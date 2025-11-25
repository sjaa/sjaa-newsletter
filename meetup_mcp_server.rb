#!/usr/bin/env ruby

require 'json'
require 'date'
require 'sjaa-meetup'

# MCP Server for SJAA Meetup Events
# This server provides a tool to fetch events from the SJAA Meetup page

class MeetupMCPServer
  MEETUP_URL = "https://www.meetup.com/sj-astronomy/events/"

  def initialize
    @capabilities = {
      tools: {}
    }
    @tools = [
      {
        name: "get-meetup-events",
        description: "Scrape and retrieve upcoming events from the SJAA Meetup page",
        inputSchema: {
          type: "object",
          properties: {
            url: {
              type: "string",
              description: "Meetup group URL (defaults to SJAA Meetup page)",
              default: MEETUP_URL
            },
            start_date: {
              type: "string",
              description: "Filter events starting from this date (ISO 8601 format: YYYY-MM-DD)"
            },
            end_date: {
              type: "string",
              description: "Filter events up to this date (ISO 8601 format: YYYY-MM-DD)"
            }
          }
        }
      }
    ]
  end

  def handle_initialize(params)
    {
      protocolVersion: "2024-11-05",
      capabilities: @capabilities,
      serverInfo: {
        name: "sjaa-meetup-mcp",
        version: "1.0.0"
      }
    }
  end

  def handle_list_tools
    {
      tools: @tools
    }
  end

  def handle_call_tool(params)
    tool_name = params["name"]
    arguments = params["arguments"] || {}

    case tool_name
    when "get-meetup-events"
      get_meetup_events(arguments)
    else
      {
        content: [
          {
            type: "text",
            text: "Unknown tool: #{tool_name}"
          }
        ],
        isError: true
      }
    end
  end

  def event_to_hash(event, truncate_description: false)
    hash = {
      id: event.id,
      title: event.title,
      url: event.url,
      description: truncate_description ? truncate_text(event.description, 200) : event.description,
      date_time: event.date_time,
      end_time: event.end_time,
      status: event.status,
      event_type: event.event_type,
      is_online: event.is_online,
      rsvp_state: event.rsvp_state,
      created_time: event.created_time,
      venue: event.venue,
      group_name: event.group_name,
      group_timezone: event.group_timezone,
      going_count: event.going_count
    }
    hash[:description] += "..." if truncate_description && event.description&.length.to_i > 200
    hash
  end

  def truncate_text(text, max_length)
    return text if text.nil? || text.length <= max_length
    text[0...max_length]
  end

  def parse_date(date_string)
    return nil if date_string.nil? || date_string.empty?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def parse_event_date(event)
    return nil if event.date_time.nil?
    DateTime.parse(event.date_time).to_date
  rescue ArgumentError
    nil
  end

  def filter_events_by_date(events, start_date, end_date)
    start_d = parse_date(start_date)
    end_d = parse_date(end_date)

    return events if start_d.nil? && end_d.nil?

    events.select do |event|
      event_date = parse_event_date(event)
      next false if event_date.nil?

      in_range = true
      in_range = event_date >= start_d if start_d
      in_range = in_range && event_date <= end_d if end_d
      in_range
    end
  end

  # Rough token estimation: ~4 characters per token
  def estimate_tokens(text)
    (text.length / 4.0).ceil
  end

  def get_meetup_events(arguments)
    url = arguments["url"] || MEETUP_URL
    start_date = arguments["start_date"]
    end_date = arguments["end_date"]
    max_tokens = 24000 # Leave some buffer below 25k limit

    begin
      events = SJAA::Meetup.scrape(url)

      # Filter events by date range if provided
      events = filter_events_by_date(events, start_date, end_date)

      # Convert Event objects to hashes for JSON serialization
      events_array = events.map { |event| event_to_hash(event, truncate_description: false) }

      # Generate JSON and check token count
      json_output = JSON.pretty_generate(events_array)
      estimated_tokens = estimate_tokens(json_output)

      # If we exceed the token limit, try with truncated descriptions
      if estimated_tokens > max_tokens
        STDERR.puts "Initial output (~#{estimated_tokens} tokens) exceeds limit, truncating descriptions..."
        events_array = events.map { |event| event_to_hash(event, truncate_description: true) }
        json_output = JSON.pretty_generate(events_array)
        estimated_tokens = estimate_tokens(json_output)

        # If still too large, progressively remove events from the end
        while estimated_tokens > max_tokens && events_array.length > 1
          events_array.pop
          json_output = JSON.pretty_generate(events_array)
          estimated_tokens = estimate_tokens(json_output)
          STDERR.puts "Still too large (~#{estimated_tokens} tokens), reduced to #{events_array.length} events"
        end

        truncation_note = "\n\nNote: Descriptions truncated and/or some events omitted to fit within token limits."
        json_output = JSON.pretty_generate(events_array) + truncation_note
      end

      {
        content: [
          {
            type: "text",
            text: json_output
          }
        ]
      }
    rescue StandardError => e
      {
        content: [
          {
            type: "text",
            text: "Error fetching Meetup events: #{e.message}\n#{e.backtrace.join("\n")}"
          }
        ],
        isError: true
      }
    end
  end

  def handle_message(message)
    method = message["method"]
    params = message["params"] || {}
    id = message["id"]

    result = case method
    when "initialize"
      handle_initialize(params)
    when "tools/list"
      handle_list_tools
    when "tools/call"
      handle_call_tool(params)
    else
      { error: "Unknown method: #{method}" }
    end

    response = {
      jsonrpc: "2.0",
      id: id
    }

    if result[:error]
      response[:error] = result[:error]
    else
      response[:result] = result
    end

    response
  end

  def run
    STDERR.puts "SJAA Meetup MCP Server started"

    while line = STDIN.gets
      line = line.strip
      next if line.empty?

      begin
        message = JSON.parse(line)
        response = handle_message(message)
        puts JSON.generate(response)
        STDOUT.flush
      rescue JSON::ParserError => e
        STDERR.puts "Invalid JSON: #{e.message}"
      rescue StandardError => e
        STDERR.puts "Error processing message: #{e.message}"
        STDERR.puts e.backtrace.join("\n")
      end
    end
  end
end

if __FILE__ == $0
  server = MeetupMCPServer.new
  server.run
end

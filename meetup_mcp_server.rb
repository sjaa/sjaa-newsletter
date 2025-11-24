#!/usr/bin/env ruby

require 'json'
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

  def event_to_hash(event)
    {
      id: event.id,
      title: event.title,
      url: event.url,
      description: event.description,
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
  end

  def get_meetup_events(arguments)
    url = arguments["url"] || MEETUP_URL

    begin
      events = SJAA::Meetup.scrape(url)

      # Convert Event objects to hashes for JSON serialization
      events_array = events.map { |event| event_to_hash(event) }

      {
        content: [
          {
            type: "text",
            text: JSON.pretty_generate(events_array)
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

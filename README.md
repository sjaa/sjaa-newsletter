# SJAA Newsletter

This repository provides a command for Claude Code, `/newsletter [date]`, along with required MCP servers and tools for accessing calendars, Meetup, and for prompting the creation of email and Discord weekly newsletters for SJAA.

## Requirements

1. Node.js (Latest LTS recommended)
2. TypeScript 5.3 or higher
3. A Google Cloud project with the Calendar API enabled
4. OAuth 2.0 credentials (Client ID and Client Secret)
5. Claude Code
6. Ruby (for meetup integration)

## Google Cloud Setup

If you already have access to an OAuth Client secret file associated with a project, then you can use that.  Otherwsie, you can create your own test project as described below:

1. Go to the [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one.
3. Enable the [Google Calendar API](https://console.cloud.google.com/apis/library/calendar-json.googleapis.com) for your project. Ensure that the right project is selected from the top bar before enabling the API.
4. Create OAuth 2.0 credentials:
   - Go to Credentials
   - Click "Create Credentials" > "OAuth client ID"
   - Choose "User data" for the type of data that the app will be accessing
   - Add your app name and contact information
   - Add the following scopes (optional):
     - `https://www.googleapis.com/auth/calendar.events` (or broader `https://www.googleapis.com/auth/calendar` if needed)
   - Select "Desktop app" as the application type (Important!)
   - Add your email address as a test user under the [Audience](https://console.cloud.google.com/auth/audience)
      - Note: it will take a few minutes for the test user to be added. The OAuth consent will not allow you to proceed until the test user has propagated.
      - Note about test mode: While an app is in test mode the auth tokens will expire after 1 week and need to be refreshed by running `npm run auth`.

## sjaa-meetup Gem

Run `bundle install` to install the SJAA Meetup Gem.  You need access to the SJAA organization on GitHub.  Create a token with package read permissions, and run `bundle config set --global https://rubygems.pkg.github.com/sjaa USERNAME:TOKEN` to set your credentials before running `bundle install`.

Note that if you are using RVM, you may need to tell Claude exactly where yoru RVM installation and Gems are.  For me, it looked like this:

```json
 "sjaa-meetup-mcp": {
      "type": "stdio",
      "command": "/Users/csvensson/.rvm/rubies/ruby-2.7.2/bin/ruby",
      "args": [
        "/Users/csvensson/Documents/Git/sjaa-newsletter/meetup_mcp_server.rb"
      ],
      "env": {
        "GEM_PATH": "/Users/csvensson/.rvm/gems/ruby-2.7.2@sjaa-newsletter:/Users/csvensson/.rvm/gems/ruby-2.7.2@global",
        "GEM_HOME": "/Users/csvensson/.rvm/gems/ruby-2.7.2@sjaa-newsletter"
      }
    }
```

## Usage

Launch Claude Code and run `/newsletter [date] [message]`.  Check the MCP server status with `/mcp` command.  Output will be sent to the `output/` directory, and includes an HTML file for the email newsletter, and a set of Markdown-formatted text files for use in Discord.

To make things even smoother, you may consider allowing access to the tools used in this process through your `settings.local.json` file:

```json
{
  "permissions": {
    "allow": [
      "Bash(mkdir:*)",
      "Bash(tree:*)",
      "mcp__google-calendar-mcp__list-calendars",
      "mcp__google-calendar-mcp__search-events",
      "mcp__sjaa-meetup-mcp__get-meetup-events",
      "WebFetch(domain:*.seasky.org)",
      "WebFetch(domain:*.timeanddate.com)"
    ],
    "deny": [],
    "ask": []
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "google-calendar-mcp"
  ]
}
```
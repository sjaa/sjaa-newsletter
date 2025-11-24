# SJAA Newsletter

This repository provides a command for Claude Code, `/newsletter [date]`, along with required MCP servers and tools for accessing calendars, Meetup, and for prompting the creation of email and Discord weekly newsletters for SJAA.

## Requirements

1. Node.js (Latest LTS recommended)
2. TypeScript 5.3 or higher
3. A Google Cloud project with the Calendar API enabled
4. OAuth 2.0 credentials (Client ID and Client Secret)
5. Claude Code

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


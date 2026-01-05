# Newsletter Generator Command

Generate the SJAA weekly newsletter for the specified date.

## Arguments
- `date` (required): The start date of the week in YYYY-MM-DD format (e.g., 2025-11-24)
- `message` (optional): An optional message to include at the top of the newsletter.  

## Task

You are generating the San Jose Astronomical Association (SJAA) weekly newsletter.

**IMPORTANT: Member-Only Audience**
This newsletter is sent ONLY to SJAA members. DO NOT include calls to action to join or become a member. The audience already consists of paid members.

### 1. Check Google Calendar MCP Authentication

**IMPORTANT: Do this FIRST before gathering any data.**

Check if Google Calendar MCP tools are available by looking for `mcp__google-calendar-mcp__*` tools in your available functions.

**If Google Calendar MCP tools are NOT available:**
- The OAuth tokens have likely expired (they expire after 1 week in test mode)
- Inform the user they need to reauthenticate by running:
  ```bash
  GOOGLE_OAUTH_CREDENTIALS="./gcp-oauth.keys.json" npx @cocal/google-calendar-mcp auth
  ```
- Tell the user to restart Claude Code after authentication completes
- Do NOT proceed with newsletter generation until this is resolved

**If Google Calendar MCP tools ARE available:**
- Proceed with the newsletter generation

### 2. Parse the Date Range

The user will provide a start date. Calculate:
- Start date: The provided date
- End date: Start date + 6 days
- Week header format: "November 24-30, 2025"
- Calendar query times: ISO format with Pacific timezone (-08:00)

### 3. Gather SJAA Events

**From Meetup:**
- Search: `site:meetup.com/sj-astronomy/events`
- Extract events within the date range
- Get: title, date, time, location, description, registration URL
- Use the sjaa-meetup-mcp server if available to fetch events
  - Pass `start_date` and `end_date` parameters to filter events (YYYY-MM-DD format)

**From Google Calendar:**
- Calendar ID: `c_4779ddc46fda914aaa8045b916044a480265c50bb4642df9420923706837a63e@group.calendar.google.com`
- Time zone: `America/Los_Angeles`
- Query with calculated time_min and time_max
- Use the google-calendar-mcp server if available

**Deduplication Rules:**
- If an event appears in both sources, prefer the Meetup version (has better details)
- Match events by date/time and title similarity

### 4. Gather Celestial Events

**Sources:**

Make sure you only use the protocol (http or https) as listed below!  Some sites
do not support https.

- SeaSky.org:
  - http://www.seasky.org/astronomy/astronomy-calendar-2025.html
  - http://www.seasky.org/astronomy/astronomy-calendar-2026.html
- TimeAndDate.com: https://www.timeanddate.com/astronomy/sights-to-see.html

**Event Types to Highlight:**
- Meteor showers (peak dates, visibility)
- Moon phases (especially new moon for dark sky observing)
- Planetary events (oppositions, conjunctions)
- Special phenomena (eclipses, occultations)

### 5. Generate HTML Newsletter

**IMPORTANT: Gmail Compatibility**
This newsletter must be copy-pasteable into Gmail. Use table-based layout with inline styles only.

**Styling:**
- Header: Dark background (#1a1a2e), centered logo
- Celestial Section: Light blue background (#f0f4f8), purple accent border (#7c3aed)
- Event Cards: Light gray background (#f8f9fa), blue accent border (#4a90e2)
- Member Updates: Green background (#e8f5e9), green border (#4caf50)
- Main container: 700px wide table, centered on page
- All styles must be inline (no CSS classes or style tags)

**Structure:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
</head>
<body style="margin: 0; padding: 0; background-color: #ffffff; font-family: Arial, sans-serif;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color: #ffffff;">
        <tr>
            <td align="center" style="padding: 20px 10px;">
                <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="background-color: #ffffff; max-width: 700px;">
                    <!-- Header -->
                    <tr>
                        <td style="background-color: #1a1a2e; color: white; padding: 30px; text-align: center; border-radius: 8px;">
                            <img src="https://membership.sjaa.net/assets/logo_small-529b119e.png" alt="SJAA Logo" style="max-width: 150px; margin-bottom: 15px; display: block; margin-left: auto; margin-right: auto;">
                            <h1 style="margin: 0 0 10px 0; font-size: 28px; font-family: Arial, sans-serif;">SJAA Weekly Newsletter</h1>
                            <p style="margin: 5px 0; font-size: 16px; font-family: Arial, sans-serif;">Week of [WEEK_HEADER]</p>
                        </td>
                    </tr>

                    <!-- Spacer -->
                    <tr><td style="height: 30px;"></td></tr>

                    <!-- Member Update -->
                    <tr>
                        <td>
                            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td style="background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 20px; border-radius: 4px;">
                                        <p style="margin: 0 0 10px 0; font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><strong>📢 Member Update</strong></p>
                                        <p style="margin: 0; font-family: Arial, sans-serif; line-height: 1.6; color: #333;">Welcome to this week's SJAA newsletter! Manage your membership at <a href="https://membership.sjaa.net" style="color: #4a90e2; text-decoration: none;">membership.sjaa.net</a>. Contact <a href="mailto:volunteerchair@sjaa.net" style="color: #4a90e2; text-decoration: none;">volunteerchair@sjaa.net</a> to volunteer and help make our events happen!</p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Spacer -->
                    <tr><td style="height: 25px;"></td></tr>

                    <!-- Celestial Section -->
                    <tr>
                        <td>
                            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td style="background-color: #f0f4f8; border-left: 4px solid #7c3aed; padding: 20px; border-radius: 4px;">
                                        <h2 style="margin: 0 0 15px 0; color: #7c3aed; font-family: Arial, sans-serif; font-size: 22px;">✨ This Week in the Sky</h2>
                                        <!-- Insert celestial events here -->
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Spacer -->
                    <tr><td style="height: 25px;"></td></tr>

                    <!-- Event Section (repeat for each event) -->
                    <tr>
                        <td>
                            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td style="background-color: #f8f9fa; border-left: 4px solid #4a90e2; padding: 20px; border-radius: 4px;">
                                        <h3 style="margin: 0 0 15px 0; color: #4a90e2; font-family: Arial, sans-serif; font-size: 20px;">🔭 [Event Title]</h3>
                                        <p style="margin: 0 0 5px 0; font-family: Arial, sans-serif; line-height: 1.6; color: #333;"><strong>Date:</strong> [Event Date]</p>
                                        <!-- Event details here, all with inline styles -->
                                        <!-- Use p, ul, li tags with inline styles -->
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Spacer -->
                    <tr><td style="height: 30px;"></td></tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding: 20px; text-align: center; color: #666; border-top: 1px solid #ddd;">
                            <p style="margin: 0 0 10px 0; font-family: Arial, sans-serif;"><strong>San Jose Astronomical Association</strong></p>
                            <p style="margin: 0 0 10px 0; font-family: Arial, sans-serif;"><a href="https://www.sjaa.net" style="color: #4a90e2; text-decoration: none;">www.sjaa.net</a> | <a href="https://membership.sjaa.net" style="color: #4a90e2; text-decoration: none;">membership.sjaa.net</a></p>
                            <p style="margin: 20px 0 0 0; font-family: Arial, sans-serif;">Clear skies! 🌟</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
```

**Key Requirements:**
1. All content must be wrapped in nested tables
2. Main content table is 700px wide with `max-width: 700px`
3. Every element needs inline `style` attributes with:
   - `font-family: Arial, sans-serif`
   - `line-height: 1.6` for paragraphs
   - `color: #333` for body text
   - Explicit margins and padding
4. No CSS classes or `<style>` tags
5. Use `<table role="presentation">` for layout tables
6. Buttons should be tables with links inside:
```html
<table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin-top: 15px;">
    <tr>
        <td style="background-color: #4a90e2; border-radius: 4px;">
            <a href="[URL]" style="display: inline-block; color: #ffffff; font-family: Arial, sans-serif; font-size: 16px; font-weight: normal; line-height: 1; text-align: center; text-decoration: none; padding: 12px 24px; border-radius: 4px;">[Button Text]</a>
        </td>
    </tr>
</table>
```

### 6. Generate Discord Versions

Create Discord-formatted markdown:

**Formatting Rules:**
- Headers: Use `##` markdown
- Emojis: 🌟 🔭 🌌 🪐 🌠 🌑 (use consistently)
- Major section separator: `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`
- Event separator: `───────────────────────────────`
- Bullets: Use `•`

**Character Limit:**
- Split at 3900 characters (buffer below 4000 limit)
- Split at clean boundaries (between sections or events)
- Number parts sequentially if needed

**Template:**
```
# 🌟 SJAA WEEKLY NEWSLETTER
**Week of [WEEK_HEADER]**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📢 MEMBER UPDATE
Welcome to this week's SJAA newsletter! Manage your membership at
https://membership.sjaa.net. Contact volunteerchair@sjaa.net to volunteer and help make our events happen!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✨ THIS WEEK IN THE SKY

[Celestial events]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📅 UPCOMING EVENTS

[SJAA events]

───────────────────────────────

[Between events]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## About SJAA
The San Jose Astronomical Association brings together amateur astronomers and sky enthusiasts.
Visit https://www.sjaa.net for more information.

Clear skies! 🌟
```

### 7. Save Output Files

Create files in the `./output/{week}` directory, where `{week}` is the week of the newsletter:

**Naming Convention:**
- Date format: `nov24_2025` (month + day + year, lowercase)
- HTML: `sjaa_newsletter_[date].html`
- Discord (split): `sjaa_newsletter_[date]_discord_part1.md`, `part2.md`, etc.

**Example outputs for 2025-11-24:**
- `sjaa_newsletter_nov24_2025.html`
- `sjaa_newsletter_nov24_2025_discord.md` (or split into parts)

### Member-Focused Messaging

**Audience Context:**
- This newsletter goes ONLY to SJAA members
- DO NOT include calls to "join" or "become a member"
- Members already have access to all member benefits

**Always include:**
- Link to https://membership.sjaa.net for membership management
- Volunteer opportunities email: volunteerchair@sjaa.net
- Use 🔒 icon for member-only events

**For Member Observing Events (Mendoza Ranch, etc.):**
- Include sign-up form: https://forms.gle/HkDVyM6XRSoM9a7i6
- Link to observers mailing list: observers@sjaa.net (NOT the old Google Groups link)
- Add weather disclaimer: "Please monitor observers@sjaa.net for go/no-go decisions based on weather conditions."

Include the optional `message` argument in this same section.

### Final Steps

1. Display a summary of what was generated
2. List all output file paths
3. Confirm the newsletter is ready for distribution

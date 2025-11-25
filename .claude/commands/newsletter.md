# Newsletter Generator Command

Generate the SJAA weekly newsletter for the specified date.

## Arguments
- `date` (required): The start date of the week in YYYY-MM-DD format (e.g., 2025-11-24)
- `message` (optional): An optional message to include at the top of the newsletter.  

## Task

You are generating the San Jose Astronomical Association (SJAA) weekly newsletter.

### 1. Parse the Date Range

The user will provide a start date. Calculate:
- Start date: The provided date
- End date: Start date + 6 days
- Week header format: "November 24-30, 2025"
- Calendar query times: ISO format with Pacific timezone (-08:00)

### 2. Gather SJAA Events

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

### 3. Gather Celestial Events

**Sources:**
- SeaSky.org: 
  - http://www.seasky.org/astronomy/astronomy-calendar-2025.html
  - http://www.seasky.org/astronomy/astronomy-calendar-2026.html
- TimeAndDate.com: https://www.timeanddate.com/astronomy/sights-to-see.html

**Event Types to Highlight:**
- Meteor showers (peak dates, visibility)
- Moon phases (especially new moon for dark sky observing)
- Planetary events (oppositions, conjunctions)
- Special phenomena (eclipses, occultations)

### 4. Generate HTML Newsletter

Create an HTML file with embedded CSS:

**Styling:**
- Header: Gradient background (#1a1a2e to #16213e), centered logo
- Celestial Section: Light blue background (#f0f4f8), purple accent border (#7c3aed)
- Event Cards: Light gray background (#f8f9fa), blue accent border (#4a90e2)
- Member Updates: Green background (#e8f5e9), green border (#4caf50)

**Structure:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 700px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            padding: 30px;
            text-align: center;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .header-logo {
            max-width: 150px;
            margin-bottom: 15px;
        }
        .celestial-section {
            background: #f0f4f8;
            border-left: 4px solid #7c3aed;
            padding: 20px;
            margin-bottom: 25px;
            border-radius: 4px;
        }
        .event {
            background: #f8f9fa;
            border-left: 4px solid #4a90e2;
            padding: 20px;
            margin-bottom: 25px;
            border-radius: 4px;
        }
        .info-note {
            padding: 15px;
            margin-bottom: 25px;
            border-radius: 4px;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            border-top: 1px solid #ddd;
            margin-top: 30px;
        }
        a {
            color: #4a90e2;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="header">
        <img src="https://membership.sjaa.net/assets/logo_small-529b119e.png" alt="SJAA Logo" class="header-logo">
        <h1>SJAA Weekly Newsletter</h1>
        <p>Week of [WEEK_HEADER]</p>
    </div>

    <div class="info-note" style="background: #e8f5e9; border-left: 4px solid #4caf50;">
        <strong>📢 Member Update</strong>
        <p>Welcome to the weekly SJAA newsletter! Manage your membership at
        <a href="https://membership.sjaa.net">membership.sjaa.net</a>.
        Contact <a href="mailto:volunteerchair@sjaa.net">volunteerchair@sjaa.net</a>
        to volunteer!</p>
    </div>

    <!-- Insert celestial and SJAA events sections here -->

    <div class="footer">
        <p>San Jose Astronomical Association</p>
        <p><a href="https://www.sjaa.net">www.sjaa.net</a> | <a href="https://membership.sjaa.net">membership.sjaa.net</a></p>
        <p>Clear skies! 🌟</p>
    </div>
</body>
</html>
```

### 5. Generate Discord Versions

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
https://membership.sjaa.net. Contact volunteerchair@sjaa.net to get involved!

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

### 6. Save Output Files

Create files in the `./output/{week}` directory, where `{week}` is the week of the newsletter:

**Naming Convention:**
- Date format: `nov24_2025` (month + day + year, lowercase)
- HTML: `sjaa_newsletter_[date].html`
- Discord (split): `sjaa_newsletter_[date]_discord_part1.md`, `part2.md`, etc.

**Example outputs for 2025-11-24:**
- `sjaa_newsletter_nov24_2025.html`
- `sjaa_newsletter_nov24_2025_discord.md` (or split into parts)

### Member-Focused Messaging

Always include:
- Link to https://membership.sjaa.net for membership management
- Volunteer opportunities email: volunteer@sjaa.net
- Emphasize member benefits (Mendoza Ranch access, member events)
- Use 🔒 icon for member-only events

Include the optional `message` argument in this same section.

### Final Steps

1. Display a summary of what was generated
2. List all output file paths
3. Confirm the newsletter is ready for distribution

"""
SJAA Newsletter Generator - Implementation Reference
====================================================

This script provides helper functions and reference implementation
for the /newsletter command workflow.

The /newsletter command in newsletter.md will guide Claude through
the full workflow. This script serves as a reference for the logic.
"""

import datetime
from typing import Tuple, List, Dict


def parse_date_range(start_date_str: str) -> Tuple[datetime.datetime, datetime.datetime, str, str, str]:
    """
    Parse start date and calculate week range.

    Args:
        start_date_str: Date in YYYY-MM-DD format

    Returns:
        Tuple of (start_date, end_date, header_format, time_min, time_max)
    """
    start_date = datetime.datetime.strptime(start_date_str, "%Y-%m-%d")
    end_date = start_date + datetime.timedelta(days=6)

    # Format for newsletter header (e.g., "November 24-30, 2025")
    header_format = f"{start_date.strftime('%B %d')}-{end_date.day}, {start_date.year}"

    # Format for calendar queries (ISO format with Pacific timezone)
    time_min = f"{start_date.strftime('%Y-%m-%dT00:00:00-08:00')}"
    time_max = f"{end_date.strftime('%Y-%m-%dT23:59:59-08:00')}"

    return start_date, end_date, header_format, time_min, time_max


def format_output_filename(start_date: datetime.datetime, file_type: str, part_num: int = None) -> str:
    """
    Generate output filename based on date and type.

    Args:
        start_date: Starting date of the week
        file_type: 'html' or 'discord'
        part_num: Optional part number for split Discord files

    Returns:
        Formatted filename
    """
    date_str = start_date.strftime("%b%d_%Y").lower()

    if file_type == 'html':
        return f"sjaa_newsletter_{date_str}.html"
    elif file_type == 'discord':
        if part_num is None:
            return f"sjaa_newsletter_{date_str}_discord.txt"
        else:
            return f"sjaa_newsletter_{date_str}_discord_part{part_num}.txt"


def calculate_discord_split_points(content: str, max_chars: int = 3900) -> List[str]:
    """
    Split Discord content at clean boundaries.

    Good split points:
    - After major section separators (━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
    - After event separators (───────────────────────────────)
    - Between celestial events

    Args:
        content: Full Discord content
        max_chars: Maximum characters per part (default 3900)

    Returns:
        List of content parts
    """
    if len(content) <= max_chars:
        return [content]

    parts = []
    current_part = ""
    lines = content.split('\n')

    major_separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    event_separator = "───────────────────────────────"

    for line in lines:
        # Check if adding this line would exceed the limit
        if len(current_part) + len(line) + 1 > max_chars:
            # If we have content, save it as a part
            if current_part:
                parts.append(current_part.strip())
                current_part = ""

        current_part += line + '\n'

        # If we hit a separator and we're getting close to limit, consider splitting
        if line.strip() in [major_separator, event_separator]:
            if len(current_part) > max_chars * 0.7:  # If over 70% full
                parts.append(current_part.strip())
                current_part = ""

    # Add the last part
    if current_part:
        parts.append(current_part.strip())

    return parts


# Data source constants
MEETUP_URL = "https://www.meetup.com/sj-astronomy/events/"
GOOGLE_CALENDAR_ID = "c_4779ddc46fda914aaa8045b916044a480265c50bb4642df9420923706837a63e@group.calendar.google.com"
TIMEZONE = "America/Los_Angeles"

# Celestial event sources
SEASKY_URL = "http://www.seasky.org/astronomy/astronomy-calendar-2025.html"
TIMEANDDATE_URL = "https://www.timeanddate.com/astronomy/sights-to-see.html"

# Output directory
OUTPUT_DIR = "./output"

# Member resources
MEMBERSHIP_URL = "https://membership.sjaa.net"
VOLUNTEER_EMAIL = "volunteerchair@sjaa.net"
SJAA_WEBSITE = "https://www.sjaa.net"
LOGO_URL = "https://membership.sjaa.net/assets/logo_small-529b119e.png"


# HTML Template Constants
HTML_COLORS = {
    "header_gradient_start": "#1a1a2e",
    "header_gradient_end": "#16213e",
    "celestial_bg": "#f0f4f8",
    "celestial_border": "#7c3aed",
    "event_bg": "#f8f9fa",
    "event_border": "#4a90e2",
    "member_update_bg": "#e8f5e9",
    "member_update_border": "#4caf50"
}


# Discord Format Constants
DISCORD_EMOJIS = {
    "star": "🌟",
    "telescope": "🔭",
    "galaxy": "🌌",
    "saturn": "🪐",
    "shooting_star": "🌠",
    "new_moon": "🌑",
    "announcement": "📢",
    "calendar": "📅",
    "sparkles": "✨",
    "lock": "🔒"
}

MAJOR_SEPARATOR = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EVENT_SEPARATOR = "───────────────────────────────"


def get_event_priority(event: Dict) -> int:
    """
    Determine event priority for deduplication.
    Meetup events have higher priority (lower number) than calendar events.

    Args:
        event: Event dictionary with 'source' key

    Returns:
        Priority value (lower = higher priority)
    """
    if event.get('source') == 'meetup':
        return 1
    elif event.get('source') == 'calendar':
        return 2
    else:
        return 3


def events_match(event1: Dict, event2: Dict, date_tolerance_hours: int = 2) -> bool:
    """
    Check if two events are the same based on date/time and title similarity.

    Args:
        event1: First event dictionary
        event2: Second event dictionary
        date_tolerance_hours: How many hours difference to allow in matching

    Returns:
        True if events match, False otherwise
    """
    # Compare dates (within tolerance)
    # Compare titles (fuzzy match - remove common words, check overlap)
    # This is a simplified version - implement full logic as needed

    if 'start_time' in event1 and 'start_time' in event2:
        time_diff = abs((event1['start_time'] - event2['start_time']).total_seconds() / 3600)
        if time_diff > date_tolerance_hours:
            return False

    # Title similarity check would go here
    # Could use fuzzy matching libraries or simple word overlap

    return False


if __name__ == "__main__":
    # Example usage
    start_date, end_date, header, time_min, time_max = parse_date_range("2025-11-24")
    print(f"Week: {header}")
    print(f"Time range: {time_min} to {time_max}")
    print(f"HTML filename: {format_output_filename(start_date, 'html')}")
    print(f"Discord filename: {format_output_filename(start_date, 'discord')}")

"""
Applet: YouTube Stats
Summary: View your YouTube stats
Description: View your YouTube stats such as total subscriber and view count.
Author: Chase Roossin
"""

load("render.star", "render")
load("schema.star", "schema")
load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("humanize.star", "humanize")
load("encoding/base64.star", "base64")

BASE_URL = "https://www.googleapis.com/youtube/v3"
SPACE = "   "

YOUTUBE_LOGO = "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9hPz9383XNaGLzju+0YwtkP9K2cJ4AtGAdi3U30oYBJAAJjrPxglAAF4JdtQHwpYBREApvqQVRAB8A/AN6yCCMCl2alrfeybVkG47PhOUI713jeugjAJwH6t9Z5VEAHwC+DVV0EEgLHeC1kFEQDqvZBVEAHgVu+FrIIIAG/13nevggjA3LzAMcAvrIIwJ9wKLgAfr4KwCMATjwBWQQRAAKyCCIAAWAURAAGwCiIAAmAVRAAEwCqIAAiAVRABEIB3qyACsHYeAbAKcrdWdSIBsApy95QBEACrIAIgAFZBBEAArIIIgABYBREAAbAKIgACYBVEAATAKogACIBVEAEQAKsgAiAAVkEEQACsgtTYCIBVUAAQgD84zp1FABAABwMEAAGwCgoAAnBPwNpxBAABsAoKAAJwd14aAWBHAbAKIgACYBVEAATAKogACIBVEAEQAKsgAiAAVkEEQACsggiAAFgFEQABsAoiAAJgFUQABMAqSJ0bAUhdBampEQCroAAgAFZBAUAA9rkKIgACYBVEAATAKogACIBVEAEQAKsgAiAAVkEEQACsggiAAFgFEQABsAoiAAJgFUQABMAqiAAIgFUQARAAqyACIABWQQFAAKyCAoAAWAUFAAGwCgoAAmAVFAAEwCooAAiAVVAAEACroAAgAFZBAUAArIICgABYBQUAAbAKCgACYBUUAATAKigACIBVUAAQAKugACAAVkEBQACsggKAANwdrIJhAUAAHAwQAATAKigACMDd+dbEBQABsAoKAAJwN86NAPAKAbAKCgACYBUUAATAKigACIBVUAAQAKugACAAVkEBQACsggKAAFgFBQABsAoKAAJgFRQAAcAPAQEQAMa1iQ2AADDMTW4ABIBzkxsAAeC4NYEBEAAUQAAEgGOTGwAB4NLkBkAAWJrYAAgAhyY3AALA3HyfujapAfAckFqapwoAa/Ntam6eIwD4DeAZgAAwNQIgAAKAAAiAACAAAuAZAAIgAFYABEAAnANAAATALwAEQAC8C4AACIC3AREAAXAfAAIgAJ4AIgAC4E5AAUAA/P0LAALguwACgAD4MpAAIAC+DSgACICvAwsAPzAADNPWRAZAADj48w8LAALgn38BEADGuREAAcg0Lk1mABCA863JDAACcF4bARAAux8CIAB2PwRAAOx+CIAA2P0QAAGw+yEAAmD3QwAEwO6H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"

# config
CONFIG_CHANNEL_ID = "config-channel-id"
CONFIG_DEV_API_KEY = "config-dev-api-key"

def main(config):
    channelId = config.str(CONFIG_CHANNEL_ID)

    # TODO: Add api key to secret
    apiKey = config.str(CONFIG_DEV_API_KEY)

    if channelId == None:
        return render.Root(
            child = twoLine("No Channel", "ID Found"),
        )

    if apiKey == None:
        return render.Root(
            child = twoLine("No API", "Key Found"),
        )

    cacheKeyStats = "youtube-cache-id" + channelId
    cachedStatsData = cache.get(cacheKeyStats)

    # Make overal stats call
    if cachedStatsData != None:
        print("Hit! Displaying cached stats data.")
        statsData = json.decode(cachedStatsData)
    else:
        print("Miss cache! Calling YouTube")
        statRep = http.get(
            BASE_URL + "/channels",
            headers = {"Accept": "application/json"},
            params = {"part": "statistics", "id": channelId, "key": apiKey},
        )

        # Ensure valid response
        if statRep.status_code != 200:
            return render.Root(
                child = twoLine("YouTube Error", "Status: " + str(statRep.status_code)),
            )

        statsData = statRep.json()

        # Update cache
        cache.set(cacheKeyStats, json.encode(statsData), ttl_seconds = 1800)  # 1hr TTL

    subscriberCount = statsData["items"][0]["statistics"]["subscriberCount"]
    viewCount = statsData["items"][0]["statistics"]["viewCount"]

    # Make call to get latest video
    cacheKeyLatestVideo = "youtube-cache-latest-video" + channelId
    cachedLatestVideoData = cache.get(cacheKeyLatestVideo)

    if cacheKeyLatestVideo == None:
        print("Hit! Displaying cached latest video data.")
        latestVideoData = json.decode(cachedLatestVideoData)
    else:
        print("Miss cache! Calling YouTube")
        latestVidRep = http.get(
            BASE_URL + "/search",
            headers = {"Accept": "application/json"},
            params = {"part": "snippet", "channelId": channelId, "maxResults": "1", "order": "date", "type": "video", "key": apiKey},
        )

        # Ensure valid response
        if latestVidRep.status_code != 200:
            return render.Root(
                child = twoLine("YouTube Error", "Status: " + str(latestVidRep.status_code)),
            )

        latestVideoData = latestVidRep.json()

        # Update cache
        cache.set(cacheKeyLatestVideo, json.encode(latestVideoData), ttl_seconds = 1800)  # 1hr TTL

    videoId = latestVideoData["items"][0]["id"]["videoId"]
    videoTitle = latestVideoData["items"][0]["snippet"]["title"]

    # Make call to get latest video stats
    cacheKeyVideoStats = "youtube-cache-video-stats" + videoId
    cachedVideoStatsData = cache.get(cacheKeyVideoStats)

    if cachedVideoStatsData != None:
        print("Hit! Displaying cached latest video data.")
        latestVideoStatsData = json.decode(cachedVideoStatsData)
    else:
        print("Miss cache! Calling YouTube")
        latestVidStatsRep = http.get(
            BASE_URL + "/videos",
            headers = {"Accept": "application/json"},
            params = {"part": "statistics", "id": videoId, "key": apiKey},
        )

        # Ensure valid response
        if latestVidStatsRep.status_code != 200:
            return render.Root(
                child = twoLine("YouTube Error", "Status: " + str(latestVidStatsRep.status_code)),
            )

        latestVideoStatsData = latestVidStatsRep.json()

        # Update cache
        cache.set(cacheKeyLatestVideo, json.encode(latestVideoStatsData), ttl_seconds = 1800)  # 1hr TTL

    videoViewCount = latestVideoStatsData["items"][0]["statistics"]["viewCount"]
    videoLikeCount = latestVideoStatsData["items"][0]["statistics"]["likeCount"]
    videoCommentCount = latestVideoStatsData["items"][0]["statistics"]["commentCount"]

    return render.Root(
        child = render.Row(
            children = [
                render.Box(
                    width = 18,
                    color = "#f40c00",
                    child = render.Image(src = base64.decode(YOUTUBE_LOGO), width = 16),
                ),
                render.Column(
                    children = [
                        render.Padding(
                            child = render.Row(
                                main_align = "start",
                                cross_align = "start",
                                expanded = True,
                                children = [
                                    render.Text(compact_number(subscriberCount)),
                                ],
                            ),
                            pad = (3, 3, 0, 0),
                        ),
                        render.Padding(
                            child = render.Row(
                                main_align = "start",
                                cross_align = "start",
                                expanded = True,
                                children = [
                                    render.Text(compact_number(viewCount)),
                                ],
                            ),
                            pad = (3, 0, 0, 0),
                        ),
                        render.Marquee(
                            width = 46,
                            child = render.Row(
                                children = [
                                    render.Text(videoTitle),
                                    render.Text(content = SPACE + compact_number(int(videoViewCount)) + SPACE + compact_number(int(videoLikeCount)) + SPACE + compact_number(int(videoCommentCount)), color = "#636363")
                                ],
                            ),
                        ),
                    ],
                ),
            ],
        ),
    )

def twoLine(line1, line2):
    return render.Box(
        width = 64,
        child = render.Column(
            cross_align = "center",
            children = [
                render.Text(content = line1, font = "CG-pixel-4x5-mono"),
                render.Text(content = line2, font = "CG-pixel-4x5-mono", height = 10),
            ],
        ),
    )

# NOTE: The below 2 functions were found from the plausibleanalytics Tidbyt app
# Thank you very much for that!!!
#
# Converts a large number into a compact string that is 6 characters or less.
# Values under 10,000 will be returned as-is eg. 120 stays 120
# Values over 10,000 will have the suffix "K" eg. 12,345 becomes 12.34K
# Values over 1,000,000 will have the suffix "M" eg. 1,234,567 becomes 1.23M
# Values over 1,000,000,000 will have the suffix "B" eg, 1,234,456,789 becomes 1.23B
# Values over a billion will return the string "A LOT!" (What are you? Google?)
def compact_number(number):
    value_string = str(number)

    # Get length of string
    character_count = len(value_string)

    # Return the string if it's 4 characters or less
    if character_count <= 4:
        return humanize.comma(number)

    # Thousands
    if character_count <= 6:
        return decorate_value(value_string, character_count - 3, "K")

    # Millions
    if character_count <= 9:
        return decorate_value(value_string, character_count - 6, "M")

    # Billions
    if character_count <= 12:
        return decorate_value(value_string, character_count - 9, "B")

    # Yikes, that's a lot
    return "A LOT!"

# Takes a string, grabs the first 4 characters,  and decorates it with the decimal separator
# and the correct suffix eg. "1234" becomes "1.234K".
# It will also remove any trailing "0" eg. 1010 becomes "1.01K" and 1000 becomes "1K".
# characters
#    value: Any string to decorate
#    decimal_index: The index in the string where to place the decimal separator (1, 2, or 3)
#    suffix: The character to place at the end of the string ("K", "M", or "B")
def decorate_value(value, decimal_index, suffix):
    # Convert the string to a list
    value_list = list(value.elems())

    # Take the first 4 characters
    cropped_list = value_list[:4]

    # Insert the "." character at the decimal_index
    cropped_list.insert(decimal_index, ".")

    # Smash it back into a string
    joined = "".join(cropped_list)

    # Loop through and remove any and all trailing "0" characters
    for _ in range(len(joined)):
        joined = joined.removesuffix("0")

    # Remove a trailing decimal separator if present
    joined = joined.removesuffix(".")

    # Return the joined string, with the suffix added
    return joined + suffix

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = CONFIG_CHANNEL_ID,
                name = "Channel Id",
                desc = "The id of the channel you would like stats on",
                icon = "user",
            ),
            schema.Text(
                id = CONFIG_DEV_API_KEY,
                name = "Dev API Key",
                desc = "Dev API Key for YouTube",
                icon = "key",
            ),
        ],
    )

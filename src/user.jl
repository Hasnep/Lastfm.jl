using JSON3
using HTTP
using DataFrames
using Dates

export user_get_friends
export user_get_info
export user_get_loved_tracks
export user_get_personal_tags
export user_get_recent_tracks
export user_get_top_albums
export user_get_top_artists
export user_get_top_tags
export user_get_top_tracks
export user_get_weekly_album_chart
export user_get_weekly_artist_chart
export user_get_weekly_chart_list
export user_get_weekly_track_chart

valid_periods = ["overall", "7day", "1month", "3month", "6month", "12month"]
valid_tagging_types = ["artist", "album", "track"]

"""
    function user_get_friends(username::String; recenttracks::Bool, limit::Integer = 50, page::Integer = 1)::DataFrame

Get a list of the user's friends on Last.fm.

* `username` The name of the Last.fm user to fetch the friends of
* `recenttracks` Whether or not to include information about friends' recent listening in the response # TODO: add this arg and decide on its type conversion and default value
* `limit` The number of results to fetch per page # TODO: add this arg
* `page` The page number to fetch # TODO: add this arg
"""
function user_get_friends(username::String; limit::Integer = 50, page::Integer = 1)::DataFrame # TODO: add `recent_tracks::Bool,`
    uri::HTTP.URI = get_uri("user.getFriends", user = username, limit = limit, page = page) # TODO: add `recenttracks = recent_tracks,`
    response::HTTP.Response = get_response(uri)
    friends = JSON3.read(String(response.body))["friends"]["user"]
    output::DataFrame = DataFrame(
        username = String[],
        country = String[],
        playcount = Integer[],
        playlists = Integer[],
        realname = String[],
        subscriber = Bool[],
        url = String[],
    )
    for friend_info in friends
        friend_flattened = Dict(
            :username => parse_string(friend_info["name"]),
            :country => parse_string(friend_info["country"]),
            :playcount => parse_integer(friend_info["playcount"]),
            :playlists => parse_integer(friend_info["playlists"]),
            :realname => parse_string(friend_info["realname"]),
            :subscriber => parse_bool(friend_info["subscriber"]),
            :url => parse_string(friend_info["url"]),
        )
        push!(output, friend_flattened)
    end
    return output
end

"""
    function user_get_info(username::String)::DataFrame

Get information about a user profile.

* `username` The name of the Last.fm user to fetch the info of
"""
function user_get_info(username::String)::DataFrame
    uri::HTTP.URI = get_uri("user.getInfo", user = username)
    response::HTTP.Response = get_response(uri)
    user_info = JSON3.read(String(response.body))["user"]
    output::DataFrame = DataFrame(
        username = String[],
        age = Integer[],
        bootstrap = Bool[],
        country = String[],
        gender = String[],
        playcount = Integer[],
        playlists = Integer[],
        realname = String[],
        registered_datetime = DateTime[],
        subscriber = String[],
        type = String[],
        url = String[],
    )
    user_flattened = Dict(
        :username => parse_string(user_info["name"]),
        :age => parse_integer(user_info["age"]),
        :bootstrap => parse_bool(user_info["bootstrap"]),
        :country => parse_string(user_info["country"]),
        :gender => parse_string(user_info["gender"]),
        :playcount => parse_integer(user_info["playcount"]),
        :playlists => parse_integer(user_info["playlists"]),
        :realname => parse_string(user_info["realname"]),
        :registered_datetime => parse_unix_timestamp(user_info["registered"]["unixtime"]),
        :subscriber => parse_string(user_info["subscriber"]),
        :type => parse_string(user_info["type"]),
        :url => parse_string(user_info["url"]),
    )
    push!(output, user_flattened)
    return output
end

"""
    function user_get_loved_tracks(username::String; limit::Integer = 50, page::Integer = 1)::DataFrame

Get the last 50 tracks loved by a user.

* `username` The name of the Last.fm user to fetch the loved tracks of
* `limit` The number of results to fetch per page
* `page` The page number to fetch
"""
function user_get_loved_tracks(username::String; limit::Integer = 50, page::Integer = 1)::DataFrame
    uri::HTTP.URI = get_uri("user.getLovedTracks", user = username)
    response::HTTP.Response = get_response(uri)
    loved_tracks = JSON3.read(String(response.body))["lovedtracks"]["track"]
    output::DataFrame = DataFrame(track = String[], artist = String[], date = DateTime[], url = String[])
    for loved_track in loved_tracks
        loved_track_flattened = Dict(
            :track => parse_string(loved_track["name"]),
            :artist => parse_string(loved_track["artist"]["name"]),
            :date => parse_unix_timestamp(loved_track["date"]["uts"]),
            :url => parse_string(loved_track["url"]),
        )
        push!(output, loved_track_flattened)
    end
    return output
end

"""
    function user_get_personal_tags(username::String; limit::Integer = 50, page::Integer = 1)::DataFrame

Get the user's personal tags

* `username` The name of the Last.fm user to fetch the personal tags of
* `tag` The tag you are interested in
* `tagging_type` The type of items which have been tagged
* `limit` The number of results to fetch per page
* `page` The page number to fetch
"""
function user_get_personal_tags(
    username::String,
    tag::String,
    tagging_type::String;
    limit::Integer = 50,
    page::Integer = 1,
)::DataFrame
    @assert tagging_type ∈ valid_tagging_types "tagging_type must be one of '$(join(valid_tagging_types, "', '", "' or '"))'."
    uri::HTTP.URI = get_uri("user.getPersonalTags", user = username, tag = tag, taggingtype = tagging_type)
    response::HTTP.Response = get_response(uri)
    personal_tags = JSON3.read(String(response.body))["taggings"][tagging_type * "s"][tagging_type]
    if tagging_type in ["album", "track"]
        artist_info
    else

    end
    output::DataFrame = DataFrame(Dict(
        :username => String[],
        :tag => String[],
        Symbol(tagging_type) => String[],
        :mbid => String[],
        :url => String[],
    ))
    for personal_tag in personal_tags
        personal_tag_flattened = Dict(
            :username => username,
            :tag => tag,
            Symbol(tagging_type) => parse_string(personal_tag["name"]),
            :mbid => parse_string(personal_tag["mbid"]),
            :url => parse_string(personal_tag["url"]),
        )
        push!(output, personal_tag_flattened)
    end
    return output
end

"""
    function user_get_recent_tracks(username::String; limit::Integer = 50, page::Integer = 1)::DataFrame

Get a list of the recent tracks listened to by this user. Also includes the currently playing track with the nowplaying="true" attribute if the user is currently listening.

* `username` The name of the Last.fm user to fetch the recent tracks of
* `limit` The number of results to fetch per page
* `page` The page number to fetch
* `from` (Optional) : Beginning timestamp of a range - only display scrobbles after this time, in UNIX timestamp format (integer number of seconds since 00:00:00, January 1st 1970 UTC). This must be in the UTC time zone.
* `extended` (0|1) (Optional): Includes extended data in each artist, and whether or not the user has loved each track
* `to` (Optional) : End timestamp of a range - only display scrobbles before this time, in UNIX timestamp format (integer number of seconds since 00:00:00, January 1st 1970 UTC). This must be in the UTC time zone.
"""
function user_get_recent_tracks(username::String; limit::Integer = 50, page::Integer = 1)::DataFrame
    # TODO: get nowplaying = true/false
    @assert 1 <= limit <= 200 "limit must be between 1 and 200."
    uri::HTTP.URI = get_uri("user.getRecentTracks", user = username)
    response::HTTP.Response = get_response(uri)
    recent_tracks = JSON3.read(String(response.body))["recenttracks"]["track"]
    output::DataFrame = DataFrame(
        track = String[],
        album = String[],
        artist = String[],
        date = Union{DateTime,Missing}[],
        url = String[],
        now_playing = Bool[],
    )
    for recent_track in recent_tracks
        now_playing = haskey(recent_track, "@attr")
        recent_track_flattened = Dict(
            :track => parse_string(recent_track["name"]),
            :album => parse_string(recent_track["album"]["#text"]),
            :artist => parse_string(recent_track["artist"]["#text"]),
            :date => now_playing ? missing : parse_unix_timestamp(recent_track["date"]["uts"]),
            :url => parse_string(recent_track["url"]),
            :now_playing => now_playing,
        )
        push!(output, recent_track_flattened)
    end
    return output
end

"""
    function user_get_top_albums(username::String; period::String = "overall", limit::Integer = 50, page::Integer = 1)::DataFrame

Get the top albums listened to by a user. You can stipulate a time period. Sends the overall chart by default.

* `username` The name of the Last.fm user to fetch the top albums of
* `period` The time period to retrieve the top albums for
* `limit` The number of results to fetch per page
* `page` The page number to fetch
"""
function user_get_top_albums(
    username::String;
    period::String = "overall",
    limit::Integer = 50,
    page::Integer = 1,
)::DataFrame
    @assert period ∈ valid_periods "period must be one of '$(join(valid_periods, "', '", "' or '"))'."
    uri::HTTP.URI = get_uri("user.getTopAlbums", user = username)
    response::HTTP.Response = get_response(uri)
    top_albums = JSON3.read(String(response.body))["topalbums"]["album"]
    output::DataFrame = DataFrame(rank = Integer[], album = String[], artist = String[], playcount = Integer[])
    for top_album in top_albums
        top_album_flattened = Dict(
            :rank => parse_integer(top_album["@attr"]["rank"]),
            :album => parse_string(top_album["name"]),
            :artist => parse_string(top_album["artist"]["name"]),
            :playcount => parse_integer(top_album["playcount"]),
        )
        push!(output, top_album_flattened)
    end
    return output
end

"""
    function user_get_top_artists(username::String; period::String = "overall", limit::Integer = 50, page::Integer = 1)::DataFrame

Get the top artists listened to by a user. You can stipulate a time period. Sends the overall chart by default.

* `username` The name of the Last.fm user to fetch the top artists of
* `period` The time period to retrieve the top artists for
* `limit` The number of results to fetch per page
* `page` The page number to fetch
"""
function user_get_top_artists(
    username::String;
    period::String = "overall",
    limit::Integer = 50,
    page::Integer = 1,
)::DataFrame
    @assert period ∈ valid_periods "period must be one of '$(join(valid_periods, "', '", "' or '"))'."
    uri::HTTP.URI = get_uri("user.getTopArtists", user = username)
    response::HTTP.Response = get_response(uri)
    top_artists = JSON3.read(String(response.body))["topartists"]["artist"]
    output::DataFrame = DataFrame(rank = Integer[], artist = String[], playcount = Integer[])
    for top_artist in top_artists
        top_artist_flattened = Dict(
            :rank => parse_integer(top_artist["@attr"]["rank"]),
            :artist => parse_string(top_artist["name"]),
            :playcount => parse_integer(top_artist["playcount"]),
        )
        push!(output, top_artist_flattened)
    end
    return output
end

# """
#     function user_get_top_tags(username::String; limit::Integer = 50)::DataFrame

# Get the top tags used by this user.

# * `username` The name of the Last.fm user to fetch the top tags of
# * `limit` The number of results to fetch per page
# """
# function user_get_top_tags(username::String; limit::Integer = 50)::DataFrame
#     uri::HTTP.URI = get_uri("user.getTopTags", user = username)
#     response::HTTP.Response = get_response(uri)
#     tags = JSON3.read(String(response.body))
#     output::DataFrame = DataFrame(rank = Integer[],
#         album = String[],
#         artist = String[],
#         playcount = Integer[],
#     )
#     for top_album in top_albums
#         top_album_flattened = Dict(:rank => parse_integer(top_album["@attr"]["rank"]),
#             :album => parse_string(top_album["name"]),
#             :artist => parse_string(top_album["artist"]["name"]),
#             :playcount => parse_integer(top_album["playcount"]),
#         )
#         push!(output, top_album_flattened)
#     end
#     return output
# end

"""
    function user_get_top_tracks(username::String; period::String = "overall", limit::Int = 50, page::Integer = 1)::DataFrame

Get the top tracks listened to by a user. You can stipulate a time period. Sends the overall chart by default.

* `username` The name of the Last.fm user to fetch the top tracks of
* `period` The time period over which to retrieve top tracks for
* `limit` The number of results to fetch per page
* `page` The page number to fetch
"""
function user_get_top_tracks(
    username::String;
    period::String = "overall",
    limit::Int = 50,
    page::Integer = 1,
)::DataFrame
    @assert period ∈ valid_periods "period must be one of '$(join(valid_periods, "', '", "' or '"))'."
    @assert 1 <= limit <= 200 "limit must be between 1 and 200."
    uri::HTTP.URI = get_uri("user.getTopTracks", user = username)
    response::HTTP.Response = get_response(uri)
    tracks = JSON3.read(String(response.body))["toptracks"]["track"]
    # @info tracks
    # output::DataFrame = DataFrame(rank = Integer[],
    # track=String[],
    #     album = String[],
    #     artist = String[],
    #     playcount = Integer[],
    # )
    # for top_album in top_albums
    #     top_album_flattened = Dict(:rank => parse_integer(top_album["@attr"]["rank"]),
    #         :album => parse_string(top_album["name"]),
    #         :artist => parse_string(top_album["artist"]["name"]),
    #         :playcount => parse_integer(top_album["playcount"]),
    #     )
    #     push!(output, top_album_flattened)
    # end
    # return output
end

# """
# Get an album chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent album chart for this user.

# * `username` The name of the Last.fm user to fetch the album chart of
# from (Optional) : The date at which the chart should start from. See User.getChartsList for more.
# to (Optional) : The date at which the chart should end on. See User.getChartsList for more.
# """
# function user_get_weekly_album_chart(username::String; from::Date, to::Date)::DataFrame
#     uri::HTTP.URI = get_uri("user.getWeeklyAlbumChart", user = username)
#     response::HTTP.Response = get_response(uri)
#     albums = JSON3.read(String(response.body))
#   output::DataFrame = DataFrame(rank = Integer[],
#         album = String[],
#         artist = String[],
#         playcount = Integer[],
#     )
#     for top_album in top_albums
#         top_album_flattened = Dict(:rank => parse_integer(top_album["@attr"]["rank"]),
#             :album => parse_string(top_album["name"]),
#             :artist => parse_string(top_album["artist"]["name"]),
#             :playcount => parse_integer(top_album["playcount"]),
#         )
#         push!(output, top_album_flattened)
#     end
#     return output
# end

"""
    function user_get_weekly_artist_chart(username::String; from::Date, to::Date)::DataFrame

Get an artist chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent artist chart for this user.

* `username` The name of the Last.fm user to fetch the artist chart of.
* `from` (Optional) The date at which the chart should start from. See `user_get_weekly_chart_list` for more.
* `to` (Optional) The date at which the chart should end on. See `user_get_weekly_chart_list` for more.
"""
function user_get_weekly_artist_chart(username::String)::DataFrame
    uri::HTTP.URI = get_uri("user.getWeeklyArtistChart", user = username)
    response::HTTP.Response = get_response(uri)
    weekly_artist_charts = JSON3.read(String(response.body))[:weeklyartistchart][:artist]
    output::DataFrame = DataFrame(rank = Integer[],
     artist = String[], 
     playcount = Integer[], 
     mbid = String[], 
     url = String[])
    for artist_chart in weekly_artist_charts
        artist_chart_flattened = Dict(
            :rank => parse_integer(artist_chart[Symbol("@attr")][:rank]),
            :artist => parse_string(artist_chart[:name]),
            :playcount => parse_integer(artist_chart[:playcount]),
            :mbid => parse_string(artist_chart[:mbid]),
            :url => parse_string(artist_chart[:url]),
        )
        push!(output, artist_chart_flattened)
    end
    return output
end

"""
    function user_get_weekly_chart_list(username::String)::DataFrame

Get a list of available charts for this user, expressed as date ranges which can be sent to the chart services.
"""
function user_get_weekly_chart_list(username::String)::DataFrame
    uri::HTTP.URI = get_uri("user.getWeeklyChartList", user = username)
    response::HTTP.Response = get_response(uri)
    charts = JSON3.read(String(response.body))[:weeklychartlist][:chart]
    output::DataFrame = DataFrame(from = Date[], to = Date[])
    for chart in charts
        chart_flattened =
            Dict(:from => parse_core_data_timestamp(chart[:from]), :to => parse_core_data_timestamp(chart[:to]))
        push!(output, chart_flattened)
    end
    return output
end

"""
    function user_get_weekly_track_chart(username::String; from::Date, to::Date)::DataFrame

Get a track chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent track chart for this user.

* `username` The name of the Last.fm user to fetch the track chart of
* `from` (Optional) : The date at which the chart should start from. See User.getWeeklyChartList for more.
* `to` (Optional) : The date at which the chart should end on. See User.getWeeklyChartList for more.
"""
function user_get_weekly_track_chart(username::String)::DataFrame
    uri::HTTP.URI = get_uri("user.getWeeklyTrackChart", user = username)
    response::HTTP.Response = get_response(uri)
    weekly_track_charts = JSON3.read(String(response.body))[:weeklytrackchart][:track]
    output::DataFrame = DataFrame(rank = Integer[], track = String[], artist = String[], playcount = Integer[])
    for track_chart in weekly_track_charts
        track_chart_flattened = Dict(
            :rank => parse_integer(track_chart[Symbol("@attr")][:rank]),
            :track => parse_string(track_chart[:name]),
            :artist => parse_string(track_chart[:artist][Symbol("#text")]),
            :playcount => parse_integer(track_chart[:playcount]),
        )
        push!(output, track_chart_flattened)
    end
    return output
end

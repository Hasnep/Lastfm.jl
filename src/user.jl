using JSON3
using HTTP
using DataFrames
using Dates

export user_get_friends
export user_get_info
export user_get_loved_tracks
export user_get_personal_artist_tags
export user_get_personal_album_tags
export user_get_personal_track_tags
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
    function user_get_friends(username::String; recenttracks::Bool, )::DataFrame

Get a list of the user's friends on Last.fm.
"""
function user_get_friends(username::String)::Vector{User}
    uri::HTTP.URI = get_uri("user.getFriends", user = username)
    response::HTTP.Response = get_response(uri)
    friends = JSON3.read(String(response.body))[:friends][:user]
    return [
        User(
            username = parse_string(friend_info[:name]),
            bootstrap = parse_bool(friend_info[:bootstrap]),
            country = parse_string(friend_info[:country]),
            images = parse_images(friend_info[:image]),
            playcount = parse_integer(friend_info[:playcount]),
            playlists = parse_integer(friend_info[:playlists]),
            real_name = parse_string(friend_info[:realname]),
            registered = parse_unix_timestamp(friend_info[:registered][:unixtime]),
            subscriber = parse_string(friend_info[:subscriber]),
            type = parse_string(friend_info[:type]),
            url = parse_url(friend_info[:url]),
        ) for friend_info in friends
    ]
end

"""
    function user_get_info(username::String)::User

Get information about a user profile.
"""
function user_get_info(username::String)::User
    uri::HTTP.URI = get_uri("user.getInfo", user = username)
    response::HTTP.Response = get_response(uri)
    user_info = JSON3.read(String(response.body))[:user]
    return User(
        username = parse_string(user_info[:name]),
        age = parse_integer(user_info[:age]),
        bootstrap = parse_bool(user_info[:bootstrap]),
        country = parse_string(user_info[:country]),
        gender = parse_string(user_info[:gender]),
        images = parse_images(user_info[:image]),
        playcount = parse_integer(user_info[:playcount]),
        playlists = parse_integer(user_info[:playlists]),
        real_name = parse_string(user_info[:realname]),
        registered = parse_unix_timestamp(user_info[:registered][:unixtime]),
        subscriber = parse_string(user_info[:subscriber]),
        type = parse_string(user_info[:type]),
        url = parse_url(user_info[:url]),
    )
end

"""
    function user_get_loved_tracks(username::String; )::DataFrame

Get the last 50 tracks loved by a user.
"""
function user_get_loved_tracks(username::String)::Vector{Track}
    uri::HTTP.URI = get_uri("user.getLovedTracks", user = username)
    response::HTTP.Response = get_response(uri)
    loved_tracks = JSON3.read(String(response.body))[:lovedtracks][:track]
    return [
        Track(
            track = loved_track[:name],
            mbid = loved_track[:mbid],
            loved_date = parse_unix_timestamp(loved_track[:date][:uts]),
            images = parse_images(loved_track[:image]),
            artist = Artist(
                artist = loved_track[:artist][:name],
                mbid = loved_track[:artist][:mbid],
                url = parse_url(loved_track[:artist][:url]),
            ),
            url = parse_url(loved_track[:url]),
        ) for loved_track in loved_tracks
    ]
end



"""
    function user_get_personal_artist_tags(username::String, tag::String; )::DataFrame

Get the user's personal tags for artists.
"""
function user_get_personal_artist_tags(username::String, tag::String)::Vector{Artist}
    uri::HTTP.URI = get_uri("user.getPersonalTags", user = username, tag = tag, taggingtype = "artist")
    response::HTTP.Response = get_response(uri)
    artist_tags = JSON3.read(String(response.body))[:taggings][:artists][:artist]
    return [
        Artist(
            artist = parse_string(artist_tag[:name]),
            mbid = parse_string(artist_tag[:mbid]),
            images = parse_images(artist_tag[:image]),
            url = parse_url(artist_tag[:url]),
        ) for artist_tag in artist_tags
    ]
end

"""
    function user_get_personal_album_tags(username::String, tag::String; )::DataFrame

Get the user's personal tags for albums.
"""
function user_get_personal_album_tags(username::String, tag::String)::Vector{Album}
    uri::HTTP.URI = get_uri("user.getPersonalTags", user = username, tag = tag, taggingtype = "album")
    response::HTTP.Response = get_response(uri)
    album_tags = JSON3.read(String(response.body))[:taggings][:albums][:album]
    return [
        Album(
            album = parse_string(album_tag[:name]),
            mbid = parse_string(album_tag[:mbid]),
            images = parse_images(album_tag[:image]),
            artist = Artist(
                artist = parse_string(album_tag[:artist][:name]),
                mbid = parse_string(album_tag[:artist][:mbid]),
                url = parse_url(album_tag[:artist][:url]),
            ),
        ) for album_tag in album_tags
    ]
end

"""
    function user_get_personal_track_tags(username::String, tag::String; )::DataFrame

Get the user's personal tags for tracks.
"""
function user_get_personal_track_tags(username::String, tag::String)::Vector{Track}
    uri::HTTP.URI = get_uri("user.getPersonalTags", user = username, tag = tag, taggingtype = "track")
    response::HTTP.Response = get_response(uri)
    track_tags = JSON3.read(String(response.body))[:taggings][:tracks][:track]
    return [
        Track(
            track = parse_string(track_tag[:name]),
            duration = (track_tag[:duration] == "FIXME") ? missing : Dates.second(parse_integer(track_tag[:duration])),
            mbid = parse_string(track_tag[:mbid]),
            url = parse_url(track_tag[:url]),
            images = parse_images(track_tag[:image]),
            artist = Artist(
                artist = parse_string(track_tag[:artist][:name]),
                mbid = parse_string(track_tag[:artist][:mbid]),
                url = parse_url(track_tag[:artist][:url]),
            ),
        ) for track_tag in track_tags
    ]

end

"""
    function user_get_recent_tracks(username::String)::DataFrame

Get a list of the recent tracks listened to by this user. Also includes the currently playing track with the nowplaying=true attribute if the user is currently listening.
"""
function user_get_recent_tracks(username::String)::Vector{Track}
    # TODO: get nowplaying = true/false
    uri::HTTP.URI = get_uri("user.getRecentTracks", user = username, nowplaying = true)
    response::HTTP.Response = get_response(uri)
    recent_tracks = JSON3.read(String(response.body))[:recenttracks][:track]
    return [
        Track(
            track = parse_string(recent_track[:name]),
            artist = Artist(artist = recent_track[:artist][Symbol("#text")], mbid = recent_track[:artist][:mbid]),
            album = Album(
                album = recent_track[:album][Symbol("#text")],
                mbid = recent_track[:album][:mbid],
                artist = Artist(artist = recent_track[:artist][Symbol("#text")], mbid = recent_track[:artist][:mbid]),
            ),
            images = parse_images(recent_track[:image]),
            date = haskey(recent_track, Symbol("@attr")) ? missing : parse_unix_timestamp(recent_track[:date][:uts]),
            url = parse_url(recent_track[:url]),
            mbid = parse_string(recent_track[:mbid]),
        ) for recent_track in recent_tracks
    ]
end

"""
    function user_get_top_albums(username::String; period::String = "overall", )::DataFrame

Get the top albums listened to by a user. You can stipulate a time period. Sends the overall chart by default.
"""
function user_get_top_albums(username::String; period::String = "overall")::Dict{Integer, Album}
    @assert period ∈ valid_periods "period must be one of '$(join(valid_periods, "', '", "' or '"))'."
    uri::HTTP.URI = get_uri("user.getTopAlbums", user = username)
    response::HTTP.Response = get_response(uri)
    top_albums = JSON3.read(String(response.body))["topalbums"]["album"]
    return Dict(
        parse_integer(top_album[Symbol("@attr")][:rank]) => Album(
            album = parse_string(top_album[:name]),
            artist = Artist(
                artist = parse_string(top_album[:artist][:name]),
                mbid = parse_string(top_album[:artist][:mbid]),
                url = parse_url(top_album[:artist][:url]),
            ),
            images = parse_images(top_album[:image]),
            user_playcount = parse_integer(top_album[:playcount]),
            url = parse_url(top_album[:url]),
            mbid = parse_string(top_album[:mbid]),
        ) for top_album in top_albums
    )
end

"""
    function user_get_top_artists(username::String; period::String = "overall")::DataFrame

Get the top artists listened to by a user. You can stipulate a time period. Sends the overall chart by default.
"""
function user_get_top_artists(username::String; period::String = "overall")::Dict{Integer, Artist}
    @assert period ∈ valid_periods "period must be one of '$(join(valid_periods, "', '", "' or '"))'."
    uri::HTTP.URI = get_uri("user.getTopArtists", user = username)
    response::HTTP.Response = get_response(uri)
    top_artists = JSON3.read(String(response.body))[:topartists][:artist]
    return Dict(
        parse_integer(top_artist[Symbol("@attr")][:rank]) => Artist(
            artist = parse_string(top_artist[:name]),
            mbid = parse_string(top_artist[:mbid]),
            url = parse_url(top_artist[:url]),
            user_playcount = parse_integer(top_artist[:playcount]),
            images = parse_images(top_artist[:image]),
        ) for top_artist in top_artists
    )
end

"""
    function user_get_top_tags(username::String; limit::Integer = 50)::DataFrame

Get the top tags used by this user.
"""
function user_get_top_tags(username::String; limit::Integer = 50)::Dict{Tag, Integer}
    uri::HTTP.URI = get_uri("user.getTopTags", user = username)
    response::HTTP.Response = get_response(uri)
    top_tags = JSON3.read(String(response.body))[:toptags][:tag]
    return Dict(
        Tag(tag = parse_string(top_tag[:name]), url = parse_url(top_tag[:url])) => parse_integer(top_tag[:count])
        for top_tag in top_tags
    )
end

"""
    function user_get_top_tracks(username::String; period::String = "overall", limit::Int = 50, page::Integer = 1)::DataFrame

Get the top tracks listened to by a user. You can stipulate a time period. Sends the overall chart by default.
"""
function user_get_top_tracks(username::String; period::String = "overall")::Dict{Integer, Track}
    @assert period ∈ valid_periods "period must be one of '$(join(valid_periods, "', '", "' or '"))'."
    uri::HTTP.URI = get_uri("user.getTopTracks", user = username)
    response::HTTP.Response = get_response(uri)
    top_tracks = JSON3.read(String(response.body))[:toptracks][:track]
    return Dict(
        parse_integer(top_track[Symbol("@attr")][:rank]) => Track(
            track = parse_string(top_track[:name]),
            artist = Artist(
                artist = parse_string(top_track[:artist][:name]),
                mbid = parse_string(top_track[:artist][:mbid]),
                url = parse_url(top_track[:artist][:url]),
            ),
            user_playcount = parse_integer(top_track[:playcount]),
            duration = Dates.Second(parse_integer(top_track[:duration])),
            images = parse_images(top_track[:image]),
            mbid = parse_string(top_track[:mbid]),
            url = parse_url(top_track[:url]),
        ) for top_track in top_tracks
    )
end

"""
    function user_get_weekly_album_chart(username::String)::DataFrame

Get an album chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent album chart for this user.
"""
function user_get_weekly_album_chart(
    username::String;
    from::Union{Date, Missing} = missing,
    to::Union{Date, Missing} = missing,
)::Dict{Integer, Album}
    uri::HTTP.URI = get_uri("user.getWeeklyAlbumChart", user = username)
    response::HTTP.Response = get_response(uri)
    weekly_album_charts = JSON3.read(String(response.body))[:weeklyalbumchart][:album]
    return Dict(
        parse_integer(album_chart[Symbol("@attr")][:rank]) => Album(
            album = parse_string(album_chart[:name]),
            artist = Artist(
                artist = parse_string(album_chart[:artist][Symbol("#text")]),
                mbid = parse_string(album_chart[:artist][:mbid]),
            ),
            mbid = parse_string(album_chart[:mbid]),
            user_playcount = parse_integer(album_chart[:playcount]),
            url = parse_url(album_chart[:url]),
        ) for album_chart in weekly_album_charts
    )
end

user_get_weekly_album_chart(username::String, chart::Chart)::Dict{Integer, Album} =
    user_get_weekly_album_chart(username; from = chart.from, to = chart.to)

"""
    function user_get_weekly_artist_chart(username::String; from::Date, to::Date)::DataFrame

Get an artist chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent artist chart for this user.
"""
function user_get_weekly_artist_chart(
    username::String;
    from::Union{Date, Missing} = missing,
    to::Union{Date, Missing} = missing,
)::Dict{Integer, Artist}
    uri::HTTP.URI = get_uri("user.getWeeklyArtistChart", user = username)
    response::HTTP.Response = get_response(uri)
    weekly_artist_charts = JSON3.read(String(response.body))[:weeklyartistchart][:artist]
    return Dict(
        parse_integer(artist_chart[Symbol("@attr")][:rank]) => Artist(
            artist = parse_string(artist_chart[:name]),
            user_playcount = parse_integer(artist_chart[:playcount]),
            mbid = parse_string(artist_chart[:mbid]),
            url = parse_url(artist_chart[:url]),
        ) for artist_chart in weekly_artist_charts
    )
end

user_get_weekly_artist_chart(username::String, chart::Chart)::Dict{Integer, Artist} =
    user_get_weekly_artist_chart(username; from = chart.from, to = chart.to)


"""
    function user_get_weekly_chart_list(username::String)::DataFrame

Get a list of available charts for this user, expressed as date ranges which can be sent to the chart services.
"""
function user_get_weekly_chart_list(username::String)::Vector{Chart}
    uri::HTTP.URI = get_uri("user.getWeeklyChartList", user = username)
    response::HTTP.Response = get_response(uri)
    charts = JSON3.read(String(response.body))[:weeklychartlist][:chart]
    return [
        Chart(from = parse_core_data_timestamp(chart[:from]), to = parse_core_data_timestamp(chart[:to]))
        for chart in charts
    ]
end

"""
    function user_get_weekly_track_chart(username::String; from::Date, to::Date)::DataFrame

Get a track chart for a user profile, for a given date range. If no date range is supplied, it will return the most recent track chart for this user.

* `username` The name of the Last.fm user to fetch the track chart of
* `from` (Optional) : The date at which the chart should start from. See User.getWeeklyChartList for more.
* `to` (Optional) : The date at which the chart should end on. See User.getWeeklyChartList for more.
"""
function user_get_weekly_track_chart(
    username::String;
    from::Union{Date, Missing} = missing,
    to::Union{Date, Missing} = missing,
)::Dict{Integer, Track}
    uri::HTTP.URI = get_uri("user.getWeeklyTrackChart", user = username)
    response::HTTP.Response = get_response(uri)
    weekly_track_charts = JSON3.read(String(response.body))[:weeklytrackchart][:track]
    return Dict(
        parse_integer(track_chart[Symbol("@attr")][:rank]) => Track(
            track = parse_string(track_chart[:name]),
            mbid = parse_string(track_chart[:mbid]),
            artist = Artist(
                artist = parse_string(track_chart[:artist][Symbol("#text")]),
                mbid = parse_string(track_chart[:artist][:mbid]),
            ),
            images = parse_images(track_chart[:image]),
            user_playcount = parse_integer(track_chart[:playcount]),
        ) for track_chart in weekly_track_charts
    )
end

user_get_weekly_track_chart(username::String, chart::Chart)::Dict{Integer, Track} =
    user_get_weekly_track_chart(username; from = chart.from, to = chart.to)

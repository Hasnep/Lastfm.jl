export album_get_info
export album_get_tags
export album_get_top_tags
export album_search

"""
Get the metadata and tracklist for an album on Last.fm using the album name or a musicbrainz id.

album (Required (unless mbid)] : The album name
artist (Required (unless mbid)] : The artist name
mbid (Optional) : The musicbrainz id for the album
autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
username (Optional) : The username for the context of the request. If supplied, the user's playcount for this album is included in the response.
lang (Optional) : The language to return the biography in, expressed as an ISO 639 alpha-2 code.
api_key (Required) : A Last.fm API key.
"""
function album_get_info(album::String, artist::String)# ::DataFrame
    uri::HTTP.URI = get_uri("album.getInfo", album = album, artist = artist)
    response::HTTP.Response = get_response(uri)
    album_info = JSON3.read(String(response.body))[:album]
    output::DataFrame = DataFrame(
        album = parse_string(album_info[:name]),
        artist = parse_string(album_info[:artist]),
        url = parse_string(album_info[:url]),
        listeners = parse_integer(album_info[:listeners]),
        playcount = parse_integer(album_info[:playcount]),
        # tracks = [parse_string(track["name"]) for track in album_info[:tracks][:track]],
        # tags = [parse_string(tag["name"]) for tag in album_info[:tags][:tag]],
    )
    return output
end

"""
Get the tags applied by an individual user to an album on Last.fm. To retrieve the list of top tags applied to an album by all users use album.getTopTags.

artist (Required (unless mbid)] : The artist name
album (Required (unless mbid)] : The album name
mbid (Optional) : The musicbrainz id for the album
autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
user (Optional) : If called in non-authenticated mode you must specify the user to look up
"""
function album_get_tags(album::String, artist::String, username::String)::DataFrame
    uri::HTTP.URI = get_uri("album.getTags", album = album, artist = artist, user = username)
    response::HTTP.Response = get_response(uri)
    album_tags = JSON3.read(String(response.body))[:tags][:tag]
    output::DataFrame = DataFrame(tag = String[], url = String[])
    for album_tag in album_tags
        album_tag_flattened = Dict(:tag => parse_string(album_tag["name"]), :url => parse_string(album_tag["url"]))
        push!(output, album_tag_flattened)
    end
    return output
end

"""
Get the top tags for an album on Last.fm, ordered by popularity.

artist (Required (unless mbid)] : The artist name
album (Required (unless mbid)] : The album name
autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
mbid (Optional) : The musicbrainz id for the album
api_key (Required) : A Last.fm API key.
"""
function album_get_top_tags(album::String, artist::String)::DataFrame
    uri::HTTP.URI = get_uri("album.getTopTags", album = album, artist = artist)
    response::HTTP.Response = get_response(uri)
    album_top_tags = JSON3.read(String(response.body))[:toptags][:tag]
    output::DataFrame = DataFrame(count = Integer[], tag = String[], url = String[])
    for album_top_tag in album_top_tags
        album_top_tag_flattened = Dict(
            :count => album_top_tag["count"],
            :tag => parse_string(album_top_tag["name"]),
            :url => parse_string(album_top_tag["url"]),
        )
        push!(output, album_top_tag_flattened)
    end
    return output
end


"""
Search for an album by name. Returns album matches sorted by relevance.

limit (Optional) : The number of results to fetch per page. Defaults to 30.
page (Optional) : The page number to fetch. Defaults to first page.
album (Required) : The album name
api_key (Required) : A Last.fm API key.
"""
function album_search(album::String)::DataFrame
    uri::HTTP.URI = get_uri("album.search", album = album)
    response::HTTP.Response = get_response(uri)
    search_results = JSON3.read(String(response.body))[:results][:albummatches][:album]
    output::DataFrame = DataFrame(album = String[], artist = String[], url = String[], mbid = String[])
    for search_result in search_results
        search_result_flattened = Dict(
            :album => parse_string(search_result["name"]),
            :artist => parse_string(search_result["artist"]),
            :url => parse_string(search_result["url"]),
            :mbid => parse_string(search_result["mbid"]),
        )
        push!(output, search_result_flattened)
    end
    return output
end

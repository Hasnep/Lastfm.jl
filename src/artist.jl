using JSON3
using HTTP
using DataFrames
using Dates

export artist_get_correction
export artist_get_info
export artist_get_similar
export artist_get_tags
export artist_get_top_albums
export artist_get_top_tags
export artist_get_top_tracks

"""
    function artist_get_correction()::DataFrame

Use the last.fm corrections data to check whether the supplied artist has a correction to a canonical artist

* artist: The artist name to correct.
"""
function artist_get_correction(artist::String)::DataFrame
    uri::HTTP.URI = get_uri("artist.getCorrection", artist = artist)
    response::HTTP.Response = get_response(uri)
    artist_correction =
        JSON3.read(String(response.body))["corrections"]["correction"]["artist"]
    output::DataFrame = DataFrame(
        artist = String[artist_correction["name"]],
        mbid = String[artist_correction["mbid"]],
        url = String[artist_correction["url"]],
    )
    return output
end

"""
    function artist_get_Info()::DataFrame

Get the metadata for an artist. Includes biography, truncated at 300 characters.

* artist (Required (unless mbid)] : The artist name
* mbid (Optional) : The musicbrainz id for the artist
* autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
* lang (Optional) : The language to return the biography in, expressed as an ISO 639 alpha-2 code.
* username (Optional) : The username for the context of the request. If supplied, the user's playcount for this artist is included in the response.
"""
function artist_get_info(
    artist::String;
    autocorrect::Bool = false, # TODO: Find out if this is on or off by default
    lang::String = "eng",
    username::String = "",
)::DataFrame
    uri::HTTP.URI = get_uri("artist.getInfo", artist = artist)
    response::HTTP.Response = get_response(uri)
    artist_info = JSON3.read(String(response.body))["artist"]
    output::DataFrame = DataFrame(
        artist = String[parse_string(artist_info["name"])],
        bio = String[parse_string(artist_info["bio"]["content"])],
        listeners = Integer[parse_integer(artist_info["stats"]["listeners"])],
        on_tour = Bool[parse_bool(artist_info["ontour"])],
        playcount = Integer[parse_integer(artist_info["stats"]["playcount"])],
        similar = Array{String}[[
            parse_string(artist["name"]) for artist in artist_info["similar"]["artist"]
        ]],
        summary = String[parse_string(artist_info["bio"]["summary"])],
        tags = Array{String}[[
            parse_string(tag["name"]) for tag in artist_info["tags"]["tag"]
        ]],
    )

    return output
end

"""
    function artist_get_similar()::DataFrame

Get all the artists similar to this artist

* artist (Required (unless mbid)] : The artist name
* limit (Optional) : Limit the number of similar artists returned
* autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
* mbid (Optional) : The musicbrainz id for the artist
"""
function artist_get_similar(artist::String)::DataFrame
    uri::HTTP.URI = get_uri("artist.getSimilar", artist = artist)
    response::HTTP.Response = get_response(uri)
    artist_similar_artists = JSON3.read(String(response.body))["similarartists"]["artist"]
    output::DataFrame =
        DataFrame(artist = String[], mbid = String[], match = Float64[], url = String[])
    for artist_similar_artist in artist_similar_artists
        artist_similar_artist_flattened = Dict(
            :artist => parse_string(artist_similar_artist["name"]),
            :mbid => parse_string(artist_similar_artist["mbid"]),
            :match => parse_float(artist_similar_artist["match"]),
            :url => parse_string(artist_similar_artist["url"]),
        )
        push!(output, artist_similar_artist_flattened)
    end
    return output
end

"""
    function artist_get_tags()::DataFrame

Get the tags applied by an individual user to an artist on Last.fm. If accessed as an authenticated service /and/ you don't supply a user parameter then this service will return tags for the authenticated user. To retrieve the list of top tags applied to an artist by all users use artist.getTopTags.

* artist (Required (unless mbid)] : The artist name
* username (Optional) : If called in non-authenticated mode you must specify the user to look up
* mbid (Optional) : The musicbrainz id for the artist
* autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
"""
function artist_get_tags(artist::String; username::String)::DataFrame
    uri::HTTP.URI = get_uri("artist.getTags", artist = artist, user = username)
    response::HTTP.Response = get_response(uri)
    artist_tags = JSON3.read(String(response.body))
    # @info artist_tags
    output::DataFrame = DataFrame()
    # for artist_tag in artist_tags
    #     artist_tag_flattened = Dict()
    #     push!(output, artist_tag_flattened)
    # end
    return output
end

"""
    function artist_get_top_albums()::DataFrame

Get the top albums for an artist on Last.fm, ordered by popularity.

* artist (Required (unless mbid)] : The artist name
* mbid (Optional) : The musicbrainz id for the artist
* autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
* page (Optional) : The page number to fetch. Defaults to first page.
* limit (Optional) : The number of results to fetch per page. Defaults to 50.
"""
function artist_get_top_albums(artist::String)::DataFrame
    uri::HTTP.URI = get_uri("artist.getTopAlbums", artist = artist)
    response::HTTP.Response = get_response(uri)
    top_albums = JSON3.read(String(response.body))["topalbums"]["album"]
    output::DataFrame =
        DataFrame(album = String[], playcount = Integer[], artist = String[])
    for top_album in top_albums
        top_album_flattened = Dict(
            :album => parse_string(top_album["name"]),
            :playcount => top_album["playcount"],
            :artist => parse_string(top_album["artist"]["name"]),
        )
        push!(output, top_album_flattened)
    end
    return output
end

"""
    function artist_get_top_tags(artist::String; autocorrect::Bool = 0)::DataFrame

Get the top tags for an artist on Last.fm, ordered by popularity.

* artist (Required (unless mbid)] : The artist name
* mbid (Optional) : The musicbrainz id for the artist
* autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response. # TODO: find out the default value
"""
function artist_get_top_tags(artist::String; autocorrect::Bool = false)::DataFrame
    uri::HTTP.URI = get_uri("artist.getTopTags", artist = artist)
    response::HTTP.Response = get_response(uri)
    top_tags = JSON3.read(String(response.body))["toptags"]
    output::DataFrame = DataFrame(artist = String[], tag = String[], weight = Integer[])
    for top_tag in top_tags["tag"]
        top_tag_flattened = Dict(
            :artist => parse_string(top_tags["@attr"]["artist"]),
            :tag => parse_string(top_tag["name"]),
            :weight => top_tag["count"],
        )
        push!(output, top_tag_flattened)
    end
    return output
end

"""
    function artist_get_topTracks()::DataFrame

Get the top tracks by an artist on Last.fm, ordered by popularity

* artist (Required (unless mbid)] : The artist name
* mbid (Optional) : The musicbrainz id for the artist
* autocorrect[0|1] (Optional) : Transform misspelled artist names into correct artist names, returning the correct version instead. The corrected artist name will be returned in the response.
* page (Optional) : The page number to fetch. Defaults to first page.
* limit (Optional) : The number of results to fetch per page. Defaults to 50.
"""
function artist_get_top_tracks(artist::String)::DataFrame
    uri::HTTP.URI = get_uri("artist.getTopTracks", artist = artist)
    response::HTTP.Response = get_response(uri)
    top_tracks = JSON3.read(String(response.body))["toptracks"]["track"]
    output::DataFrame = DataFrame(
        rank = Integer[],
        track = String[],
        artist = String[],
        listeners = Integer[],
        playcount = Integer[],
    )
    for top_track in top_tracks
        top_track_flattened = Dict(
            :rank => parse_integer(top_track["@attr"]["rank"]),
            :track => parse_string(top_track["name"]),
            :artist => parse_string(top_track["artist"]["name"]),
            :listeners => parse_integer(top_track["listeners"]),
            :playcount => parse_integer(top_track["playcount"]),
        )
        push!(output, top_track_flattened)
    end
    return output
end

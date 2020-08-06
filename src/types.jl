using Dates
using HTTP

export Album
export AlbumTag
export Artist
export ArtistTag
export Bio
export Chart
export Images
export Tag
export Track
export TrackTag
export User

Base.@kwdef struct Bio
    content::String
    publish_date::DateTime
    summary::String
    url::HTTP.URI
end

Base.@kwdef struct Images
    small::Union{HTTP.URI, Missing} = missing
    medium::Union{HTTP.URI, Missing} = missing
    large::Union{HTTP.URI, Missing} = missing
    extralarge::Union{HTTP.URI, Missing} = missing
    mega::Union{HTTP.URI, Missing} = missing
end

Base.@kwdef struct ArtistTag
    tag::String
    tag_url::Union{HTTP.URI, Missing} = missing
end

ArtistTag(tag::String, tag_url::String) = ArtistTag(tag = tag, tag_url = parse_url(tag_url))

Base.@kwdef struct Artist
    artist::String
    bio::Union{Bio, Missing} = missing
    images::Union{Images, Missing} = missing
    listeners::Union{Integer, Missing} = missing
    match::Union{Number, Missing} = missing
    mbid::Union{String, Missing} = missing
    on_tour::Union{Bool, Missing} = missing
    playcount::Union{Integer, Missing} = missing
    similar::Union{Vector{Artist}, Missing} = missing
    streamable::Union{Bool, Missing} = missing
    tags::Union{Vector{ArtistTag}, Missing} = missing
    url::Union{HTTP.URI, Missing} = missing
    user_playcount::Union{Missing, Integer} = missing
end

Base.@kwdef struct Album
    album::String
    mbid::String
    artist::Artist
    images::Union{Images, Missing} = missing
    url::Union{HTTP.URI, Missing} = missing
    user_playcount::Union{Missing, Integer} = missing
end

Base.@kwdef struct Track
    track::String
    mbid::String
    images::Images
    artist::Artist
    date::Union{DateTime, Missing} = missing
    url::Union{HTTP.URI, Missing} = missing
    duration::Union{Dates.Second, Missing} = missing
    loved_date::Union{DateTime, Missing} = missing
    album::Union{Album, Missing} = missing
    listeners::Union{Integer, Missing} = missing
    user_playcount::Union{Integer, Missing} = missing
end

Base.@kwdef struct Tag
    tag::String
    url::HTTP.URI
end

Base.@kwdef struct TrackTag
    tag::String
    track::Track
    artist::Artist
end

Base.@kwdef struct AlbumTag
    tag::Any
    album::Any
    artist::Any
    album_mbid::Any
    album_url::Any
    artist_mbid::Any
    artist_url::Any
end

Base.@kwdef struct User
    username::String
    age::Union{Integer, Missing} = missing
    bootstrap::Bool
    country::String
    gender::Union{String, Missing} = missing
    images::Images
    playcount::Integer
    playlists::Integer
    real_name::String
    registered::DateTime
    subscriber::String
    type::String
    url::HTTP.URI
end

Base.@kwdef struct Chart
    from::Date
    to::Date
end

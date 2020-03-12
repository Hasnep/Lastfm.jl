using HTTP

"""
converts args to uri
"""
function get_uri(method::String; kwargs...)::HTTP.URI
    @assert haskey(ENV, "LASTFMAUTH") "Last.fm key not defined, use authenticate_lastfm() to authenticate"
    query::Dict{Symbol, Union{String, Integer}} =
        Dict(:method => method, :api_key => ENV["LASTFMAUTH"], :format => "json", kwargs...)
    uri::HTTP.URI = HTTP.URI(; scheme = "https", host = "ws.audioscrobbler.com/2.0", path = "/", query = query)
    return uri
end

"""
posts a get response
"""
function get_response(uri::HTTP.URI)::HTTP.Response
    url::String = string(uri)
    # @info "Getting the url at " * url
    response::HTTP.Response = HTTP.get(url)
    if response.status == 200
        return response
    else
        error("Last.fm API returned error $(response.status): $(error_codes[response.status])")
    end
end

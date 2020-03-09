export authenticate_lastfm

function authenticate_lastfm(key::String)::Nothing
    ENV["LASTFMAUTH"] = key
    return nothing
end

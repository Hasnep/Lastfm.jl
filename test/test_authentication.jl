using Test
using Lastfm

if haskey(ENV, "LASTFM_KEY")
    @info "Last.fm environment variable found."
else
    @info "Last.fm environment variable not found, reading from .env file."
    using DotEnv
    DotEnv.config()
    if !haskey(ENV, "LASTFM_KEY")
        KeyError("Last.fm key not found in .env file.")
    end
end

@testset "Test authentication functions" begin
    @test authenticate_lastfm(ENV["LASTFM_KEY"]) isa Nothing
    @test haskey(ENV, "LASTFMAUTH")
end

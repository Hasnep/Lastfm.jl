using Test
using Lastfm

@testset "Test authentication functions" begin
    @test authenticate_lastfm(ENV["LASTFM_KEY"]) isa Nothing
    @test ENV["LASTFMAUTH"] isa String
end

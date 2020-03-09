using Test
using Lastfm
using DataFrames

artist_test = "Red Hot Chili Peppers"

authenticate_lastfm(ENV["LASTFM_KEY"])

@testset "Test artist functions" begin
    @test artist_get_correction(artist_test) isa DataFrame
    @test artist_get_info(artist_test) isa DataFrame
    @test artist_get_similar(artist_test) isa DataFrame
    @test artist_get_tags(artist_test, username = "Hasnep") isa DataFrame
    @test artist_get_top_albums(artist_test) isa DataFrame
    @test artist_get_top_tags(artist_test) isa DataFrame
    @test artist_get_top_tracks(artist_test) isa DataFrame
end

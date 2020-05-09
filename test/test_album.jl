using Test
using Lastfm
using DataFrames

album_test = "The Hanging Gardens of Beatenberg"
artist_test = "Beatenberg"
username_test = "Hasnep"

authenticate_lastfm(ENV["LASTFM_KEY"])

@testset "Test artist functions" begin
    @test album_get_info(album_test, artist_test) isa DataFrame
    @test album_get_tags(album_test, artist_test, username_test) isa DataFrame
    @test album_get_top_tags(album_test, artist_test) isa DataFrame
    @test album_search(album_test) isa DataFrame
end

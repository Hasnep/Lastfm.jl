using Test
using Lastfm
using DataFrames

username_test = "Hasnep"

authenticate_lastfm(ENV["LASTFM_KEY"])

@testset "Test user functions" begin
    @test user_get_friends(username_test) isa DataFrame
    @test user_get_info(username_test) isa DataFrame
    @test user_get_loved_tracks(username_test) isa DataFrame
    @test_skip user_get_personal_tags(username_test, "rock", "track") isa DataFrame
    @test user_get_recent_tracks(username_test) isa DataFrame
    @test user_get_top_albums(username_test) isa DataFrame
    @test user_get_top_artists(username_test) isa DataFrame
    @test_skip user_get_top_tags(username_test) isa DataFrame
    @test_skip user_get_top_tracks(username_test) isa DataFrame
    @test_skip user_get_weekly_album_chart(username_test) isa DataFrame
    @test_skip user_get_weekly_artist_chart(username_test) isa DataFrame
    @test_skip user_get_weekly_chart_list(username_test) isa DataFrame
    @test_skip user_get_weekly_track_chart(username_test) isa DataFrame
end

using Test
using Lastfm

username_test = "Hasnep"

@testset "Test user_get_* functions" begin
    @test user_get_friends(username_test) isa Vector{User}
    @test user_get_info(username_test) isa User
    @test user_get_loved_tracks(username_test) isa Vector{Track}
    @testset "Test user_get_personal_*_tags functions" begin
        @test user_get_personal_artist_tags(username_test, "indie") isa Vector{Artist}
        @test user_get_personal_album_tags(username_test, "indie") isa Vector{Album}
        @test user_get_personal_track_tags(username_test, "indie") isa Vector{Track}
    end
    @test user_get_recent_tracks(username_test) isa Vector{Track}
    @test user_get_top_albums(username_test) isa Dict{Integer, Album}
    @test user_get_top_artists(username_test) isa Dict{Integer, Artist}
    @test user_get_top_tags(username_test) isa Dict{Tag, Integer}
    @test user_get_top_tracks(username_test) isa Dict{Integer, Track}
    @testset "Test user_*_chart functions" begin
        chart_list = user_get_weekly_chart_list(username_test)
        @test chart_list isa Vector{Chart}
        @testset "Test user_get_weekly_album_chart" begin
            @test user_get_weekly_album_chart(username_test) isa Dict{Integer, Album}
            @test user_get_weekly_album_chart(username_test, chart_list[1]) isa Dict{Integer, Album}
        end
        @testset "Test user_get_weekly_track_chart" begin
            @test user_get_weekly_artist_chart(username_test) isa Dict{Integer, Artist}
            @test user_get_weekly_artist_chart(username_test, chart_list[1]) isa Dict{Integer, Artist}
        end
        @testset "Test user_get_weekly_track_chart" begin
            @test user_get_weekly_track_chart(username_test) isa Dict{Integer, Track}
            @test user_get_weekly_track_chart(username_test, chart_list[1]) isa Dict{Integer, Track}
        end
    end
end

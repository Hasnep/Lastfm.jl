using Test
@testset "Test Lastfm.jl" begin
    include("test_authentication.jl")
    include("test_album.jl")
    include("test_artist.jl")
    include("test_user.jl")
    include("test_formatting.jl")
end

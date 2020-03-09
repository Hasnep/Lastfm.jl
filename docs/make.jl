push!(LOAD_PATH, "../src/")

using Documenter
using Lastfm

makedocs(sitename = "Lastfm.jl", modules = [Lastfm], authors = "Hannes")

deploydocs(repo = "github.com/hasnep/Lastfm.jl.git")

demo:
	julia --project="scripts" scripts/demo.jl

count:
	find src -name '*.jl' | xargs wc -l

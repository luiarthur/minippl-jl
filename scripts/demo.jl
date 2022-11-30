using Printf
import OrderedCollections: OrderedDict 
using Distributions
import PPL
import PPL: trace, condition, get
import Random: seed!

struct NormalModel end
function PPL.model(m::PPL.Model{NormalModel}; x)
    mu = PPL.rv(m, :mu, Normal(0, 1))
    sigma = PPL.rv(m, :sigma, Uniform(0, 1))
    PPL.rv(m, :x, Normal(mu, sigma), obs=x)
end
nm = PPL.Model{NormalModel}()
# Want to abbreviate the above to:
# @model function NormalModel(x)
#     mu = PPL.rv(:mu, Normal())
#     sigma = PPL.rv(:sigma, Uniform(0, 1))
#     PPL.rv(:x, Normal(mu, sigma), obs=x)
# end

seed!(0)
true_dist = Normal(3, 0.5)
x = rand(true_dist, 100)

t1 = get(trace(condition(nm, Dict(:mu => 0))), x = 10)
t2 = get(trace(condition(nm, Dict(:sigma => 0.01))),
         x = nothing)
t3 = get(trace(condition(nm, Dict(:mu => 11, :sigma => 0.01))),
         x = 10)

for (i, t) in enumerate([t1, t2,t3])
    d = Dict(
        name => msg.value
        for (name, msg) in t
    )
    println("$i: $d")
end

xs = rand(true_dist, 2000)
profile = OrderedDict(
    m => PPL.logpdf(
        nm,
        Dict(:mu => m, :sigma => 0.5),
        x = xs
    )
    for m in range(2, 4, 15)
)

for (m, lpdf) in profile
    @printf "m: %.3f | lpdf: %.3f\n" m lpdf
end

abstract type Handler end

"""
Methods to implement:
- `model(::Model{T}; kwargs...)`
"""
struct Model{T, R<:AbstractRNG}
    stack::Vector{Handler}
    rng::R
end
Model{T}(rng::R = GLOBAL_RNG) where {T, R} = Model{T, R}(Handler[], rng)

struct trace{
    F <: Union{<:Handler, <:Model},
    R <: Dict{Symbol, <:Any}
} <: Handler
    fn::F
    result::R
end
trace(fn) = trace(fn, Dict{Symbol, Any}())

struct condition{
    F <: Union{<:Handler, <:Model},
    S <: Dict{Symbol, <:Any}
} <: Handler
    fn::F
    substate::S
end

Base.@kwdef mutable struct Message{F, T <: Symbol}
    name::Symbol
    value
    fn::F = nothing
    type::T = :rv
    observed::Bool = false
end

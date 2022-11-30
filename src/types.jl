abstract type Handler end

"""
Methods to implement:
- `model(::Model{T}; kwargs...)`
"""
struct Model{T}
    _stack::Vector{Handler}
end
Model{T}() where T = Model{T}(Handler[])

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

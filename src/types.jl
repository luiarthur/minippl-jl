abstract type Handler end

"""
AbstractModel has 
- field:  _stack::Vector{Handler}
- method: model(; kwargs...)
"""
abstract type AbstractModel end

struct trace{
    F <: Union{<:Handler, <:AbstractModel},
    R <: Dict{Symbol, <:Any}
} <: Handler
    fn::F
    result::R
end
trace(fn) = trace(fn, Dict{Symbol, Any}())

struct condition{
    F <: Union{<:Handler, <:AbstractModel},
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

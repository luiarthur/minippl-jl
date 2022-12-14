model(::Model; kwargs...) = nothing
(m::Model)(; kwargs...) = model(m; kwargs...)
stack(m::Model) = m.stack

function apply_stack(m::Model, msg::Message)::Message
    for handler in reverse(m.stack)
        process(handler, msg)
    end

    isnothing(msg.value) && (msg.value = rand(msg.fn))

    for handler in m.stack
        postprocess(handler, msg)
    end

    return msg
end

function rv(m::Model, name::Symbol, dist::Distribution; obs = nothing)
    if length(m.stack) > 0
        msg = Message(
            name = name,
            fn = dist,
            value = obs,
            observed = !isnothing(obs)
        )
        return apply_stack(m, msg).value
    else
        return rand(dist)
    end
end

function Distributions.logpdf(
    m::Model,
    state::Dict{Symbol, <:Any};
    kwargs...
)
    t = get(trace(condition(m, state)); kwargs...)
    lp = 0.0
    for param in values(t)
        if param.type === :rv
            lp += sum(logpdf.(param.fn, param.value))
            if lp === -Inf
                return -Inf
            end
        end
    end
    return lp
end

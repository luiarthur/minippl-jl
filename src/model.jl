run(d::Distribution) = rand(d)

model(am::AbstractModel; kwargs...) = nothing

function run(am::AbstractModel; kwargs...)
    return model(am; kwargs...)
end

stack(am::AbstractModel) = am._stack

function apply_stack(am::AbstractModel, msg::Message)
    for handler in reverse(am._stack)
        process(handler, msg)
    end

    if isnothing(msg.value)
        msg.value = run(msg.fn)
    end

    for handler in am._stack
        postprocess(handler, msg)
    end

    return msg
end

function rv(am::AbstractModel,
            name::Symbol,
            dist::Distribution;
            obs = nothing)

    if length(am._stack) == 0
        return rand(dist)
    else
        msg = Message(
            name = name,
            fn = dist,
            value = obs,
            observed = !isnothing(obs)
        )
        msg = apply_stack(am, msg)
        return msg.value
    end
end

function Distributions.logpdf(am::AbstractModel, state::Dict{Symbol, <:Any}; kwargs...)
    t = get(trace(condition(am, state)); kwargs...)

    lp = 0.0
    for param in values(t)
        if param.type == :rv
            lp += sum(logpdf.(param.fn, param.value))
            if lp === -Inf
                return -Inf
            end
        end
    end
    return lp
end

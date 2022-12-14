# Handler methods.
stack(h::Handler) = stack(h.fn)
process(h::Handler, msg::Message) = nothing
postprocess(h::Handler, msg::Message) = nothing
function (h::Handler)(; kwargs...)
    push!(stack(h), h)
    result = h.fn(; kwargs...)
    @assert pop!(stack(h)) === h
    return result
end

# Trace methods.
postprocess(h::trace, msg::Message) = (h.result[msg.name] = msg)
function get(h::trace; kwargs...)
    h(; kwargs...)
    return h.result
end

# Condition methods.
function postprocess(h::condition, msg::Message)
    if haskey(h.substate, msg.name)
        msg.value = h.substate[msg.name]
    end
end

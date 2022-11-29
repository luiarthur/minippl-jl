# Handler methods.
stack(h::Handler) = stack(h.fn)
Base.push!(h::Handler) = push!(stack(h), h)
Base.pop!(h::Handler) = @assert pop!(stack(h)) === h
process(h::Handler, msg::Message) = nothing
postprocess(h::Handler, msg::Message) = nothing
function run(h::Handler; kwargs...)
    push!(h)
    result = run(h.fn; kwargs...)
    pop!(h)
    return result
end

# Trace methods.
function postprocess(h::trace, msg::Message)
    h.result[msg.name] = msg
end
function get(h::trace; kwargs...)
    run(h; kwargs...)
    return h.result
end

# Condition methods.
function postprocess(h::condition, msg::Message)
    if haskey(h.substate, msg.name)
        msg.value = h.substate[msg.name]
    end
end

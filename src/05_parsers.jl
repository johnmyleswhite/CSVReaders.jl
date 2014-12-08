@doc """
# Description

Parse a null value from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes.
* `sentinels`: A vector of sequences of bytes representing a null value.

# Returns

* `isnull::Bool`: Did the byte sequence represent a null value?
""" ->
function parsenull(bytes::Vector{Uint8}, sentinels::Vector{Vector{Uint8}})
    for sentinel in sentinels
        if bytes == sentinel
            return true
        end
    end
    return false
end

@doc """
# Description

Parse an integer from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::Int`: The Int value parsed if the parse succeeded.
* `success::Bool`: Was an Int value successfully parsed?
""" ->
function Base.parseint(bytes::Vector{Uint8})
    value = 0
    power = 1
    index = length(bytes)
    byte = bytes[index]

    while index > 1
        if uint8('0') <= byte <= uint8('9')
            value += (byte - uint8('0')) * power
            power *= 10
        else
            # Invalid digit error
            return value, false
        end
        index -= 1
        byte = bytes[index]
    end

    if byte == '-'
        return -value, true
    elseif byte == '+'
        return value, true
    elseif uint8('0') <= byte <= uint8('9')
        # Technically this should reject strings like "01"
        value += (byte - uint8('0')) * power
        return value, true
    else
        return value, false
    end
end

let out = Array(Float64, 1)
    @doc """
    # Description

    Parse a 64-bit floating point number from a sequence of bytes.

    # Arguments

    * `bytes::Vector{Uint8}`: A sequence of bytes

    # Returns

    * `value::Float64`: The Float64 value parsed if the parse succeeded.
    * `success::Bool`: Was a Float64 value successfully parsed?
    """ ->
    function Base.parsefloat(bytes::Vector{Uint8})
        success = ccall(
            :jl_substrtod,
            Int32,
            (Ptr{Uint8}, Csize_t, Int, Ptr{Float64}),
            bytes,
            convert(Csize_t, 0),
            length(bytes),
            out
        ) == 0
        return out[1], success
    end
end

@doc """
# Description

Parse a boolean value from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::Int`: The Bool value parsed if the parse succeeded.
* `success::Bool`: Was an Bool value successfully parsed?
""" ->
function parsebool(
    bytes::Vector{Uint8},
    trues::Vector{Vector{Uint8}},
    falses::Vector{Vector{Uint8}},
)
    for truebytes in trues
        if bytes == truebytes
            return true, true
        end
    end

    for falsebytes in falses
        if bytes == falsebytes
            return false, true
        end
    end

    return false, false
end

# TODO: Deal with re-encoding from Latin-1 to UTF-8
# TODO: Is this copy needed?
@doc """
# Description

Parse a UTF8String value from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::UTF8String`: The UTF8String value parsed if the parse succeeded.
* `success::Bool`: Was an UTF8String value successfully parsed?
""" ->
parsestring(bytes::Vector{Uint8}) = bytestring(copy(bytes))

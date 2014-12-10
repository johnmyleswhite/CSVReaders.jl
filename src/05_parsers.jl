@doc """
# Description

Parse a null value from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes.
* `sentinels`: A vector of sequences of bytes representing a null value.

# Returns

* `isnull::Bool`: Did the byte sequence represent a null value?
""" ->
function parsenull(
    bytes::Vector{Uint8},
    sentinels::Vector{Vector{Uint8}},
    defaults::Bool,
)
    if defaults
        n = length(bytes)
        if n == 2
            if bytes[1] == uint8('N') && bytes[2] == uint8('A')
                return true
            end
        elseif n == 4
            if bytes[1] == uint8('N') && bytes[2] == uint8('U') &&
              bytes[3] == uint8('L') && bytes[4] == uint8('L')
                return true
            end
        end
        return false
    else
        # TODO: Why does this cause allocation?
        for sentinel in sentinels
            if bytes == sentinel
                return true
            end
        end
        return false
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
    default_trues::Bool,
    default_falses::Bool,
)
    # TODO: Hardcode defaults here
    if default_trues
        if length(bytes) == 1
            if bytes[1] == uint8('t') || bytes[1] == uint8('T')
                return true, true
            end
        elseif length(bytes) == 4
            if (
                bytes[1] == uint8('t') &&
                bytes[2] == uint8('r') &&
                bytes[3] == uint8('u') &&
                bytes[4] == uint8('e')
            ) || (
                bytes[1] == uint8('T') &&
                bytes[2] == uint8('R') &&
                bytes[3] == uint8('U') &&
                bytes[4] == uint8('E')
            )
                return true, true
            end
        end
    else
        for truebytes in trues
            if bytes == truebytes
                return true, true
            end
        end
    end

    if default_falses
        if length(bytes) == 1
            if bytes[1] == uint8('f') || bytes[1] == uint8('F')
                return false, true
            end
        elseif length(bytes) == 5
            if (
                bytes[1] == uint8('f') &&
                bytes[2] == uint8('a') &&
                bytes[3] == uint8('l') &&
                bytes[4] == uint8('s') &&
                bytes[5] == uint8('e')
            ) || (
                bytes[1] == uint8('F') &&
                bytes[2] == uint8('A') &&
                bytes[3] == uint8('L') &&
                bytes[4] == uint8('S') &&
                bytes[5] == uint8('E')
            )
                return false, true
            end
        end
    else
        for falsebytes in falses
            if bytes == falsebytes
                return false, true
            end
        end
    end

    return false, false
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
    # TODO: Check for overflow
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

const out = Array(Float64, 1)
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

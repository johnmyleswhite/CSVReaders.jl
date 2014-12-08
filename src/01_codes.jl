module Codes
    const INT = 1
    const FLOAT = 2
    const BOOL = 3
    const STRING = 4
end

@doc """
# Description

Convert a code number to its equivalent Julia type

# Arguments

* `code::Int`: The numeric code for a type. Must be one of:
    * `Codes.INT`
    * `Codes.FLOAT`
    * `Codes.BOOL`
    * `Codes.STRING`

# Returns

* `type::DataType`: The Julia type corresponding to the input code number.
""" ->
function code2type(code::Int)
    if code == Codes.INT
        return Int64
    elseif code == Codes.FLOAT
        return Float64
    elseif code == Codes.BOOL
        return Bool
    elseif code == Codes.STRING
        return UTF8String
    else
        throw(DomainError())
    end
end

@doc """
# Description

Convert a Julia type to its equivalent code number

# Arguments

* `type::DataType`: A Julia type. Must be one of:
    * `Int64`
    * `Float64`
    * `Bool`
    * `UTF8String`

# Returns

* `code::Int`: The numeric code for the input type.
""" ->
type2code(::Type{Int64}) = Codes.INT
type2code(::Type{Float64}) = Codes.FLOAT
type2code(::Type{Bool}) = Codes.BOOL
type2code(::Type{UTF8String}) = Codes.STRING

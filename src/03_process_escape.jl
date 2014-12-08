@doc """
# Description

Given a CSVReader object and the sequence byte of a potential ASCII escape
sequence, insert the appropriate ASCII escape byte into the CSVReader's main
buffer.

# Arguments

* `reader::CSVReader`: A CSVReader object
* `byte::Uint8`: The second byte of a potential ASCII escape sequence

# Returns

* Void
""" ->
@inline function process_escape!(reader::CSVReader, byte::Uint8)
    if byte == convert(Uint8, '\\')
        push!(reader.main, convert(Uint8, '\\'))
    # TODO: Stop processing quote marks here?
    elseif byte == convert(Uint8, '\'')
        push!(reader.main, convert(Uint8, '\''))
    # TODO: Stop processing quote marks here?
    elseif byte == convert(Uint8, '"')
        push!(reader.main, convert(Uint8, '"'))
    elseif byte == convert(Uint8, 'n')
        push!(reader.main, convert(Uint8, '\n'))
    elseif byte == convert(Uint8, 't')
        push!(reader.main, convert(Uint8, '\t'))
    elseif byte == convert(Uint8, 'r')
        push!(reader.main, convert(Uint8, '\r'))
    elseif byte == convert(Uint8, 'a')
        push!(reader.main, convert(Uint8, '\a'))
    elseif byte == convert(Uint8, 'b')
        push!(reader.main, convert(Uint8, '\b'))
    elseif byte == convert(Uint8, 'f')
        push!(reader.main, convert(Uint8, '\f'))
    elseif byte == convert(Uint8, 'v')
        push!(reader.main, convert(Uint8, '\v'))
    else
        msg = IOBuffer()
        show(msg, bytestring(Uint8['\\', byte]))
        error(@sprintf("Invalid ASCII sequence: %s", takebuf_string(msg)))
    end
    return
end

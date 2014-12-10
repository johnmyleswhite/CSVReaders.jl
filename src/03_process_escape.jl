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
    # TODO: Stop processing quote marks here?
    if byte == convert(Uint8, '\'')
        push!(reader.main, convert(Uint8, '\''))
    # TODO: Stop processing quote marks here?
    elseif byte == convert(Uint8, '"')
        push!(reader.main, convert(Uint8, '"'))
    elseif byte == convert(Uint8, '\\')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\\'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, '\\'))
        end
    elseif byte == convert(Uint8, 'n')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\n'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 'n'))
        end
    elseif byte == convert(Uint8, 't')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\t'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 't'))
        end
    elseif byte == convert(Uint8, 'r')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\r'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 'r'))
        end
    elseif byte == convert(Uint8, 'a')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\a'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 'a'))
        end
    elseif byte == convert(Uint8, 'b')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\b'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 'b'))
        end
    elseif byte == convert(Uint8, 'f')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\f'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 'f'))
        end
    elseif byte == convert(Uint8, 'v')
        if reader.allow_escapes
            push!(reader.main, convert(Uint8, '\v'))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, convert(Uint8, 'v'))
        end
    else
        if reader.allow_escapes
            msg = IOBuffer()
            show(msg, bytestring(Uint8['\\', byte]))
            error(@sprintf("Invalid ASCII sequence: %s", takebuf_string(msg)))
        else
            push!(reader.main, convert(Uint8, '\\'))
            push!(reader.main, byte)
        end
    end
    return
end

# Lexer state codes
module States
    const LEFT_PADDING = 1
    const UNQUOTED = 2
    const QUOTED = 3
    const QUOTED_ASCII_ESCAPE = 4
    const ESCAPED_QUOTE_BYTE = 5
    const UNQUOTED_ASCII_ESCAPE = 6
    const COMMENT = 7
    const FIELD_END = 8
end

@doc """
# Description

Read in the next sequence of bytes corresponding to a single column's value
from a CSV source provided as an IO object. The bytes will be read from `io`
into the reader's main buffer.

The implementation involves a finite-state machine that has several
side effects, including:

* Setting the bytes in `reader.main`
* Setting relevant boolean fields that influence higher-level parsing:
    * `reader.eor`: Was the end of a row of data encountered?
    * `reader.eof`: Was the end of the IO source encountered?
    * `reader.contained_comment`: Did the field contain a comment?
    * `reader.contained_quote`: Did the field contain any quoted sections?

# Arguments

* `io::IO`: An IO object from bytes will be read.
* `reader::CSVReader`: A CSVReader object.

# Returns

* `nbytes::Int`: The number of bytes read in total, including any control bytes
that influence parsing, but are not stored in the final buffer.
""" ->
function get_bytes!(io::IO, reader::CSVReader)
    reset!(reader)

    nbytes = 0

    if reader.allow_padding
        state = States.LEFT_PADDING
    else
        state = States.UNQUOTED
    end

    while state != States.FIELD_END
        if eof(io)
            state = States.FIELD_END
            reader.eor = true
            reader.eof = true
            break
        end

        byte = read(io, Uint8)
        nbytes += 1

        if state == States.LEFT_PADDING
            if reader.allow_padding && byte == convert(Uint8, ' ')
                state = States.LEFT_PADDING
            elseif reader.allow_comments && byte == reader.comment_byte
                state = States.COMMENT
                reader.contained_comment = true
            elseif reader.allow_quotes && byte == reader.quote_byte
                state = States.QUOTED
                reader.contained_quote = true
            elseif byte == reader.eoc_prefix
                # TODO: Handle multibyte sequences for EOC
                state = States.FIELD_END
                reader.eor = false
            elseif byte == reader.eor_prefix
                # TODO: Handle multibyte sequences for EOR
                state = States.FIELD_END
                reader.eor = true
            else
                state = States.UNQUOTED
                push!(reader.main, byte)
            end
        elseif state == States.UNQUOTED
            if reader.allow_comments && byte == reader.comment_byte
                state = States.COMMENT
                reader.contained_comment = true
            elseif reader.allow_quotes && byte == reader.quote_byte
                state = States.QUOTED
                reader.contained_quote = true
            elseif reader.allow_escapes && byte == '\\'
                state = States.UNQUOTED_ASCII_ESCAPE
            elseif byte == reader.eoc_prefix
                # TODO: Handle multibyte sequences for EOC
                state = States.FIELD_END
                reader.eor = false
            elseif byte == reader.eor_prefix
                # TODO: Handle multibyte sequences for EOR
                state = States.FIELD_END
                reader.eor = true
            else
                state = States.UNQUOTED
                push!(reader.main, byte)
            end
        elseif state == States.QUOTED
            if reader.allow_quotes && byte == reader.quote_byte
                state = States.ESCAPED_QUOTE_BYTE
            elseif reader.allow_escapes && byte == '\\'
                state = States.QUOTED_ASCII_ESCAPE
            else
                state = States.QUOTED
                push!(reader.main, byte)
            end
        elseif state == States.QUOTED_ASCII_ESCAPE
            state = States.QUOTED
            process_escape!(reader, byte)
        elseif state == States.ESCAPED_QUOTE_BYTE
            if reader.allow_quotes && byte == reader.quote_byte
                state = States.QUOTED
                push!(reader.main, byte)
            elseif byte == reader.eoc_prefix
                # TODO: Handle multibyte sequences for EOC
                state = States.FIELD_END
                reader.eor = false
            elseif byte == reader.eor_prefix
                # TODO: Handle multibyte sequences for EOR
                state = States.FIELD_END
                reader.eor = true
            else
                state = States.UNQUOTED
                push!(reader.main, byte)
            end
        elseif state == States.UNQUOTED_ASCII_ESCAPE
            state = States.UNQUOTED
            process_escape!(reader, byte)
        elseif state == States.COMMENT
            if byte == reader.eor_prefix
                # TODO: Handle multibyte sequences for EOR
                state = States.FIELD_END
                reader.eor = true
            else
                state = States.COMMENT
            end
        end
    end

    if reader.allow_padding
        rstrip!(reader)
    end

    return nbytes
end

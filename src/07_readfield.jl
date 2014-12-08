@doc """
# Description

Read the next field from an IO stream using a CSVReader object. Pass an
expected code to the inner `get_value!` call.

# Arguments

* `io::IO`: An IO stream from which bytes will be read.
* `reader::CSVReader`: A CSVReader object whose state will reflect the parsed
  field.
* `expected_type::Int`: The code to use when initiating parsing.

# Returns

* `nbytes::Int`: The total number of bytes read, including control bytes that
  do not appear in the output.
""" ->
function readfield(io::IO, reader::CSVReader, expected_type::Int)
    # TODO: Stop using expected_type here?
    nbytes = 0

    while reader.col == reader.skip_col
        nbytes += get_bytes!(io, reader)

        if reader.eor
            reader.col = 1
            reader.skip_col_idx = 1
            reader.skip_col = reader.skip_cols[1]
        else
            reader.col += 1
            if reader.skip_col_idx == length(reader.skip_cols)
                reader.skip_col_idx = 1
            else
                reader.skip_col_idx += 1
            end
            reader.skip_col = reader.skip_cols[reader.skip_col_idx]
        end
    end

    nbytes += get_bytes!(io, reader)
    get_value!(reader, expected_type)

    if reader.eor
        reader.col = 1
    else
        reader.col += 1
    end

    return nbytes
end

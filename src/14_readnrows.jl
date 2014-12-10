@doc """
# Description

Parse an integer from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::Int`
* `success::Bool`
""" ->
function print_error(i::Int, j::Int, reader::CSVReader)
    # TODO: Reconstruct the input row along w/ type inference results
    # Saw: 1,1.0,foo,false,NULL
    # Expected: Int,Float64,Bool,Bool
    error(
        @sprintf(
            "Parsing failed at row %d, col %d while reading this text:\n\"\"\"%s\"\"\"\n",
            i,
            j,
            bytestring(reader.main),
        )
    )
end

@doc """
# Description

Parse an integer from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::Int`
* `success::Bool`
""" ->
function readnrows(
    io::IO,
    reader::CSVReader,
    output::Any,
    max_rows::Integer = typemax(Int),
    output_i::Integer = 1,
)
    if !isempty(reader.skip_rows)
        skip_row_idx = 1
        skip_row = reader.skip_rows[skip_row_idx]
    else
        skip_row_idx = 0
        skip_row = 0
    end

    input_i = 0
    output_i -= 1
    nrows = available_rows(output, reader)
    ncols = length(reader.column_types)
    while !eof(io) && input_i < max_rows
        input_i += 1
        output_i += 1

        # Allocate space for more rows if necessary
        if output_i > nrows
            add_rows!(output, ceil(Integer, 1.5 * output_i), ncols)
            nrows = available_rows(output, reader)
        end

        # Handle skip rows
        while input_i == skip_row
            skiprow(io, reader)
            skip_row_idx += 1
            if skip_row_idx <= length(reader.skip_rows)
                skip_row = reader.skip_rows[skip_row_idx]
            else
                skip_row = 0
            end
            input_i += 1
        end

        # Attempt to read the first column
        j = 1
        readfield(io, reader, reader.column_types[j])
        if ncols > 1 && reader.eor
            if !isempty(reader.main)
                print_error(input_i, j, reader)
            end
            if reader.allow_comments && reader.contained_comment
                output_i -= 1
                continue
            end
            if reader.skip_blanks && !reader.contained_comment && !reader.contained_quote
                output_i -= 1
                continue
            end
        end
        store_field!(output, output_i, j, reader)

        # Move on if the data source only has one column per row
        if ncols == 1
            continue
        end

        # Read intermediate columns between first column and last column
        for j in 2:(ncols - 1)
            readfield(io, reader, reader.column_types[j])
            if reader.eor
                print_error(input_i, j, reader)
            end
            store_field!(output, output_i, j, reader)
        end

        # Read final column
        j = ncols
        readfield(io, reader, reader.column_types[j])
        if !reader.eor
            print_error(input_i, j, reader)
        end
        store_field!(output, output_i, j, reader)
    end

    return finalize(output, output_i, ncols)
end

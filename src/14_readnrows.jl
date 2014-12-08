@doc """
# Description

Parse an integer from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::Int`
* `success::Bool`
""" ->
function print_error(row::Int, col::Int, reader::CSVReader)
    # TODO: Reconstruct the input row along w/ type inference results
    # Saw: 1,1.0,foo,false,NULL
    # Expected: Int,Float64,Bool,Bool
    error(@sprintf("Parsing failed at row %d", row))
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
    output_row::Integer = 1,
)
    if !isempty(reader.skip_rows)
        skip_row_idx = 1
        skip_row = skip_rows[skip_row_idx]
    else
        skip_row_idx = 0
        skip_row = 0
    end

    input_row = 0
    output_row -= 1
    nrows = available_rows(output, reader)
    ncols = length(reader.column_types)
    while !eof(io) && input_row < max_rows
        input_row += 1
        output_row += 1

        # Allocate space for more rows if necessary
        if output_row > nrows
            add_rows!(output, ceil(Integer, 1.5 * output_row), ncols)
            nrows = available_rows(output, reader)
        end

        # Handle skip rows
        if input_row == skip_row
            skiprow(io, reader)
            skip_row_idx += 1
            if skip_row_idx <= length(skip_rows)
                skip_row = skip_rows[skip_row_idx]
            else
                skip_row = 0
            end
        end

        # Attempt to read the first column
        col = 1
        readfield(io, reader, reader.column_types[col])
        if ncols > 1 && reader.eor
            if !isempty(reader)
                print_error(input_row, col, reader)
            end
            if reader.allow_comments && reader.contained_comment
                continue
            end
            if reader.allow_blanks
                continue
            end
        end
        store_field!(output, output_row, col, reader)

        # Move on if the data source only has one column per row
        if ncols == 1
            continue
        end

        # Read intermediate columns between first column and last column
        for col in 2:(ncols - 1)
            readfield(io, reader, reader.column_types[col])
            if reader.eor
                print_error(input_row, col, reader)
            end
            store_field!(output, output_row, col, reader)
        end

        # Read final column
        col = ncols
        readfield(io, reader, reader.column_types[col])
        if !reader.eor
            print_error(input_row, col, reader)
        end
        store_field!(output, output_row, col, reader)
    end

    return finalize(output, output_row, ncols)
end

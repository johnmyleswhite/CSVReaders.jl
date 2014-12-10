@doc """
# Description

Parse an integer from a sequence of bytes.

# Arguments

* `bytes::Vector{Uint8}`: A sequence of bytes

# Returns

* `value::Int`
* `success::Bool`
""" ->
function Base.readall{T}(
    ::Type{T},
    io::IO,
    reader::CSVReader,
    sizehint::Integer = -1,
)
    if !isempty(reader.skip_rows)
        skip_row_idx = 1
        skip_row = reader.skip_rows[skip_row_idx]
    else
        skip_row_idx = 0
        skip_row = 0
    end

    # Skip lines at the start
    input_i = 1
    while !eof(io) && (input_i <= reader.skip_start || input_i == skip_row)
        if input_i <= reader.skip_start
            skiprow(io, reader)
            input_i += 1
        else
            skiprow(io, reader)
            skip_row_idx += 1
            if skip_row_idx <= length(reader.skip_rows)
                skip_row = reader.skip_rows[skip_row_idx]
            else
                skip_row = 0
            end
            input_i += 1
        end
    end

    # TODO: Return empty result with zero columns on EOF
    if eof(io)
        error("Input ended before a header was seen")
    end

    # Handle header
    if reader.header # AND NO FORCED NAMES
        # Handle comment lines here
        reader.column_names = readheader(io, reader)
        input_i += 1
    end

    # TODO: Return empty result with all Int64 columns on EOF after header
    if eof(io)
        error("Input ended immediately after the header")
    end

    rowdata = Relation(falses(0), Any[])
    bytes_per_row = readrow(io, reader, rowdata)
    avg_bytes_per_row = convert(Float64, bytes_per_row)
    input_i += 1

    # Now we definitely know ncols
    ncols = length(reader.column_types)

    # TODO: If header and ncols disagree, raise an error

    # In case we didn't have a header
    if !reader.header
        reader.column_names = UTF8String[@sprintf("x%d", i) for i in 1:ncols]
    end

    # TODO: Read more rows to improve type inference and estimate of numrows
    # TODO: Check that we're not reading too many rows
    const MAGIC_NUMBER = 0
    while input_i <= MAGIC_NUMBER
        bytes_per_row = readrow(io, reader, rowdata)
        α = 1 / input_i
        avg_bytes_per_row = α * avg_bytes_per_row + (1 - α) * bytes_per_row
        input_i += 1
    end

    # Allocate output based on estimate size
    if sizehint != -1
        # Number of bytes in the full stream
        estimated_nrows = sizehint / avg_bytes_per_row
        # β is a magic number that over-estimates number of rows
        # When β is well-chosen, we over-estimate enough that we seldom do
        # multiple allocations. When β is too larger, we over-allocate and
        # waste memory.
        β = 1.2
        nrows = ceil(Integer, β * estimated_nrows)
    end
    output = allocate(T, nrows, ncols, reader)

    # Store the early rows in output
    # TODO: Store missing rows
    for i in 1:(1 + MAGIC_NUMBER)
        store_row!(output, i, reader, rowdata)
    end

    # Use the standard nrows loop
    readnrows(io, reader, output, typemax(Int), 1 + MAGIC_NUMBER + 1)

    return output
end

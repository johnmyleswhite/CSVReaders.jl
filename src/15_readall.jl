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
    # Skip lines at the start
    input_row = 1
    while !eof(io) && input_row <= reader.skip_start
        skiprow(io, reader)
        input_row += 1
    end

    # TODO: Return empty result with an INT columns on EOF

    # Handle header
    if reader.header # AND NO FORCED NAMES
        reader.column_names = readheader(io, reader)
        input_row += 1
    end

    # TODO: Return empty result with an INT columns on EOF

    rowdata = Relation(falses(0), Any[])
    bytes_per_row = readrow(io, reader, rowdata)
    input_row += 1

    # Now we definitely know ncols
    numcols = length(reader.column_types)

    # In case we didn't have a header
    if !reader.header
        reader.column_names = UTF8String[@sprintf("x%d", i) for i in 1:numcols]
    end

    # TODO: Read more rows to improve type inference and estimate of numrows

    # Allocate output based on estimate size
    if sizehint != -1
        # Number of bytes in the full stream
        expected_numrows = sizehint / bytes_per_row
        numrows = ceil(Integer, 1.25 * expected_numrows)
    end
    output = allocate(T, numrows, numcols, reader)

    # Store the early rows in output
    store_row!(output, 1, reader, rowdata)

    # Use the standard nrows loop
    readnrows(io, reader, output, typemax(Int), 2)

    return output
end

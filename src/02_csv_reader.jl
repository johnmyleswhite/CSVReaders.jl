@doc """
# Description
A CSVReader object contains all of the information necessary to parse
a CSV file.

In particular, it maintains:

* Configuration settings necessary to extract the raw bytes representing each
  field.
* State information required for storing the raw bytes representing each field.
* Configuration settings necessary for parsing values from raw bytes.
* State information required for storing values parsed from raw bytes.
* Configuration settings necessary for parsing a complete CSV file when
  iterating field-by-field.
* State information required for parsing a complete CSV file when iterating
  field-by-field.
""" ->
type CSVReader
    # == get_bytes config ==
    eoc_bytes::Vector{Uint8}
    eoc_prefix::Uint8
    eor_bytes::Vector{Uint8}
    eor_prefix::Uint8
    # TODO: Support multibyte sequences here?
    quote_byte::Uint8
    # TODO: Support multibyte sequences here?
    comment_byte::Uint8
    allow_escapes::Bool
    allow_quotes::Bool
    allow_comments::Bool
    allow_padding::Bool

    # == get_bytes state ==
    main::Vector{Uint8}
    scratch::Vector{Uint8}
    eor::Bool
    eof::Bool
    contained_comment::Bool
    contained_quote::Bool

    # == get_value config ==
    nulls::Vector{Vector{Uint8}}
    trues::Vector{Vector{Uint8}}
    falses::Vector{Vector{Uint8}}

    # == get_value state ==
    int::Int
    float::Float64
    bool::Bool
    string::UTF8String
    success::Bool
    isnull::Bool
    current_type::Int

    # == read*() config ==
    column_types::Vector{Int}
    column_names::Vector{UTF8String}
    header::Bool
    skip_blanks::Bool
    skip_start::Int
    skip_rows::Vector{Int}
    skip_cols::Vector{Int}

    # == read*() state ==
    col::Int
    skip_col::Int
    skip_col_idx::Int
end

# @doc """
# # Description

# Construct a CSVReader object with reasonable defaults.

# # Arguments

# * `separator::String`: The sequence of bytes defining the field separator,
#    input as a string. Defaults to `","`.
# * `newline::String`: The sequence of bytes defining the row separator, input
#    as a string. Defaults to `"\n"`.
# * `quotemark::String`: The byte that indicates a quoted field, input as a
#    string. Defaults to `"\""`.
# * `commentmark::String`: The byte that indicates a comment, input as a
#    string. Defaults to `"#"`.
# * `allow_escapes::Bool`: Should ASCII escapes be processed? Defaults to `true`.
# * `allow_quotes::Bool`: Should quoted fields be allowed? Defaults to `true`.
# * `allow_comments::Bool`: Should comments be allowed? Defaults to `true`
# * `allow_padding::Bool`: Should padding around fields be ignored? Defaults to
#   `true`.
# * `nulls::Vector`: Which strings should be treated as indicators that a value
#    is null? Defaults to `["NA", "NULL"]`.
# * `trues::Vector`: Which strings should be treated as indicators that a value
#    is a Boolean value of true? Defaults to `["true", "TRUE"].
# * `falses::Vector`: Which strings should be treated as indicators that a value
#    is a Boolean value of false? Defaults to `["false", "FALSE"]`.
# * `column_types::Vector{DataType}`: Specify the types of all columns as Julia
#    types. Defaults to `DataType[]`.
# * `column_names::Vector{UTF8String}`: Specify the names of all columns using
#    a vector of strings. Defaults to `UTF8String[]`.
# * `header::Bool`: Does the file contain a header line with column names?
#    Defaults to `true`.
# * `skip_blanks::Bool`: Should be blank lines be ignored? Defaults to `true`.
# * `skip_start::Int`: How many lines of input should be ignored before
#    starting to read data from the IO source? Defaults to `0`.
# * `skip_rows::Vector{Int}`: Should certain rows from the IO source be ignored?
#    Defaults to `Int[]`.
# * `skip_cols::Vector{Int}`: Should certain columns from the IO source be
#    ignored? Defaults to `Int[]`.

# # Returns

# * `reader::CSVReader`: A CSVReader object

# """ ->
function CSVReader(;
    separator::String = ",",
    newline::String = "\n",
    quotemark::String = "\"",
    commentmark::String = "#",
    allow_escapes::Bool = true,
    allow_quotes::Bool = true,
    allow_comments::Bool = true,
    allow_padding::Bool = true,
    nulls::Vector = ["NA", "NULL"],
    trues::Vector = ["true", "TRUE"],
    falses::Vector = ["false", "FALSE"],
    column_types::Vector{DataType} = DataType[],
    column_names::Vector{UTF8String} = UTF8String[],
    header::Bool = true,
    skip_blanks::Bool = true,
    skip_start::Int = 0,
    skip_rows::Vector{Int} = Int[],
    skip_cols::Vector{Int} = Int[],
)
    # TODO: Support the following
    # decimal::Char – Assume that the decimal place in numbers is written
    #   using the decimal character. Defaults to '.'.
    # makefactors::Bool – Convert string columns into PooledDataVector‘s for
    #   use as factors. Defaults to false.
    # encoding::Int
    eoc_bytes = convert(Vector{Uint8}, separator)
    eoc_prefix = eoc_bytes[1]
    eor_bytes::Vector{Uint8} = convert(Vector{Uint8}, newline)
    eor_prefix = eor_bytes[1]
    quote_byte::Uint8 = convert(Vector{Uint8}, quotemark)[1]
    comment_byte::Uint8 = convert(Vector{Uint8}, commentmark)[1]
    null_seqs = convert(Vector{Vector{Uint8}}, nulls)
    true_seqs = convert(Vector{Vector{Uint8}}, trues)
    false_seqs = convert(Vector{Vector{Uint8}}, falses)
    main = Uint8[]
    scratch = Uint8[]
    eor = false
    eoc = false
    contained_comment = false
    contained_quote = false
    intval = 0
    floatval = 0.0
    boolval = false
    stringval = ""
    successval = false
    isnullval = false
    current_type = 0
    column_types = Int[type2code(rawtype) for column_type in column_types]
    col = 1
    if isempty(skip_cols)
        skip_col = 0
        skip_col_idx = 0
    else
        skip_col = skip_cols[1]
        skip_col_idx = 1
    end

    return CSVReader(
        eoc_bytes,
        eoc_prefix,
        eor_bytes,
        eor_prefix,
        quote_byte,
        comment_byte,
        allow_escapes,
        allow_quotes,
        allow_comments,
        allow_padding,
        main,
        scratch,
        eor,
        eoc,
        contained_comment,
        contained_quote,
        null_seqs,
        true_seqs,
        false_seqs,
        intval,
        floatval,
        boolval,
        stringval,
        successval,
        isnullval,
        current_type,
        column_types,
        column_names,
        header,
        skip_blanks,
        skip_start,
        skip_rows,
        skip_cols,
        col,
        skip_col,
        skip_col_idx,
    )
end

@doc """
# Description

Remove any padding bytes from the righthand side of the main byte buffer.

# Arguments

* `reader::CSVReader`:  A CSVReader object

# Returns

* Void
""" ->
function rstrip!(reader::CSVReader) # -> Void
    bytes = reader.main
    i = length(bytes)
    while i > 0 && bytes[i] == convert(Uint8, ' ')
        i -= 1
        pop!(bytes)
    end
    return
end

@doc """
# Description

Transfer bytes from the scratch buffer of a CSVReader to the main buffer.

# Arguments

* `reader::CSVReader`: A CSVReader object

# Returns

* Void
""" ->
function transfer!(reader::CSVReader) # -> Void
    while length(reader.scratch) > 0
        push!(reader.main, pop!(reader.scratch))
    end
    return
end

@doc """
# Description

Prepare a CSVReader object for reading a new field by resetting fields that
are left dirty by the previous read and will not be set correctly during the
next read.

# Arguments

* `reader::CSVReader`: A CSVReader object

# Returns

* Void
""" ->
function reset!(reader::CSVReader) # -> Void
    resize!(reader.main, 0)
    reader.contained_comment = false
    reader.contained_quote = false
    return
end

@doc """
# Description

Is the buffer of bytes of the last field read empty?

# Arguments

* `reader::CSVReader`: A CSVReader object

# Returns

* `isempty::Bool`: Is the buffer empty?
""" ->
Base.isempty(reader::CSVReader) = length(reader.main) == 0

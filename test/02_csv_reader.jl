module TestCSVReader
    using Base.Test
    using CSVReaders

    reader = CSVReaders.CSVReader()

    @test reader.eoc_bytes == [convert(Uint8, ',')]
    @test reader.eoc_prefix == convert(Uint8, ',')
    @test reader.eor_bytes == [convert(Uint8, '\n')]
    @test reader.eor_prefix == convert(Uint8, '\n')
    @test reader.quote_byte === convert(Uint8, '"')
    @test reader.comment_byte === convert(Uint8, '#')
    @test reader.allow_comments === true
    @test reader.allow_quotes === true
    @test reader.allow_padding === true

    for byte in convert(Vector{Uint8}, "Foobar   ")
        push!(reader.main, byte)
    end

    @test reader.main == Uint8[
        'F',
        'o',
        'o',
        'b',
        'a',
        'r',
        ' ',
        ' ',
        ' ',
    ]

    @test pop!(reader.main) === convert(Uint8, ' ')

    @test reader.main == Uint8[
        'F',
        'o',
        'o',
        'b',
        'a',
        'r',
        ' ',
        ' ',
    ]

    CSVReaders.rstrip!(reader)

    @test reader.main == Uint8[
        'F',
        'o',
        'o',
        'b',
        'a',
        'r',
    ]

    CSVReaders.reset!(reader)
    @test isempty(reader.main) === true

    push!(reader.main, 0x00)
    @test isempty(reader.main) === false

    @test 0x00 === pop!(reader.main)
    @test isempty(reader.main) === true

    @test isa(reader.main, Vector{Uint8})
    @test isa(reader.scratch, Vector{Uint8})
    @test isa(reader.main, Vector{Uint8})

    @test reader.eor === false
    @test reader.eof === false
    @test reader.contained_comment === false
    @test reader.contained_quote == false

    push!(reader.scratch, 0x00)
    @test reader.main == Uint8[]
    @test reader.scratch == Uint8[0x00]

    CSVReaders.transfer!(reader)
    @test reader.main == Uint8[0x00]
    @test reader.scratch == Uint8[]

    CSVReaders.reset!(reader)
    @test reader.main == Uint8[]
    @test reader.contained_comment === false
    @test reader.contained_quote === false

    @test reader.nulls == Vector{Uint8}[
        convert(Vector{Uint8}, "NA"),
        convert(Vector{Uint8}, "NULL"),
    ]

    @test reader.trues == Vector{Uint8}[
        convert(Vector{Uint8}, "true"),
        convert(Vector{Uint8}, "TRUE"),
    ]

    @test reader.falses == Vector{Uint8}[
        convert(Vector{Uint8}, "false"),
        convert(Vector{Uint8}, "FALSE"),
    ]

    @test reader.int === 0
    @test reader.float === 0.0
    @test reader.bool === false
    @test reader.string == ""
    @test reader.success === false
    @test reader.isnull === false
    @test reader.current_type === 0

    reader.int = 1
    reader.float = 1.0
    reader.bool = true
    reader.string = "foobar"
    reader.success = true
    reader.isnull = true
    reader.current_type = 1

    @test reader.int === 1
    @test reader.float === 1.0
    @test reader.bool === true
    @test reader.string == "foobar"
    @test reader.success === true
    @test reader.isnull === true
    @test reader.current_type === 1

    @test length(reader.column_types) == 0
    @test isa(reader.column_types, Vector{Int})

    push!(reader.column_types, CSVReaders.type2code(Int64))

    @test length(reader.column_types) == 1
    @test reader.column_types[1] == CSVReaders.Codes.INT

    reader.column_types[1] = CSVReaders.Codes.FLOAT

    @test length(reader.column_types) == 1
    @test reader.column_types[1] == CSVReaders.Codes.FLOAT

    @test reader.column_names == UTF8String[]

    @test reader.header === true
    @test reader.skip_blanks === true
    @test reader.skip_start === 0
    @test reader.skip_rows == Int[]
    @test reader.skip_cols == Int[]

    # TODO: Write tests for CSVReader() constructor w/ keyword args
end

module TestReadNRows
    using Base.Test
    using CSVReaders

    # Read a longer input into a Vector{Dict}

    io = open(joinpath("test", "data", "02_movies.csv"), "r")

    reader = CSVReaders.CSVReader()
    reader.column_names = CSVReaders.readheader(io, reader)

    row = CSVReaders.Relation(falses(0), Any[])
    bytes = CSVReaders.readrow(io, reader, row)

    output = Array(Dict{UTF8String, Any}, 10_000)
    for i in 1:10_000
        output[i] = Dict{UTF8String, Any}()
    end

    CSVReaders.store_row!(output, 1, reader, row)

    CSVReaders.readnrows(io, reader, output, 9_999, 2)

    @test length(output) == 10_000

    close(io)

    # Read the same input into a Dict{Vector}

    io = open(joinpath("test", "data", "02_movies.csv"), "r")

    reader = CSVReaders.CSVReader()
    reader.column_names = CSVReaders.readheader(io, reader)

    row = CSVReaders.Relation(falses(0), Any[])
    bytes = CSVReaders.readrow(io, reader, row)

    output = Dict{UTF8String, Any}()
    for j in 1:length(reader.column_types)
        output[reader.column_names[j]] = Array(
            Nullable{CSVReaders.code2type(reader.column_types[j])},
            50_000
        )
    end

    CSVReaders.store_row!(output, 1, reader, row)

    CSVReaders.readnrows(io, reader, output, 100_000, 2)

    @test length(output["title"]) == 58788

    close(io)

    # Vector{Nullable{Float64}}?
    io = open(joinpath("test", "data", "01_floats.csv"), "r")

    reader = CSVReaders.CSVReader()
    reader.column_names = CSVReaders.readheader(io, reader)

    row = CSVReaders.Relation(falses(0), Any[])
    bytes = CSVReaders.readrow(io, reader, row)

    output = Array(Nullable{Float64}, length(reader.column_types))

    CSVReaders.store_row!(output, 1, reader, row)

    @test length(output) == 3

    CSVReaders.readnrows(io, reader, output, 1)

    close(io)
end

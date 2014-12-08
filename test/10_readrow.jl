module TestReadRow
    using Base.Test
    using CSVReaders

    io = open(joinpath("test", "data", "scaling", "movies.csv"), "r")

    reader = CSVReaders.CSVReader()

    column_names = CSVReaders.readheader(io, reader)

    row = CSVReaders.Relation(falses(0), Any[])

    i = 0

    bytes = CSVReaders.readrow(io, reader, row)
    i += 1
    # Test all fields

    bytes = CSVReaders.readrow(io, reader, row)
    i += 1
    # Test all fields

    while !isempty(row.isnull)
        bytes = CSVReaders.readrow(io, reader, row)
        if !isempty(reader)
            i += 1
        end
    end

    @test i == 58788

    close(io)

    # Now w/ skip_cols
    io = open(joinpath("test", "data", "scaling", "movies.csv"), "r")

    reader = CSVReaders.CSVReader()
    reader.skip_cols = Int[i for i in 2:25]

    column_names = CSVReaders.readheader(io, reader)

    row = CSVReaders.Relation(falses(0), Any[])

    i = 0

    bytes = CSVReaders.readrow(io, reader, row)
    @test row.isnull[1] === false
    @test row.values[1] === 1
    i += 1

    bytes = CSVReaders.readrow(io, reader, row)
    @test row.isnull[1] === false
    @test row.values[1] === 2
    i += 1

    while !isempty(row.isnull)
        bytes = CSVReaders.readrow(io, reader, row)
        if !isempty(reader)
            i += 1
        end
    end

    @test i == 58788

    close(io)
end

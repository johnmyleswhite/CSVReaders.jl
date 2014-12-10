module TestDataChecks14
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "14_osx-newlines-in-fields.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader(newline = "\n")
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B"]

    nrows = 1
    ncols = 2
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable{UTF8String}(convert(UTF8String, "This")),
        Nullable{UTF8String}(convert(UTF8String, "That\nis what I said")),
    ]

    for i in 1:nrows
        for j in 1:ncols
            if isnull(truth[i][j])
                @test isnull(parsed[i, j])
            else
                @test get(parsed[i ,j]) == get(truth[i][j])
            end
        end
    end
end

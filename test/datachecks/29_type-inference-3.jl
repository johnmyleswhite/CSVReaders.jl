module TestDataChecks29
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "29_type-inference-3.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == [
        "IntColumn",
        "IntlikeColumn",
        "FloatColumn",
        "BoolColumn",
        "StringColumn",
    ]

    nrows = 3
    ncols = 5
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(1),
        Nullable(1.0),
        Nullable(3.1),
        Nullable(true),
        Nullable("stuff"),
    ]

    truth[2] = Any[
        Nullable(2),
        Nullable(7.0),
        Nullable(-3.1e8),
        Nullable(false),
        Nullable("blah"),
    ]

    truth[3] = Any[
        Nullable(-1),
        Nullable(7.0),
        Nullable(-3.1e-8),
        Nullable(false),
        Nullable("gah"),
    ]

    for i in 1:nrows
        for j in 1:ncols
            if isnull(truth[i][j])
                @test isnull(parsed[i, j])
            else
                @test get(parsed[i, j]) == get(truth[i][j])
            end
        end
    end
end

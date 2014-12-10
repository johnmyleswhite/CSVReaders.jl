module TestDataChecks08
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "08_types.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["n", "s", "f", "b"]

    nrows = 5
    ncols = 4
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(1),
        Nullable("text"),
        Nullable(2.3),
        Nullable(true),
    ]

    truth[2] = Any[
        Nullable(0),
        Nullable("more text"),
        Nullable(0.2),
        Nullable(false),
    ]

    truth[3] = Any[
        Nullable(100),
        Nullable(""),
        Nullable(5.7),
        Nullable(true),
    ]

    truth[4] = Any[
        Nullable(57),
        Nullable("text ole"),
        Nullable(2.010),
        Nullable(true),
    ]

    truth[5] = Any[
        Nullable(7),
        Nullable("test"),
        Nullable(0.0),
        Nullable(false),
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

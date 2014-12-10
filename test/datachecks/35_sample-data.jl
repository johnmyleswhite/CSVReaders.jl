module TestDataChecks35
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "35_sample-data.tsv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader(header = false, separator = "\t")
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["x1", "x2", "x3"]

    nrows = 5
    ncols = 3
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(0),
        Nullable(3),
        Nullable(5),
    ]

    truth[2] = Any[
        Nullable(1),
        Nullable(13),
        Nullable(4),
    ]

    truth[3] = Any[
        Nullable(12),
        Nullable(3),
        Nullable(3),
    ]

    truth[4] = Any[
        Nullable(13),
        Nullable(3),
        Nullable(102),
    ]

    truth[5] = Any[
        Nullable(10),
        Nullable(20),
        Nullable(30),
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

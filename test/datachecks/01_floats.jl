module TestDataChecks01
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "01_floats.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B", "C"]

    nrows = 5
    ncols = 3
    @test length(output) == nrows * ncols
    M = transpose(reshape(output, ncols, nrows))

    floats = Array(Any, nrows)

    floats[1] = Any[
        Nullable(1.5),
        Nullable(2.5),
        Nullable(3.5),
    ]

    floats[2] = Any[
        Nullable(7.6),
        Nullable(7.8),
        Nullable(8.0),
    ]

    floats[3] = Any[
        Nullable(1.678),
        Nullable(2.345),
        Nullable(6.543),
    ]

    floats[4] = Any[
        Nullable(99.1023),
        Nullable(98.1435),
        Nullable(97.1434),
    ]

    floats[5] = Any[
        Nullable(1.0),
        Nullable(2.0),
        Nullable(3.0),
    ]

    for i in 1:nrows
        for j in 1:ncols
            if isnull(floats[i][j])
                @test isnull(M[i, j])
            else
                @test get(M[i ,j]) == get(floats[i][j])
            end
        end
    end
end

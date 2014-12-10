# TODO: Decide what type to assign to the first column
module TestDataChecks28
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "28_type-inference-2.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["c1", "c2", "c3", "c4", "c5"]

    nrows = 3
    ncols = 5
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable("1.0"),
        Nullable(1.0),
        Nullable("0"),
        Nullable(true),
        Nullable("False"),
    ]

    truth[2] = Any[
        Nullable("2.0"),
        Nullable(3.0),
        Nullable("1"),
        Nullable(false),
        Nullable("true"),
    ]

    truth[3] = Any[
        Nullable("true"),
        Nullable(4.5),
        Nullable("f"),
        Nullable(true),
        Nullable("true"),
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

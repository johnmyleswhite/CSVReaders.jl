# TODO: Decide whether empty fields are NULL for all types
module TestDataChecks19
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "19_empty.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B", "C"]

    nrows = 3
    ncols = 3
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(convert(UTF8String, "")),
        Nullable{UTF8String}(),
        Nullable(convert(UTF8String, "")),
    ]

    truth[2] = Any[
        Nullable(convert(UTF8String, "x")),
        Nullable(convert(UTF8String, "y")),
        Nullable(convert(UTF8String, "z")),
    ]

    truth[3] = Any[
        Nullable(convert(UTF8String, "")),
        Nullable(convert(UTF8String, "")),
        Nullable(convert(UTF8String, "")),
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

module TestDataChecks30
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "30_complex-osx.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader(skip_start = 4, skip_blanks = true)
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["RawRow", "String"]

    nrows = 5
    ncols = 2
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(8),
        Nullable(convert(UTF8String, "multi-\nline\ntext")),
    ]

    truth[2] = Any[
        Nullable(11),
        Nullable(convert(UTF8String, "text")),
    ]

    truth[3] = Any[
        Nullable(13),
        Nullable(convert(UTF8String, "text")),
    ]

    truth[4] = Any[
        Nullable(15),
        Nullable(convert(UTF8String, "text")),
    ]

    truth[5] = Any[
        Nullable(16),
        Nullable(convert(UTF8String, "text")),
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

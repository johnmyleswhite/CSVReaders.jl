module TestDataChecks17
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "17_padding-2.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["Name", "IsMale"]

    nrows = 8
    ncols = 2
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(convert(UTF8String, "John")),
        Nullable(true),
    ]

    truth[2] = Any[
        Nullable(convert(UTF8String, "Joan")),
        Nullable(false),
    ]

    truth[3] = Any[
        Nullable(convert(UTF8String, "Alexander")),
        Nullable(true),
    ]

    truth[4] = Any[
        Nullable(convert(UTF8String, "Alexandra")),
        Nullable(false),
    ]

    truth[5] = Any[
        Nullable(convert(UTF8String, "Francis")),
        Nullable(true),
    ]

    truth[6] = Any[
        Nullable(convert(UTF8String, "Francine")),
        Nullable(false),
    ]

    truth[7] = Any[
        Nullable(convert(UTF8String, "George")),
        Nullable(true),
    ]

    truth[8] = Any[
        Nullable(convert(UTF8String, "Georgette")),
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

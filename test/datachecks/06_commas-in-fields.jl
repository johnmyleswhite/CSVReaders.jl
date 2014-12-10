module TestDataChecks06
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "06_commas-in-fields.tsv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader(separator = "\t")
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B"]

    nrows = 2
    ncols = 2
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable("1,0"),
        Nullable("2,2"),
    ]

    truth[2] = Any[
        Nullable(",3"),
        Nullable("4,"),
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

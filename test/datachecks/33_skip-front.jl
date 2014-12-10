# TODO: Figure out semantics of skip_start, skip_rows
# Do row numbers refer to discarded rows? To something like lines?
# NONSENSE,HEADER,ROW
# Is ROW at row 1 or row 3?
# How to "use up" skip_rows when called across functions?
# Need to track input row internally in reader to handle repeated calls
module TestDataChecks33
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "33_skip-front.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader(skip_start = 3)
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B", "C", "D"]

    nrows = 5
    ncols = 4
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    for i in 1:5
        truth[i] = Any[
            Nullable(1),
            Nullable(2),
            Nullable(3),
            Nullable(4),
        ]
    end

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

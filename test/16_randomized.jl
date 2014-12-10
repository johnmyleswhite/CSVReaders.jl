module TestRandomized
    using Base.Test
    using CSVReaders

    nreps = 25
    for rep in 1:nreps
        path = tempname()

        srand(1)
        nrows, ncols = rand(1:1000), rand(1:10)
        coltypes = rand(1:4, ncols)
        nullity = 0.1
        truth = Array(Any, nrows, ncols)
        for j in 1:ncols
            if coltypes[j] == 1
                for i in 1:nrows
                    if rand() < nullity
                        truth[i, j] = Nullable{Int}()
                    else
                        truth[i, j] = Nullable{Int}(rand(Int))
                    end
                end
            elseif coltypes[j] == 2
                for i in 1:nrows
                    if rand() < nullity
                        truth[i, j] = Nullable{Float64}()
                    else
                        truth[i, j] = Nullable{Float64}(rand(Float64))
                    end
                end
            elseif coltypes[j] == 3
                for i in 1:nrows
                    if rand() < nullity
                        truth[i, j] = Nullable{Bool}()
                    else
                        truth[i, j] = Nullable{Bool}(rand(Bool))
                    end
                end
            elseif coltypes[j] == 4
                for i in 1:nrows
                    if rand() < nullity
                        truth[i, j] = Nullable{UTF8String}()
                    else
                        truth[i, j] = Nullable{UTF8String}(utf8(randstring()))
                    end
                end
            end
        end

        # TODO: Insert header randomly
        # TODO: Insert comments randomly
        # TODO: Insert skip rows with "gobbledeegook" randomly
        # TODO: Insert blank row randomly
        # TODO: Pick skip cols randomly
        io = open(path, "w")
        for i in 1:nrows
            for j in 1:(ncols - 1)
                if isnull(truth[i, j])
                    print(io, "NULL")
                else
                    print(io, get(truth[i, j]))
                end
                print(io, ',')
            end
            if isnull(truth[i, ncols])
                println(io, "NULL")
            else
                println(io, get(truth[i, ncols]))
            end
        end
        close(io)

        reader = CSVReaders.CSVReader(header = false)
        io = open(path, "r")
        parsed = readall(Vector{Any}, io, reader, filesize(path))
        @test length(parsed) == nrows * ncols
        parsed = transpose(reshape(parsed, ncols, nrows))
        close(io)

        for i in 1:nrows
            for j in 1:ncols
                if isnull(truth[i, j])
                    @test isnull(parsed[i, j])
                else
                    @test get(truth[i, j]) == get(parsed[i, j])
                end
            end
        end
    end
end

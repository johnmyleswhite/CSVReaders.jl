module TestGetBytes
    using Base.Test
    using CSVReaders

    io = IOBuffer()
    write(io, """
    1,1.0,true,foo
    -2,NaN,false,bar
    123,1e-301,NULL,"this is some quoted text"
    13"45"5,NaN,false,I "have ""got"" some" text for you
     1 , 3.1 , TRUE , TextGoesHere
    """)
    seek(io, 0)

    reader = CSVReaders.CSVReader()

    i, j = 1, 1
    while !reader.eof
        nbytes = CSVReaders.get_bytes!(io, reader)
        if !reader.eof
            if i == 1
                if j == 1
                    @test bytestring(reader.main) == "1"
                elseif j == 2
                    @test bytestring(reader.main) == "1.0"
                elseif j == 3
                    @test bytestring(reader.main) == "true"
                elseif j == 4
                    @test bytestring(reader.main) == "foo"
                end
            elseif i == 2
                if j == 1
                    @test bytestring(reader.main) == "-2"
                elseif j == 2
                    @test bytestring(reader.main) == "NaN"
                elseif j == 3
                    @test bytestring(reader.main) == "false"
                elseif j == 4
                    @test bytestring(reader.main) == "bar"
                end
            elseif i == 3
                if j == 1
                    @test bytestring(reader.main) == "123"
                elseif j == 2
                    @test bytestring(reader.main) == "1e-301"
                elseif j == 3
                    @test bytestring(reader.main) == "NULL"
                elseif j == 4
                    @test bytestring(reader.main) == "this is some quoted text"
                end
            elseif i == 4
                if j == 1
                    @test bytestring(reader.main) == "13455"
                elseif j == 2
                    @test bytestring(reader.main) == "NaN"
                elseif j == 3
                    @test bytestring(reader.main) == "false"
                elseif j == 4
                    @test bytestring(reader.main) == "I have \"got\" some text for you"
                end
            elseif i == 5
                if j == 1
                    @test bytestring(reader.main) == "1"
                elseif j == 2
                    @test bytestring(reader.main) == "3.1"
                elseif j == 3
                    @test bytestring(reader.main) == "TRUE"
                elseif j == 4
                    @test bytestring(reader.main) == "TextGoesHere"
                end
            end
            if reader.eor
                i += 1
                j = 1
            else
                j += 1
            end
        end
    end

    @test (i, j) == (6, 1)

    io = open(joinpath("test", "data", "02_movies.csv"), "r")

    reader = CSVReaders.CSVReader()

    i, j, ncols = 1, 1, 0
    while !reader.eof
        nbytes = CSVReaders.get_bytes!(io, reader)
        # Debugging
        # @printf("%d,%d,%s\n", i, j, bytestring(reader.main))
        if !reader.eof
            if reader.eor
                i += 1
                j = 1
            else
                j += 1
                ncols = max(j, ncols)
            end
        end
    end

    @test (i, j) == (58790, 1)
    @test ncols == 25
end

module TestParseField
    using Base.Test
    using CSVReaders

    io = IOBuffer()

    write(io, """
        1,1.0,true,foo
        -2,NaN,false,bar
        123,1e-301,NULL,"this is some quoted text"
        13"45"5,NaN,false,I "have ""got"" some" text for you
         1 , 3.1 , TRUE , NA
    """)
    seek(io, 0)

    reader = CSVReaders.CSVReader()

    finished = false
    i = 0
    while !finished
        i += 1
        for j in 1:4
            nbytes = CSVReaders.get_bytes!(io, reader)
            if j == 1 && reader.eof && isempty(reader.main)
                finished = true
                break
            else
                CSVReaders.get_value!(reader, 1)
            end
            if i == 1
                if j == 1
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.INT
                    @test reader.int === 1
                elseif j == 2
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.FLOAT
                    @test reader.float === 1.0
                elseif j == 3
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.BOOL
                    @test reader.bool === true
                elseif j == 4
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.STRING
                    @test reader.string == "foo"
                end
            elseif i == 2
                if j == 1
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.INT
                    @test reader.int === -2
                elseif j == 2
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.FLOAT
                    @test reader.float === NaN
                elseif j == 3
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.BOOL
                    @test reader.bool === false
                elseif j == 4
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.STRING
                    @test reader.string == "bar"
                end
            elseif i == 3
                if j == 1
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.INT
                    @test reader.int === 123
                elseif j == 2
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.FLOAT
                    @test reader.float === 1e-301
                elseif j == 3
                    @test reader.isnull === true
                elseif j == 4
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.STRING
                    @test reader.string == "this is some quoted text"
                end
            elseif i == 4
                if j == 1
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.INT
                    @test reader.int === 13455
                elseif j == 2
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.FLOAT
                    @test reader.float === NaN
                elseif j == 3
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.BOOL
                    @test reader.bool === false
                elseif j == 4
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.STRING
                    @test reader.string == "I have \"got\" some text for you"
                end
            elseif i == 5
                if j == 1
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.INT
                    @test reader.int === 1
                elseif j == 2
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.FLOAT
                    @test reader.float === 3.1
                elseif j == 3
                    @test reader.isnull === false
                    @test reader.current_type == CSVReaders.Codes.BOOL
                    @test reader.bool === true
                elseif j == 4
                    @test reader.isnull === true
                end
            end
        end
    end
end

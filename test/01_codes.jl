module TestCodes
    using Base.Test
    using CSVReaders

    @test CSVReaders.code2type(CSVReaders.Codes.INT) == Int64
    @test CSVReaders.code2type(CSVReaders.Codes.FLOAT) == Float64
    @test CSVReaders.code2type(CSVReaders.Codes.BOOL) == Bool
    @test CSVReaders.code2type(CSVReaders.Codes.STRING) == UTF8String

    @test CSVReaders.type2code(Int64) == CSVReaders.Codes.INT
    @test CSVReaders.type2code(Float64) == CSVReaders.Codes.FLOAT
    @test CSVReaders.type2code(Bool) == CSVReaders.Codes.BOOL
    @test CSVReaders.type2code(UTF8String) == CSVReaders.Codes.STRING
end

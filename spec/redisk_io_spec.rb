require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Redisk::IO do
  before do
    # load a file into an IO object
    @io_name = 'rails.log'
    @key = Redisk::IO.list_key(@io_name)
    @file_as_array = []
    File.foreach(File.dirname(__FILE__) + '/fixtures/rails.log') {|f|
      @file_as_array << f
      Redisk.redis.rpush @key, f
    }
    @io = Redisk::IO.new(@io_name)
  end

  after do
    Redisk.redis.del @key
  end

  describe 'new' do    
    it 'returns an IO object' do
      @io.should be_instance_of(Redisk::IO)
    end

    it 'connects to the redis server' do
      @io.redis.should be_instance_of(Redis::Namespace)
    end

    it 'stores the name of the key' do
      @io.name.should == @io_name
    end
  end

  describe 'foreach' do

    it 'should yield each line to the block' do
      Redisk::IO.foreach(@io_name) do |line|
        line.should be_kind_of(String)
      end
    end

    it 'should return nil' do
      Redisk::IO.foreach(@io_name) {|l| l }.should == nil
    end

  end

  describe 'open' do

    it 'should return an IO object if no block is given' do
      Redisk::IO.open('newlog').should be_kind_of(Redisk::IO)
    end

    it 'should yield the IO object to the block' do
      Redisk::IO.open('newlog') do |log|
        log.should be_kind_of(Redisk::IO)
      end
    end

    it 'should return the value of the block' do
      Redisk::IO.open('newlog') do |log|
        'returned'
      end.should == 'returned'
    end

  end

  describe 'read' do

    it 'should return the entire contents without arguments' do
      Redisk::IO.read(@io_name).should == @file_as_array.join("\n")
    end

    it 'should return the first [length] contents' do
      Redisk::IO.read(@io_name, 2).should == @file_as_array[0..1].join("\n")
    end

    it 'should return [length] contents starting at [offset]' do
      Redisk::IO.read(@io_name, 2, 2).should == @file_as_array[2..3].join("\n")
    end

  end

  describe 'readlines' do

    it 'should return the entire contents as an array' do
      Redisk::IO.readlines(@io_name).should == @file_as_array
    end

  end

  describe 'instance methods' do
    before(:each) do
      @io = Redisk::IO.new(@io_name)
    end

    describe '#<<' do

      it 'should append a line to the io' do
        @io << 'whu'
        @io.lineno = 100
        @io.gets.should == "whu"
      end

      it 'should return the text' do
        (@io << 'whu').should == 'whu'
      end

      it 'should be able to chain' do
        @io << 'whu ' << 'zuh'
        @io.lineno = 100
        @io.gets.should == "whu zuh"
      end

    end

    describe '#each' do

      it 'should yield each line of the file' do
        i = 0
        @io.each {|l|
          l.should be_kind_of(String)
          l.should == @file_as_array[i]
          i+=1
        }
        i.should == 100
      end

      it 'should advance the lineno for each iteration' do
        i = 0
        @io.each {|l|
          i+=1
          @io.lineno.should == i
        }
        @io.lineno.should == 100
      end

    end
    
    describe '#each_byte' do
      
      it 'should yield each byte as a fixnum to a block' do
        i = 0
        all_bytes = @file_as_array.join('')
        @io.each_byte {|b| 
          b.should be_kind_of(Fixnum)
          b.should == all_bytes[i]
          i+=1
        }
      end
      
      it 'should advance the pos of the io' do
        i = 0
        @io.each_byte {|b|
          i+=1
          i.pos.should == i
        }
      end
      
    end
    
    describe '#eof' do

      it 'should return false if lineno is not the end of the file' do
        @io.eof.should == false
      end

      it 'should return true if lineno is at the end of the file' do
        @io.each {|l| l }
        @io.eof.should == true
      end

    end

    describe '#getc' do
      
      it 'should get the next byte from the file as a fixnum' do
        val = @io.getc
        val.should be_kind_of(Fixnum)
        val.should == @file_as_array[0][0]
      end
      
      it 'should increment the pos of the io' do
        @io.getc
        @io.pos.should == 1
        @io.getc
        @io.pos.should == 2
      end
      
      it 'should get the next line if necessary' do
        @io.pos = @file_as_array[0].length
        @io.getc.should == @file_as_array[1][0]
      end

    end
      
    describe '#gets' do

      it 'should return the next line from the io' do
        val = @io.gets
        val.should be_kind_of(String)
        val.should == @file_as_array[0]
      end

      it 'should advance the filedescriptor lineno' do
        @io.gets.should == @file_as_array[0]
        @io.lineno.should == 1
        @io.gets.should == @file_as_array[1]
        @io.lineno.should == 2
      end

      it 'should set the value of $_' do
        val = @io.gets
        @io._.should == val
      end
      
    end

    describe '#lineno' do
      it 'should return the current lineno' do
        @io.lineno.should == 0
      end
    end

    describe '#lineno=' do
      it 'should set the current lineno' do
        @io.lineno = 50
        @io.lineno.should == 50
        @io.gets.should == @file_as_array[50]
      end
    end
    
    describe '#pos' do
      
      it 'should return the current pos' do
        @io.pos.should == 0
      end
      
    end
    
    describe '#pos=' do
      
      it 'should set the pos' do
        @io.pos = 5
        @io.pos.should == 5
        @io.getc.should == @file_as_array[0][5]
      end
      
      it 'should set the lineno based on the pos' do
        @io.pos = @file_as_array[0].length + 2
        @io.lineno.should == 1
      end
      
    end

    describe '#print' do

      it 'should append arguments into a string and write to io' do
        @io.print('My ', 'name ', 'is ', 'redisk')
        line = Redisk::IO.read(@io_name, 1, 100)
        line.should == 'My name is redisk'
      end

      it 'should return nil' do
        @io.print('whu').should == nil
      end

      it 'should write the contents of $_ if no arguments are provided' do
        @io.gets
        @io.print
        line = Redisk::IO.read(@io_name, 1, 100)
        line.should == @file_as_array[0]
      end
    end

    describe '#printf' do

      it 'should run the arguments through sprintf and print to the io' do
        @io.printf('My name is %s', 'redisk')
        line = Redisk::IO.read(@io_name, 1, 100)
        line.should == 'My name is redisk'
      end

    end

    describe '#puts' do

      it 'should write each argument to the io' do
        @io.puts('1', '2', '3')
        @io.lineno = 100
        @io.gets.should == "1\n"
        @io.gets.should == "2\n"
        @io.gets.should == "3\n"
      end

      it 'should write a blank string if no argument is passed' do
        @io.puts
        @io.lineno = 100
        @io.gets.should == "\n"
      end

    end

    describe '#read' do
      
      it 'should read to the end of the file if [length] is ommited' do
        @io.read.should == @file_as_array.join("\n")
      end
      
      it 'should read into the [buffer] if a buffer is passed' do
        string = "new string\n"
        @io.read(nil, string)
        string.should == "new string\n" + @file_as_array.join("\n")
      end
      
      it 'should read [length] bytes from the IO' do
        val = @io.read(20)
        val.length.should == 20
      end
      
      it 'should return nil if [length] is passed at the eof' do
        @io.pos = 1000000
        @io.eof?.should == true
        @io.read(5).should == nil
      end
      
      it 'should return "" if no [length] is passed at the eof' do
        @io.pos = 1000000
        @io.eof?.should == true
        @io.read(nil).should == ""
      end
      
    end

    describe '#readbytes' do
      
      it 'should read [n] bytes from the io' do
        val = @io.readbytes(10)
        val.length.should == 10
        val.should == @file_as_array.join("\n")[0...10]
      end
      
      it 'should raise EOFError if the data is nil' do
        @io.each_byte {|b| b }
        @io.eof?.should == true
        lambda {
          @io.readbytes(10)
        }.should raise_error(EOFError)
      end
      
    end

    describe '#readline' do

      it 'should read the next line with gets' do
        @io.readline.should == @file_as_array[0]
        @io.lineno.should == 1
      end

      it 'should raise EOFError at the end of the lines' do
        @io.lineno = 100
        lambda {
          @io.readline
        }.should raise_error(Redisk::IO::EOFError)
      end

    end

    describe '#readlines' do

      it 'should return the lines as an array' do
        @io.readlines.should == @file_as_array
      end

    end

    describe '#rewind' do

      it 'should set the lineno to 0' do
        @io.lineno = 50
        @io.rewind.should == 0
        @io.lineno.should == 0
      end
      
    end

    describe '#seek' do

      it 'should set the lineno to the absolute location' do
        @io.seek(10)
        @io.lineno.should == 10
      end

      it 'should set the lineno to the absolute location with SEEK_SET' do
        @io.seek(15, IO::SEEK_SET)
        @io.lineno.should == 15
      end

      it 'should set the lineno to the location relative to the end with SEEK_END' do
        @io.seek(-5, IO::SEEK_END)
        @io.lineno.should == 95
      end

      it 'should set the lineno to an offset position from the current line with SEEK_CUR' do
        @io.lineno = 5
        @io.lineno.should == 5
        @io.seek(5, IO::SEEK_CUR)
        @io.lineno.should == 10
      end

    end

    describe '#stat' do

      it 'should return a stat like object' do
        @stat = @io.stat
        @stat.should be_instance_of(Redisk::Stat)
        @stat.atime.should be_instance_of(Time)
        @stat.size.should == 0
      end

    end

    describe '#write' do
      
      it 'should write the contents of string to the io' do
        @io.write('123')
        @io.lineno = 100
        @io.gets.should == '123'
      end

      it 'should return the number of bytes written' do
        @io.write('123').should == 3
      end

    end
    
    describe '#truncate(size)' do
      
      it 'should only keep the last [size] lines' do
        @io.truncate(10).should == 10
        @io.length.should == 10
        @io.readlines.should == @file_as_array[90...100]
      end
      
    end

    describe '#ungetc' do
      
      it 'should put the string represented by a fixnum at the end of the io buffer' do
        @io.ungetc 65
        @io.flush
        @io.each_byte {|b| b }
        @io.gets.should == "A"
      end
      
      it 'should return nil' do
        @io.ungetc(65).should == nil
      end
      
    end

  end
  
  describe 'As an interface for logger' do
    before do
      @io = Redisk::IO.new('test.log')
      @io.truncate
      @logger = Logger.new(@io)
    end
     
    it 'should write to the log' do
      @logger.info "This should be info"
      @logger.warn "This should be warn"
      @io.length.should == 2
    end    
    
  end
end
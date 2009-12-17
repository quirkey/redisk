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
      Redisk::IO.read(@io_name, 2, 2).should == @file_as_array[2..4].join("\n")
    end
    
  end
  
  describe 'readlines' do
    
    it 'should return the entire contents as an array' do
      Redisk::IO.readlines(@io_name).should == @file_as_array
    end
    
  end
  
  describe '#<<' do
    
    it 'should append a line to the io' do
      
    end
    
    it 'should return the text' do
      
    end
    
    it 'should be able to chain' do
      
    end
    
  end
    
  describe '#each' do
    
    it 'should yield each line of the file' do
      
    end
    
    it 'should advance the lineno for each iteration' do
      
    end
    
  end
  
  describe '#eof' do
    
    it 'should return false if lineno is not the end of the file' do
      
    end
    
    it 'should return true if lineno is at the end of the file' do
      
    end
    
  end
  
  describe '#gets' do
    
    it 'should return the next line from the io' do
      
    end
    
    it 'should advance the filedescriptor lineno' do
      
    end
    
    it 'should set the value of $_' do
      
    end
  end
  
  describe '#lineno' do
    it 'should return the current lineno' do
      
    end
  end
  
  describe '#lineno=' do
    it 'should set the current lineno' do
      
    end
    
    it 'should raise error if num is not a string'
  end
  
  describe '#print' do
    
    it 'should append arguments into a string' do
      
    end
    
    it 'should write arguments to the io' do
      
    end
    
    it 'should write the contents of $_ if no arguments are provided' do
      
    end
  end
  
  describe '#printf' do
    
    it 'should run the arguments through sprintf' do
      
    end
    
    it 'should append to the io' do
      
    end
  end
  
  describe '#puts' do
    
    it 'should write each argument to the io' do
      
    end
    
    it 'should write a blank string if no argument is passed' do
      
    end
    
  end
  
  describe '#readline' do
    
    it 'should read the next line with gets' do
      
    end
    
    it 'should raise EOFError at the end of the lines' do
      
    end
    
  end
  
  describe '#readlines' do
    
    it 'should return the lines as an array' do
      
    end
    
  end
  
  describe '#rewind' do
    
    it 'should set the lineno to 0' do
      
    end
    
    it 'should return 0' do
      
    end
  end
  
  
end

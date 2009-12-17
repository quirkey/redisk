require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Redisk::IO do
  before do
    # load a file into an IO object
    @io_name = 'rails.log'
    key = Redisk::IO.list_key(@io_name)
    @file_as_array = []
    File.foreach('fixtures/rails.log', 'r') {|f|
      @file_as_array << f
      Redisk.redis.lpush key, f
    }
    @io = Redisk::IO.new(@io_name)
  end
  
  describe 'new' do    
    it 'returns an IO object' do
      @io.should be_instance_of(Redisk::IO)
    end
    
    it 'connects to the redis server' do
      @io.redis.should be_instance_of(Redis::Namespace)
    end
    
    it 'stores the name of the key' do
      @io.name.should == 'testio'
    end
  end
  
  describe 'foreach' do
    
    it 'should yield each line to the block' do
      Redisk::IO.foreach(@io_name) do |line|
        line.should be_kind_of(String)
      end
    end
    
    it 'should return nil' do
      assert_nil Redisk::IO.foreach(@io_name) {|l| l }
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
      Redisk::IO.read(@io_name).should == @file_as_array.join('\n')
    end
    
    it 'should return the first [length] contents' do
      Redisk::IO.read(@io_name, 2).should == @file_as_array[0..1].join('\n')
    end
    
    it 'should return [length] contents starting at [offset]' do
      Redisk::IO.read(@io_name, 2, 2).should == @file_as_array[2..4].join('\n')
    end
    
  end
  
  describe 'readlines' do
    
    it 'should return the entire contents as an array' do
      Redisk::IO.readlines(@io_name).should == @file_as_array
    end
    
  end
    
  
end

require 'logger'
require 'redis/namespace'
require 'redisk/io'

module Redisk
  extend self
  
  # straight up lifted from from @defunkt's resque
  # Accepts a 'hostname:port' string or a Redis server.
  def redis=(server)
    case server
    when String
      host, port = server.split(':')
      redis = Redis.new(:host => host, :port => port, :thread_safe => true)
      @redis = Redis::Namespace.new(:redisk, :redis => redis)
    when Redis
      @redis = Redis::Namespace.new(:redisk, :redis => server)
    else
      raise "I don't know what to do with #{server.inspect}"
    end
  end

  # Returns the current Redis connection. If none has been created, will
  # create a new one.
  def redis
    return @redis if @redis
    self.redis = 'localhost:6379'
    self.redis
  end
  
end


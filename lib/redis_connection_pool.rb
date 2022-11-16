require 'connection_pool'
require 'redis'


module RedisConnectionPool
    def self.redis
        @redis ||= ConnectionPool::Wrapper.new do
            #Redis.new(url: ENV["REDIS_URL"])
            Redis.new(host: "127.0.0.1", port: 6379, db: 0 )
        end
    end
    def self.set(key,val)
        self.redis.set(key,val)
    end
end


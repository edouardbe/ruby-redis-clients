require 'redis'
require 'redis_connection_pool'
require 'abstract_state_client'


class Redis
    class StateClient < AbstractStateClient
        def initialize(key, redis)
            super()
            @key = key
            @redis = redis
        end

        def get
            @redis.get(@key)
        end

        def set(value)
            @redis.set(@key,value)
        end
    end
end
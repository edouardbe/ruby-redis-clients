require 'abstract_on_off_client'

class Redis
    class OnOffClient < AbstractOnOffClient
        
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
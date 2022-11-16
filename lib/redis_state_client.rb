require 'redis'
require 'redis_connection_pool'
require 'redis_thread_client_state'
require 'redis_abstract_client'


class Redis
    class StateClient < Redis::AbstractClient

        def initialize(key, redis, check_interval_s)
            super(key, redis, check_interval_s)
            @new_value = nil
            @previous_value = nil
            @on = {}
        end

        def on(array_of_value, &block)
            if array_of_value.class == String
                @on[[array_of_value]] = block
            else
                @on[array_of_value] = block
            end
        end

        def set(value)
            @redis.set(@key,value)
        end

        private
        def pre_start
            #none
        end
        def post_start
            #none
        end
        def run
            @new_value = @redis.get(@key)
            if @new_value != @previous_value
                @on.each do |k,v|
                    v.call(@new_value, @previous_value ) if k.include? @new_value
                end
                @previous_value = @new_value
            end
        end
    end
end
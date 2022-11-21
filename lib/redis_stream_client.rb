require 'redis'
require 'redis_connection_pool'
require 'abstract_stream_client'


class Redis
    class StreamClient < AbstractStreamClient
       
        def initialize(key, redis, max_messages_per_read = 10,from_s = nil, max_previous_messages = 0)
            super()
            @key = key
            @redis = redis
            @lastids = nil
            @max_messages_per_read = max_messages_per_read
            @from_s = from_s
            @max_previous_messages = max_previous_messages
        end

        def on_message(&block)
            @on_message_callback = block
        end

        def send(in_hash)
            @redis.xadd(@key, in_hash)
        end

        def start
            if ( @from_s.nil? )
                begin
                    @lastid = info['last-generated-id']
                    increment_last_id
                rescue 
                    @lastid = '0-0'
                end
            else
                @lastid =(Time.now.to_i - @from_s).to_s + "-0"
            end

            if @max_previous_messages > 0
                result = @redis.xrevrange(@key, @lastid, count: @max_previous_messages)
                unless result.empty?
                    result.each { |k,v| call(@on_message_callback, v)}
                    @lastid = result[result.length-1][0]
                    increment_last_id
                end
            end
        end

        def run
            loop do
                result = @redis.xrange(@key, @lastid, count: @max_messages_per_read)
                unless result.empty?
                    result.each { |k,v| call(@on_message_callback, v)}
                    @lastid = result[result.length-1][0]
                    increment_last_id
                else
                    break
                end
            end
        end

        private
        def info
            @redis.xinfo("stream", @key)
        end
        def increment_last_id
            timestamp, index = @lastid.split("-")
            @lastid = timestamp + "-" + (index.to_i+1).to_s
        end
    end
end
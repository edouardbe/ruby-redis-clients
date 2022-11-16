require 'redis'
require 'redis_connection_pool'
require 'redis_thread_client_state'
require 'redis_abstract_client'


class Redis
    class StreamClient < Redis::AbstractClient
       
        # Initialize: setup the stream client to listen to a redis stream
        # @param [Array of strings] keys    keys of the stream to listen to
        # @param [Object] redis either a Redis connection or Redis Connection Pool
        def initialize(key, redis, check_interval_s = 20, max_messages_per_read = 10,from_s = nil, max_last_messages = nil)
            super(key, redis, check_interval_s)
            @lastids = nil
            @max_messages_per_read = max_messages_per_read
            @from_s = from_s
            @max_last_messages = max_last_messages
        end

        def on_message(&block)
            @on_message_callback = block
        end

        def send(in_hash)
            @redis.xadd(@key, in_hash)
        end

        private
        def pre_start
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
        end
        def post_start
            read_last_messages_from_stream(@max_last_messages) unless (@max_last_messages.nil?)
        end
        def run
            read_next_messages_from_stream()
        end
        def info
            @redis.xinfo("stream", @key)
        end
        def increment_last_id
            timestamp, index = @lastid.split("-")
            @lastid = timestamp + "-" + (index.to_i+1).to_s
        end
        def read_next_messages_from_stream
            loop do
                result = @redis.xrange(@key, @lastid, count: @max_messages_per_read)
                unless result.empty?
                    result.each { |k,v| handle_new_message(v)}
                    @lastid = result[result.length-1][0]
                    increment_last_id
                else
                    break
                end
            end
        end
        def handle_new_message(message)
            if callback = @on_message_callback
                begin
                    callback.call(message)
                end
            end
        end
        def read_last_messages_from_stream
            result = @redis.xrevrange(@key, start:@lastid, count: @max_messages_per_read)
            unless result.empty?
                result.each { |k,v| handle_new_message(v)}
                @lastid = result[result.length-1][0]
                increment_last_id
            end
        end
    end
end
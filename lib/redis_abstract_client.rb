require 'redis'
require 'redis_connection_pool'
require 'redis_thread_client_state'

class Redis
    class AbstractClient    
       
        attr_reader :state

        # Initialize: setup the stream client to listen to a redis stream
        # @param [Array of strings] keys    keys of the stream to listen to
        # @param [Object] redis either a Redis connection or Redis Connection Pool
        def initialize(key, redis, check_interval_s = 20 )
            @key = key
            @redis = redis
            @check_interval_s = check_interval_s
            @state = Redis::ThreadClientState::STOPPED
        end

        def on_started(&block)
            @on_started_callback = block
        end

        def on_stopped(&block)
            @on_stopped_callback = block
        end

        def start(block_until_started = false)
            raise "#{self} already running" if @state == Redis::ThreadClientState::RUNNING
            @state = Redis::ThreadClientState::STARTING
            @thread = Thread.new do
                pre_start
                @state = Redis::ThreadClientState::RUNNING
                if @on_started_callback
                    begin
                        @on_started_callback.call
                    end
                end
                post_start
                
                while @state == Redis::ThreadClientState::RUNNING 
                    run
                    sleep(@check_interval_s)
                end
                @state = Redis::ThreadClientState::STOPPED 
                if  @on_stopped_callback
                    begin
                        @on_stopped_callback.call
                    end
                end
            end
            while (block_until_started && @state != Redis::ThreadClientState::RUNNING )
                sleep(0.001)
            end 
        end

        def stop(join = true)
            @state = Redis::ThreadClientState::STOPPING
            @thread.join if join
        end

        protected
        def pre_start
            raise "have to be implemented by child class"
        end
        def post_start
            raise "have to be implemented by child class"
        end
        def run
            raise "have to be implemented by child class"
        end
        

    end
end
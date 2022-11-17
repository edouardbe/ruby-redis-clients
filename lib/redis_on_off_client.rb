require 'redis_state_client'


class Redis
    class OnOffClient < Redis::StateClient

        def initialize(key, redis, check_interval_s = 60, sleep_interval_s = 0.001, auto_start = true)
            super(key, redis, check_interval_s)
            @on_off_client_thread = Thread.new do
                Thread.current.thread_variable_set(:activated, true)
                Thread.current.thread_variable_set(:to_shutdown, false)
                while (Thread.current.thread_variable_get(:to_shutdown) == false)
                    yield if (Thread.current.thread_variable_get(:activated) == true)
                    sleep(sleep_interval_s)
                end
            end
            on(["on","ON","true",true]) do
                @on_off_client_thread.thread_variable_set(:activated, true)
            end

            on(["off","OFF","false",false]) do
                @on_off_client_thread.thread_variable_set(:activated, false)
            end
            start if auto_start
        end

        def shutdown(value = false)
            @on_off_client_thread.thread_variable_set(:to_shutdown, true)
            @on_off_client_thread.value if value
        end
        
    end
end
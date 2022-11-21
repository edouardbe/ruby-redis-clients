require 'redis_connection_pool'
require 'redis_on_off_client'
require 'on_off_stop_thread'

describe OnOffStopThread do
    it  "TBD" do
        # ensure the value is off first
        l_client = Redis::OnOffClient.new("test3",RedisConnectionPool.redis)
        l_client.set("off")

        l_on_off_thread_listener = OnOffThreadListener.new(l_client, 0.005)
        l_on_off_stop_thread = OnOffStopThread.new(l_on_off_thread_listener, 0.001)
        
        l_on_init_called = 0
        l_on_run_called = 0
        l_on_stop_called = 0
        l_counter = 0

        l_on_off_stop_thread.on_start do 
            puts "init"
            l_on_init_called +=1
            l_counter = 0
        end
        
        l_on_off_stop_thread.on_run do 
            l_on_run_called += 1
            l_counter += 1
        end
        
        l_on_off_stop_thread.on_stop do 
            l_on_stop_called += 1
        end
        
        l_on_off_thread_listener.start(true)
        sleep(0.020)
        l_on_off_stop_thread.start(true)
        sleep(0.05)
        
        # init should be called by the start
        expect(l_on_init_called).to eq 1
        expect(l_counter).to eq 0 

        # should call init and call run, but not stop
        l_client.set("on")
        sleep(0.05)
        expect(l_on_init_called).to eq 1
        expect(l_counter).to be > 0 
        expect(l_counter).to eq l_on_run_called
        expect(l_on_stop_called).to eq 0
       
        # expect the counter to increment while running
        before_counter = l_counter
        sleep(0.05)
        expect(l_counter).to be > before_counter

        # should call stop
        l_client.set("off")
        sleep(0.05)
        expect(l_on_stop_called).to eq 1

        # should call init a second time and reset the counter so counter != on_run_called 
        l_client.set("on")
        sleep(0.02)
        expect(l_on_init_called).to eq 2 
        expect(l_counter).to be < l_on_run_called
        expect(l_on_stop_called).to eq 1

        # should now call the on_stop
        l_on_off_stop_thread.stop(true)
        l_on_off_thread_listener.stop(true)
        expect(l_on_stop_called).to eq 2

    end
end
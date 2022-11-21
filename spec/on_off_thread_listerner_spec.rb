require 'redis_on_off_client'
require 'redis_connection_pool'
require 'on_off_thread_listener'


describe OnOffThreadListener do
    it  "TBD" do
        
        l_counter_on = 0
        l_counter_off = 0
        l_counter_pouet = 0
        
        l_client = Redis::OnOffClient.new("test3",RedisConnectionPool.redis)
        l_on_off_thread_listener = OnOffThreadListener.new(l_client, 0.005)
        l_on_off_thread_listener.on_on do
            l_counter_on += 1
        end
        l_on_off_thread_listener.on_off do
            l_counter_off += 1
        end

        # ensure the value is unknown before
        l_client.set("unknown")

        l_on_off_thread_listener.start()
        l_client.set("on")
        sleep(0.01)
        l_client.set("off")
        sleep(0.01)
        l_client.set("on")
        sleep(0.01)
        l_client.set("off")
        sleep(0.01)
        l_on_off_thread_listener.stop(true)
        
        expect(l_counter_on).to eq(2)
        expect(l_counter_pouet).to eq(0) 
        expect(l_counter_off).to eq(2) 
    end
end
require 'redis_state_client'

describe Redis::StateClient do
    describe "instanciate state client" do
        l_redisConnectionPool = RedisConnectionPool.redis
        it "should TBD" do
            l_state_client = Redis::StateClient.new("test2", l_redisConnectionPool, 0.001 )
            expect(l_state_client.state).to eq(Redis::ThreadClientState::STOPPED) 
            
            l_on_started_called = false
            l_state_client.on_started do  
                expect(l_state_client.state).to eq(Redis::ThreadClientState::RUNNING) 
                l_on_started_called = true
            end

            l_counter_on = 0
            l_state_client.on("on") do |value, previous| 
                l_counter_on+=1
            end

            l_counter_off = 0
            l_state_client.on(["off","OFF"]) do |value, previous| 
                l_counter_off+=1
            end

            l_state_client.set("")

            l_state_client.start(block_until_started: true)
            expect(l_state_client.state).to eq(Redis::ThreadClientState::RUNNING) 
            
            sleep(0.2)
            l_state_client.set("on")
            sleep(0.2)
            l_state_client.set("off")
            sleep(0.2)
            l_state_client.set("ON")
            sleep(0.2)
            l_state_client.set("OFF")
            sleep(0.2)
            l_state_client.stop

            expect(l_on_started_called).to be true 
            expect(l_counter_on).to eq(1) 
            expect(l_counter_off).to eq(2) 

        end
    end
end
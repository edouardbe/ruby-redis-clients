require 'redis_state_client'

describe Redis::StateClient do
    describe "instanciate state client" do
        l_redisConnectionPool = RedisConnectionPool.redis
        it "should TBD" do
            l_state_client = Redis::StateClient.new("test2", l_redisConnectionPool)
            
            l_counter_on = 0
            l_state_client.on("on") do |value, previous| 
                l_counter_on+=1
            end

            l_counter_off = 0
            l_state_client.on(["off","OFF"]) do |value, previous| 
                l_counter_off+=1
            end

            l_counter_pouet = 0
            l_state_client.on(["pouet"]) do |value, previous| 
                l_counter_pouet+=1
            end

            l_state_client.set("")
            l_state_client.run
            l_state_client.set("on")
            l_state_client.run
            l_state_client.set("off")
            l_state_client.run
            l_state_client.set("pouet")
            l_state_client.run
            l_state_client.set("ON")
            l_state_client.run
            l_state_client.set("OFF")
            l_state_client.run
            
            expect(l_counter_on).to eq(1)
            expect(l_counter_pouet).to eq(1) 
            expect(l_counter_off).to eq(2) 

        end
    end
end
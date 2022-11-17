require 'redis_on_off_client'

describe Redis::OnOffClient do
    describe "instanciate on off client" do
        it "should TBD" do
            l_counter = 0
            l_client = Redis::OnOffClient.new("test3",RedisConnectionPool.redis, 1, 0.25) do
                l_counter += 1
                puts "running, counter is #{l_counter}"
            end
            l_client.set("on")
            sleep(3)
            l_client.set("off")
            sleep(3)
            l_client.set("on")
            sleep(3)
            l_client.set("off")
            sleep(3)
        end
    end
end
require 'redis_stream_client'

describe Redis::StreamClient do
    describe "instanciate client" do
        l_redisConnectionPool = RedisConnectionPool.redis
        it "should read all messages only once" do
            l_reader = Redis::StreamClient.new("test", l_redisConnectionPool )
            l_treated = {}
            l_called = 0
            
            l_reader.on_message do |m| 
                v = m["a"].to_i
                c = l_treated[v] || 0
                l_treated[v] = c + 1
                l_called += 1
            end
            
            
            sleep(1)
            l_reader.start
            
            l_writer = Redis::StreamClient.new("test", l_redisConnectionPool )
            for i in 1..50 do
                l_writer.send({:a => i})
            end
            
            l_reader.run
            
            # check all messages have been treated only once
            l_any = l_treated.any? { |k,v| v != 1}
            expect(l_called).to eq 50 
            expect(l_treated.length).to eq 50 
            expect(l_any).to be false 
            
        end
    end
end
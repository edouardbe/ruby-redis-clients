require 'redis_stream_client'

describe Redis::StreamClient do
    describe "instanciate client" do
        l_redisConnectionPool = RedisConnectionPool.redis
        it "should read all messages only once" do
            l_reader = Redis::StreamClient.new("test", l_redisConnectionPool, 0.001, 10 )
            expect(l_reader.state).to eq(Redis::ThreadClientState::STOPPED) 
            l_treated = {}
            l_called = 0
            l_reader.on_message do |m| 
                v = m["a"].to_i
                c = l_treated[v] || 0
                l_treated[v] = c + 1
                l_called += 1
            end
            
            l_on_started_called = false
            l_reader.on_started do  
                expect(l_reader.state).to eq(Redis::ThreadClientState::RUNNING) 
                l_on_started_called = true
            end

            l_reader.start(block_until_started: true)
            expect(l_reader.state).to eq(Redis::ThreadClientState::RUNNING) 
            l_writer = Redis::StreamClient.new("test", l_redisConnectionPool )
            for i in 1..200 do
                l_writer.send({:a => i})
            end
            
            sleep(1)
            l_reader.stop

            # check all messages have been treated only once
            l_any = l_treated.any? { |k,v| v != 1}
            expect(l_called).to eq(200) 
            expect(l_treated.length).to eq(200) 
            expect(l_any).to be false 
            expect(l_on_started_called).to be true 
            
        end
    end

    describe "instanciate client" do
        l_redisConnectionPool = RedisConnectionPool.redis
        it "test stop without join" do
            l_reader = Redis::StreamClient.new("test", l_redisConnectionPool, 0.001, 2 )
            l_treated = {}
            l_called = 0
            l_reader.on_message do |m| 
                v = m["a"].to_i
                c = l_treated[v] || 0
                l_treated[v] = c + 1
                l_called += 1
            end
            l_reader.start(block_until_started: true)
            l_writer = Redis::StreamClient.new("test", l_redisConnectionPool )
            for i in 1..2000 do
                l_writer.send({:a => i})
            end
            
            l_reader.stop(false)
            expect(l_reader.state).to eq(Redis::ThreadClientState::STOPPING) 
            
        end
    end
    describe "instanciate client" do
        l_redisConnectionPool = RedisConnectionPool.redis
        it "test stop with join" do
            l_reader = Redis::StreamClient.new("test", l_redisConnectionPool, 0.001, 2 )
            l_treated = {}
            l_called = 0
            l_reader.on_message do |m| 
                v = m["a"].to_i
                c = l_treated[v] || 0
                l_treated[v] = c + 1
                l_called += 1
            end
            l_reader.start(block_until_started: true)
            l_writer = Redis::StreamClient.new("test", l_redisConnectionPool )
            for i in 1..2000 do
                l_writer.send({:a => i})
            end
            
            l_on_stopped_called = false
            l_reader.on_stopped {
                l_on_stopped_called = true
            }
            l_reader.stop(true)
            expect(l_reader.state).to eq(Redis::ThreadClientState::STOPPED) 
            expect(l_on_stopped_called).to be true 
            
        end
    end
end
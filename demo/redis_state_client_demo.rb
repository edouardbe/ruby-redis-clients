require_relative '../lib/redis_state_client'

l_redisConnectionPool = RedisConnectionPool.redis
l_state_client = Redis::StateClient.new("test2", l_redisConnectionPool, 2 )
l_state_client.on("on") do |value, previous| 
    puts "value is now #{value}, previous was #{previous}"
end

l_state_client.on(["off","OFF"]) do |value, previous| 
    puts "value is now #{value}, previous was #{previous}"
end

l_state_client.start
l_state_client.join
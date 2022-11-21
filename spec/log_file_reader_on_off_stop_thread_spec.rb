require 'log_file_reader_on_off_stop_thread'
require 'redis_on_off_client'
require 'redis_connection_pool'
require 'on_off_thread_listener'
require 'tmpdir'

describe LogFileReader::LogFileReaderOnOffStopThread do
    
    it "TBD" do
        l_full_path = Dir.tmpdir() + "/logfile.txt"
        l_counter = 0

        # ensure the value is off first
        l_client = Redis::OnOffClient.new("test4",RedisConnectionPool.redis)
        l_client.set("off")
        
        # get the on_off_listener
        l_on_off_listener = OnOffThreadListener.new(l_client, 0.005)
        # get the log file reader
        l_log_file_reader = LogFileReader::LogFileReaderOnOffStopThread.new(l_full_path,l_on_off_listener, 0.001)

        l_log_file_reader.add_listener(LogFileReader::YieldNewLineReader.new do |line|
            l_counter +=1
        end)

        l_log_file_reader.start
        l_on_off_listener.start
        
        l_writer = Thread.new do 
            increment = 0
            while (true)
                File.open(l_full_path, "a") do |f|
                    f.write("line #{increment}\n")
                    increment += 1
                    sleep(0.015)
                end
            end
        end

        expect(l_counter).to eq 0 
        l_client.set("on")
        sleep(0.1)
        l_client.set("off")
        sleep(0.1)
        expect(l_counter).to be > 0 
        l_intermediate = l_counter
        l_client.set("on")
        sleep(0.1)
        l_client.set("off")
        sleep(0.2)
        expect(l_counter).to be > l_intermediate 

        l_on_off_listener.stop(true)
        l_log_file_reader.stop(true)

    end
end
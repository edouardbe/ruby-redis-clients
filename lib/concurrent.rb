module Concurrent
    @@THREADPOOLS = {}
    def self.get_or_create_threadpool(in_name, in_size, in_proc)
        if !@@THREADPOOLS.has_key?(in_name)
            @@THREADPOOLS[in_name] = Threadpool.new(in_name , in_size, in_proc)
            @@THREADPOOLS[in_name].spawn_threads 
        end
        @@THREADPOOLS[in_name] 
    end

    class Threadpool
        def initialize(in_name, in_num_threads, in_proc)
            @name = in_name
            @num_threads = in_num_threads
            @threads = []
            @queue = Queue.new
            @counter = 0
            @done = 0
            @proc = in_proc
        end
        
        attr_reader :num_threads, :threads, :counter, :name, :done
        private :threads
    
        def spawn_threads
          num_threads.times do
            threads << Thread.new do
                while running? || actions?
                    action_proc, action_payload = wait_for_action
                    action_proc.call(action_payload) if action_proc
                    @done +=1
                end
            end
          end
        end
        def submit(payload)
            @queue.push([@proc, payload])
            @counter +=1
        end
        def remaining_size
            @queue.length
        end
        def actions?
            !@queue.empty?
        end
        def running?
            !@queue.closed?
        end
        def dequeue_action
            @queue.pop(true)
        end
        def wait_for_action
            @queue.pop(false)
        end
        def stop
            @queue.close
            threads.each(&:exit)
            threads.clear
            true
        end
        def stats
            name + ": " +  @queue.length.to_s + " remaining, " + @done.to_s + " done"
        end
    end
end
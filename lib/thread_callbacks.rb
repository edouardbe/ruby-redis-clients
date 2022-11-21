require 'ostruct'
require 'callback'

class ThreadCallbacks   
    include Callback
       
    attr_accessor :context

    def initialize(sleep_interval_s = 20, context = nil )
        @sleep_interval_s = sleep_interval_s
        @context = context || OpenStruct.new
    end

    def on_start(&block)
        @on_start_callback = block
    end
    def on_run(&block)
        @on_run_callback = block
    end
    def on_stop(&block)
        @on_stop_callback = block
    end
    def on_pause(&block)
        @on_pause_callback = block
    end
    def on_resume(&block)
        @on_resume_callback = block
    end
    
    def start(block_until_started = false)
        pause = @pause
        pause = "unknown" if pause.nil?
        raise "#{self} already running" if !@thread.nil?
        @thread = Thread.new do
            Thread.current.thread_variable_set(:to_stop, false)
            Thread.current.thread_variable_set(:to_pause, pause)
            call(@on_start_callback, @context)
            Thread.current.thread_variable_set(:started, true)
            
            while Thread.current.thread_variable_get(:to_stop) == false
                #puts "pause? #{Thread.current.thread_variable_get(:to_pause)}"
                if Thread.current.thread_variable_get(:to_pause) == false
                    Thread.current.thread_variable_set(:paused, false)
                    call(@on_run_callback,@context)
                else
                    Thread.current.thread_variable_set(:paused, true)
                end
                sleep(@sleep_interval_s)
            end

            call(@on_stop_callback,@context)
        end
        
        while (block_until_started && @thread.thread_variable_get(:started) != true )
            sleep(0.001)
        end
        @thread.thread_variable_set(:to_pause, pause)
         
    end

    def started?
        !@thread.nil? && @thread.thread_variable_get(:started) == true 
    end

    def stop(join = false)
        if !@thread.nil?
            @thread.thread_variable_set(:to_stop, true) 
            @thread.join if join
            @thread = nil
        end
    end

    def paused?
        @thread.nil? || @thread.thread_variable_get(:paused)
    end
    
    def pause(join = false)
        raise "#{self} not running" if @thread.nil?
        @thread.thread_variable_set(:to_pause, true) 
        while (join && @thread.thread_variable_get(:paused) != true )
            sleep(0.001)
        end 
    end

    def resume(join = false)
        raise "#{self} not running" if @thread.nil?
        @thread.thread_variable_set(:to_pause, false) 
        while (join && @thread.thread_variable_get(:paused) != false )
            sleep(0.001)
        end 
    end
end
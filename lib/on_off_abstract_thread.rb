require 'thread_callbacks'
require 'on_off_thread_listener'
require 'callback'

class OnOffAbstractThread < ThreadCallbacks

    def initialize(on_off_thread_listener, sleep_interval_s = 0.001, context = nil)
        raise "on_off_thread_listener has to inherit from OnOffThreadListener" unless on_off_thread_listener.class.ancestors.include? OnOffThreadListener
        super(sleep_interval_s, context)
        
        @on_off_thread_listener = on_off_thread_listener

        @on_off_thread_listener.on_on do |ctx|
            raise 'on_on callback has to be implemented by inherited class'
        end

        @on_off_thread_listener.on_off do |ctx|
            raise 'on_off callback has to be implemented by inherited class'
        end 
    end
end
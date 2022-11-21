require 'on_off_abstract_thread'

class OnOffStopThread < OnOffAbstractThread
        
    def initialize(on_off_thread_listener, sleep_interval_s = 0.001, context = nil)
        super
        @on_off_thread_listener.on_on do |ctx|
            start(true) if !started?
            resume
        end

        @on_off_thread_listener.on_off do |ctx|
            stop if started?
        end

        on_run do
            raise 'on_run has to be overriden by the inherited class'
        end
    end
end
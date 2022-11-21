require 'abstract_on_off_client'
require 'thread_callbacks'

class OnOffThreadListener < ThreadCallbacks
    
    def initialize(on_off_client, check_interval_s = 1)
        raise 'on_off_client is not inherited from AbstractOnOffClient' unless on_off_client.class.ancestors.include? AbstractOnOffClient
        super(check_interval_s)
        @on_off_client = on_off_client
       
        @on_off_client.on_on do |ctx|
            call(@on_on)
        end

        @on_off_client.on_off do |ctx|
            call(@on_off)
        end

        on_run do
            @on_off_client.run
        end

        @pause = false
    end

    def on_on(&block)
        @on_on = block
    end
    def on_off(&block)
        @on_off = block
    end
end

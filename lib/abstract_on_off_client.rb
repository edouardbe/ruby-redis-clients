require 'abstract_state_client'


class AbstractOnOffClient < AbstractStateClient
    
    def initialize()
        super
        on(["on","ON","true",true]) do
            call(@on_on_callback)
        end

        on(["off","OFF","false",false]) do
            call(@on_off_callback)
        end
    end

    def on_on(&on_on_callback)
        @on_on_callback = on_on_callback
    end
    def on_off(&on_off_callback)
        @on_off_callback = on_off_callback
    end

end
require 'callback'

class AbstractStreamClient
    include Callback
       
    def initialize()
        @run_once = false
    end

    def on_message(&block)
        @on_message_callback = block
    end

    def send(obj)
        raise 'need to be implemented by inherited class'
    end

    def start
        raise 'need to be implemented by inherited class'
    end
    def run
        raise 'need to be implemented by inherited class'
    end
end

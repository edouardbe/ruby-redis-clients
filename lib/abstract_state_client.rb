require 'callback'

class AbstractStateClient
    include Callback

    def initialize()
        @new_value = nil
        @previous_value = nil
        @on = {}
    end

    def on(array_of_value, &block)
        if array_of_value.class == String
            @on[[array_of_value]] = block
        else
            @on[array_of_value] = block
        end
    end

    def run
        @new_value = get
        if @new_value != @previous_value
            @on.each do |k,v|
                v.call(@new_value, @previous_value ) if k.include? @new_value
            end
            @previous_value = @new_value
        end
    end

    def get
        raise 'get has to be overriden by the inherited class'
    end
    def set(value)
        raise 'set(value) has to be overriden by the inherited class'
    end
end
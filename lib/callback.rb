module Callback
    def call(in_callback,*args)
        #puts "#{self} : #{in_callback} called with args #{args}"
        in_callback.(*args) if !in_callback.nil?
    end
  end
require 'on_off_stop_thread'

module LogFileReader
    class LogFileReaderOnOffStopThread < OnOffStopThread
        
        def initialize(logfile_fullpath, on_off_thread_listener, sleep_interval_s = 0.001)
            super(on_off_thread_listener, sleep_interval_s)
            @fullpath = logfile_fullpath
            @listeners = []
            on_run do |ctx|
                if (@creation_time.nil?) 
                    # open the file and seek to then end
                    @fd = File.open(@fullpath, "r")
                    @creation_time = File.birthtime(@fullpath)
                    @fd.seek(0,IO::SEEK_END) 
                elsif ( File.birthtime(@fullpath).to_i != @creation_time.to_i )
                    # file rotation
                    # first read the remaining lines in the old file
                    read
                    # then be ready to read the new file
                    @fd = File.open(@fullpath, "r")
                    @creation_time = @fd.lstat.ctime
                end
                read
            end
            on_stop do |ctx|
                @creation_time = nil
                @fd = nil
            end
        end
        def add_listener(in_listener)
            unless (in_listener.class.ancestors.include? LogFileReader::AbstractNewLineReader) 
                raise "The listener #{in_listener} does not inherite from LogFileReader::AbstractNewLineReader"
            end
            @listeners << in_listener
            self
        end

        private
        def read 
            unless (@fd.nil?)
                @fd.readlines.each do |line|
                    @listeners.each do |listener|
                        listener.on_new_line(line)
                    end
                end
                @fd.seek(0,IO::SEEK_END) 
            end 
        end
    end

    class AbstractNewLineReader 
        def on_new_line(in_line)
            raise 'this method should be overriden'
        end
    end

    class YieldNewLineReader < AbstractNewLineReader
        def initialize(&block)
            @yield_callback = block
        end
        def on_new_line(in_line)
            @yield_callback.(in_line) unless @yield_callback.nil?
        end
    end

    class AbstractNewLineMatcher < AbstractNewLineReader
        def initialize(in_regex)
            super()
            @regex = in_regex
        end
        def on_new_line_match(in_line, in_matchdata) 
            raise 'this method should be overriden'
        end
        def on_new_line(in_line)
            matchdata = @regex.match(in_line)
            if (!matchdata.nil?) 
                on_new_line_match(in_line, matchdata)
            end
        end
    end
end
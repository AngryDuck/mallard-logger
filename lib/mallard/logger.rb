require 'logger'
require 'socket'
require 'fileutils'

# a simple wrapper for the Logger class.
# Mallard::Logger does the following for you:
# * prepends $HOME/logs to the path
# * creates the directory if it does not already exist
# * sets logfile rotation to daily
# * sets date format to CCYY-MM-DD hh:mm:ss
module Mallard; class Logger < ::Logger
    @@prefix = "#{ENV['HOME']}/logs"
    def initialize (logfile)
        full    = "#{@@prefix}/#{logfile}"
        dir     = File.dirname(full)
        @host   = Socket.gethostname.split(/\./).first
        begin
            FileUtils.mkpath(dir) unless test(?d, dir)
            super("#{@@prefix}/#{logfile}", 'daily')
        rescue Errno::EACCES
            Kernel.warn "Permission to create/access log denied.  Logging to stderr."
            super(STDERR)
        end
        self.formatter = proc do |severity, datetime, progname, msg|
            "#{severity[0]}, [#{datetime.strftime("%F %T")}##{@host}:#{$$}] #{severity} -- : #{msg}\n"
        end
    end
end; end

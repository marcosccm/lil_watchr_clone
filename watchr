#!/usr/bin/env ruby
require "pathname"

class Watcher
  attr_reader :paths
  def initialize(script)
    @handlers = {}
    @paths = []
    instance_eval(script.read)  
  end

  def watch(path, &block)
    Dir[path].each do |p|
      path = Pathname.new(p)
      next unless path.file?
      if @handlers.key? path
        @handlers[path] << block  
      else
        @handlers[path] = [ block ]
        @paths << path
      end
    end
  end

  def handle(path)
    @handlers[path].each(&:call)
  end
end

class Executor
  def initialize(script_path)
    @watchr = Watcher.new(Pathname.new(script_path))
    init_file_sizes
    rescue
    puts "Attempt to load the script file from #{script_path}. File not found."
  end

  def run
    loop do
      @sizes.each do |file, size|
        if file.size != size 
          @sizes[file] = file.size
          @watchr.handle(file) 
        end
      end
      sleep 1
    end
  end
  
  def init_file_sizes
    @sizes = Hash.new(0)  
    @watchr.paths.each do |path|  
      @sizes[path] = path.size
    end
  end
end

puts "Start watching..."
Executor.new(ARGV.first || "watchlist").run

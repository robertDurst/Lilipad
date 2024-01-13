# frozen_string_literal: true

require "filewatcher"

module Lilipad
  module Logger
    LOGG = {}.freeze

    filewatcher = Filewatcher.new(["./lilipad_config.json"])

    Thread.new(filewatcher) do |fw|
      fw.watch do |_changes|
        json = JSON.parse(File.read("./lilipad_config.json"))

        if json["enable"]
          enable_trace
        else
          disable_trace
        end

        reset

        json["log"].each do |log|
          append_logg(log["file"], log["lineno"], log["msg"])
        end
      end
    end

    TRACE = TracePoint.new(:line) do |tp|
      # known events to ignore
      if (tp.path && (tp.path.include?("gem") || tp.path.include?("lib") || tp.path.include?("internal:"))) || tp.defined_class&.to_s&.include?("Sinatra")
        next
      end

      puts LOGG[tp.path][tp.lineno.to_s] if LOGG[tp.path] && LOGG[tp.path][tp.lineno.to_s]
    end

    def self.enable_trace
      return if TRACE.enabled?

      TRACE.enable
    end

    def self.append_logg(path, lineno, msg)
      LOGG[path] ||= {}
      LOGG[path][lineno.to_s] = msg
    end

    def self.disable_trace
      return unless TRACE.enabled?

      TRACE.disable
    end

    def self.reset
      LOGG.clear
    end
  end
end

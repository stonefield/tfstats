#encoding: UTF-8
Encoding.default_external = Encoding::UTF_8
require "fileutils"
module Tfstats
  class Collector
    class << self
      def collect(directory, filespec, recursive, tabseparated)
        statistics = process_dir(directory, filespec, recursive)
        puts output( statistics, tabseparated)
      end

      def process_dir(directory, filespec, recursive)
        statistics = {}
        basename = File.basename File.expand_path(directory)
        info "directory: #{directory}"
        info "basename: #{basename}"
        info "filespec: #{filespec}"
        info "recursive: #{recursive}"
        if recursive
          Dir.glob("#{directory}/**/").each do |dir|
            info "traversing: #{dir}"
            placeholder = dir.sub(/^#{Regexp.escape(directory.to_s)}/, basename).chop
            statistics[placeholder] = new(dir, filespec).collect
          end
        else
          statistics[basename] = new(directory,filespec).collect
        end
        statistics
      end

      def output(statistics, tabseparated)
        str = ''
        if tabseparated
          pattern = (["%s"] * 8).join("\t") + + "\n"
          separator = ''
        else
          max_name = statistics.keys.max_by { |s| s.size  }.size
          pattern = "| %-#{max_name}.#{max_name}s |" + " %9.9s |" * 7 + "\n"
          separator = '+-'+ ('-' * max_name) + '-+' + ('-' * 11 + '+') * 7 + "\n"
        end
        fields = %i(files modules resources data variables lines loc)
        str << separator
        str << (pattern % %w(Directory Files modules resources data variables Lines LOC))
        str << separator
        statistics.each do |dir, filespecs|
          t = statistics[dir]
          unless empty?(t)
            str << (pattern % ([dir ] + t.values_at(*fields) ))
          end
        end
        str << separator
        str << (pattern % (["Total"] + sum(statistics).values_at(*fields) ))
        str << separator
        str
      end

      def sum(statistics)
        s = {}
        s.default = 0
        statistics.each do |k, stats|
          stats.each do |k,v|
            s[k] += v
          end
        end
        s
      end

      def empty?(stats)
        stats.values.sum == 0
      end

      def info(msg)
        if Tfstats.verbose
          puts msg
        end
      end
    end # << self

    attr_accessor :stats, :directory, :filespec

    def initialize(directory, filespec)
      @directory, @filespec = directory, filespec
      @stats = {}
      @stats.default = 0
    end

    def info(msg)
      self.class.info msg
    end

    def collect
      spec = File.join(directory, filespec)
      info "Fetching data from: #{spec}"
      Dir[spec].each do |file|
        info "Reading file: #{file}"
        @stats[:files] += 1
        begin
          File.read(file).each_line.with_index do |line,i|
            begin
              case line
              when /^\s*#/, /^\s*$/
              when /^\s*resource/
                @stats[:resources] += 1
              when /^\s*module/
                @stats[:modules] += 1
              when /^\s*variable/
                @stats[:variables] += 1
              when /^\s*data/
                @stats[:data] += 1
              else
                @stats[:loc] += 1
              end
            rescue ArgumentError => e
              STDERR.puts "#{file}:#{i+1} #{e}"
            end
            @stats[:lines] += 1
          end
        rescue => e
          STDERR.puts e
        end

      end
      @stats
    end

  end # Collector
end
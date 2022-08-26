#encoding: UTF-8
Encoding.default_external = Encoding::UTF_8
require "fileutils"
module Tfstats
  class Collector
    class << self
      def collect(directory, filespec, recursive, tabseparated)
        statistics = {}
        process_dir(directory, filespec, recursive) do |collector, placeholder|
          statistics[placeholder] = collector.collect
        end
        puts output( statistics, tabseparated)
      end

      def versions(directory, filespec, recursive, tabseparated)
        versions = {}
        process_dir(directory, filespec, recursive) do |collector, placeholder|
          versions[placeholder] = collector.versions if collector.any? # Check versions only if there are any relevant files in the directory
        end
        puts output_versions( versions, tabseparated)
      end


      def process_dir(directory, filespec, recursive)
        basename = File.basename File.expand_path(directory)
        info "directory: #{directory}"
        info "basename: #{basename}"
        info "filespec: #{filespec}"
        info "recursive: #{recursive}"
        if recursive
          Dir.glob("#{directory}/**/").each do |dir|
            info "traversing: #{dir}"
            placeholder = dir.sub(/^#{Regexp.escape(directory.to_s)}/, basename).chop
            yield new(dir, filespec), placeholder
          end
        else
          yield new(directory,filespec), basename
        end
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

      def output_versions(statistics, tabseparated)
        str = ''
        info "statistics collected: #{statistics.inspect}"
        if tabseparated
          pattern = (["%s"] * 3).join("\t") + "\n"
          separator = ''
          str << (pattern % %w(Directory Provider Version))
          statistics.each do |dir, info|
            str << (pattern % [dir, 'terraform-version', info[:terraform_version]])
            if info[:providers].is_a? Hash
              info[:providers].each do |provider, version|
                str << (pattern % [dir, provider, version])
              end
            else
              str << (pattern % [dir, 'providers', info[:providers]])
            end
          end
        else
          max_name = statistics.map do |dir, info|
            if info[:providers].is_a? Hash
              info[:providers].map { |k,v| k.size }
            else
              info[:providers].size
            end
          end.flatten.max + 1
          pattern = "    %-#{max_name}.#{max_name}s %8s\n"
          statistics.each do |dir, info|
            str << "#{dir}:\n"
            str << "  terraform-version: #{info[:terraform_version]}\n"
            if info[:providers].is_a? Hash
              str << "  providers:\n"
              info[:providers].each do |provider,version|
                str << ( pattern % ["#{provider}:",version])
              end
            else
              str << "  providers: #{info[:providers]}\n"
            end
          end
        end
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

    def any?
      spec = File.join(directory, filespec)
      Dir[spec].any?
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

    def versions
      @stats[:terraform_version] = terraform_version
      @stats[:providers] = provider_versions
      @stats
    end

    def terraform_version
      file = File.join(directory, '.terraform-version')
      version = ''
      if File.exist? file
        info "Fetching version from: #{file}"
        version = File.read(file).chomp
      else
        info "No terraform version file found (#{file})"
      end
      version == '' ? 'undefined' : version
    end

    def provider_versions
      file = File.join(directory, '.terraform.lock.hcl')
      providers = {}
      if File.exist? file
        state = :root
        provider = nil
        begin
          info "Fetching provider versions from: #{file}"
          File.read(file).each_line.with_index do |line,i|
            begin
              case state
              when :root
                if line =~ /^\s*provider\s*\"(.+)\"\s*\{\s*$/
                  provider = $1
                  state = :provider
                end
              when :provider
                if line =~ /^\s*version\s*=\s*"(.*)"\s*$/
                  providers[provider] = $1
                  state = :version
                end
              when :version
                if line =~ /^\s*\}\s*$/
                  provider = nil
                  state = :root
                end
              else
                raise ArgumentError, "File out of sync."
              end
            rescue ArgumentError => e
              STDERR.puts "#{file}:#{i+1} #{e}"
            end
          end
        rescue => e
          STDERR.puts e
        end
      end
      providers == {} ? 'undefined' : providers
    end

  end # Collector
end
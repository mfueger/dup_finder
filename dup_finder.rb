#!/usr/bin/env ruby

require 'find'
require 'digest/sha1'
require 'optparse'

class DupFinder
  attr_accessor :dirs
  attr_reader :file_sizes, :dups

  def initialize(options)
    @dirs = []
    @file_sizes = {}
    @dups = []
    @options = options
  end

  def show_dups
    @dirs.each { |dir| get_file_sizes(dir) }
    find_dups
    @dups.each { |dup| puts %{"#{dup}"} }
    summary if @options[:verbose]
  end

  def summary
    puts "#{@file_sizes.length} files processed"
    puts "#{@dups.count} dups found"
  end

  private

  def get_file_sizes(dir)
    Find.find(dir) do |f|
      # exclude dotfiles
      next if !@options[:all] && ((File.basename(f) =~ /^\./) || (File.dirname(f) =~ /\/\./))

      # exclude symlinks
      next if File.symlink?(f)

      # custom exclude
      next if @options[:exclude] && (f =~ /#{Regexp.quote(@options[:exclude])}/)

      if File.file?(f)
        size = File.size(f)
        next if (size == 0) && !@options[:empty]
        @file_sizes[size] ||= []
        @file_sizes[size] << f
      end
    end
  end # get_file_sizes

  def get_dups_from_group(group)
    case @options[:keep]
    when :none
      original = "none"
    when :short
      original = group.sort_by! { |fn| File.dirname(fn).length }.shift
    when :long
      original = group.sort_by! { |fn| File.dirname(fn).length }.reverse!.shift
    else
      original = group.shift
    end

    puts "# Kept: #{original}" if @options[:verbose] && (@options[:keep] != :none)
    group.each { |f| @dups << f }
  end # get_dups_from_group
  
  def find_dups
    @file_sizes.reject { |size, file_ary| file_ary.length == 1 }.values.each do |group|
      digests = group.map { |f| Digest::SHA1.file(f).hexdigest }

      if digests.uniq.size > 1
        digest_groups = digests.inject({}) { |h,d| h[d]=h[d].to_i + 1; h }.reject { |d,c| c == 1 }.keys

        sub_groups = []

        digest_groups.each do |digest_group|
          sub_group = []
          digests.each_with_index { |digest, idx| sub_group << group[idx] if digest == digest_group }
          sub_groups << sub_group
        end

        sub_groups.each { |group| get_dups_from_group(group) }
      else
        get_dups_from_group(group)
      end
    end
  end # find_dups
end

if __FILE__ == $0
  options = {}

  OptionParser.new do |opts|
    opts.version = '0.1.0'
    opts.banner = "Usage: #{File.basename(__FILE__)} [options] [dir ...]"
    opts.on("-a", "--all", "Include hidden files and folders") { |a| options[:all] = a }
    opts.on("-k", "--keep KEEP_TYPE", [:short, :long, :none], "Files to keep (short, long, none)") { |k| options[:keep] = k }
    opts.on("-z", "--empty", "Include empty files") { |z| options[:empty] = z }
    opts.on("-e", "--exclude REG_EX", "Exclude files with regex") { |reg_ex| options[:exclude] = reg_ex }
    opts.on("-c", "--verbose", "Show comments in output") { |c| options[:verbose] = c }
    opts.on_tail("-v", "--version", "Show version and exit") do
      puts "Version: #{opts.version}"
      exit
    end
  end.parse!

  dup_finder = DupFinder.new(options)

  ARGV.each do |dir|
    if File.directory?(dir)
      dup_finder.dirs << dir
    else
      puts %{"#{dir}" is not a valid directory.}
      exit 1
    end
  end

  dup_finder.dirs << Dir.getwd if dup_finder.dirs.empty?

  dup_finder.show_dups
end

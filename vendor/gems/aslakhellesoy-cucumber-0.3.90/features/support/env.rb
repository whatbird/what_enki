require 'rubygems'
require 'tempfile'
require 'spec/expectations'
require 'fileutils'
require 'forwardable'
begin
  gem "spork", ">= 0.5.1" # Ensure correct spork version number to avoid false-negatives.
rescue Gem::LoadError => ex
  warn "WARNING: #{ex.message} You need to have the spork gem installed to run the DRb feature properly!"
end

class CucumberWorld
  extend Forwardable
  def_delegators CucumberWorld, :examples_dir, :self_test_dir, :working_dir, :cucumber_lib_dir

  def self.examples_dir(subdir=nil)
    @examples_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../examples'))
    subdir ? File.join(@examples_dir, subdir) : @examples_dir
  end

  def self.self_test_dir
    @self_test_dir ||= examples_dir('self_test')
  end

  def self.working_dir
    @working_dir ||= examples_dir('self_test/tmp')
  end

  def cucumber_lib_dir
    @cucumber_lib_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))
  end

  def initialize
    @current_dir = self_test_dir
  end

  private
  attr_reader :last_exit_status, :last_stderr

  # The last standard out, with the duration line taken out (unpredictable)
  def last_stdout
    strip_duration(@last_stdout)
  end

  def strip_duration(s)
    s.gsub(/^\d+m\d+\.\d+s\n/m, "")
  end

  def replace_duration(s, replacement)
    s.gsub(/\d+m\d+\.\d+s/m, replacement)
  end

  def create_file(file_name, file_content)
    file_content.gsub!("CUCUMBER_LIB", "'#{cucumber_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def background_jobs
    @background_jobs ||= []
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def run(command)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      @last_stdout = `#{command} 2> #{stderr_file.path}`
      mode = Cucumber::RUBY_1_9 ? {:external_encoding=>"UTF-8"} : 'r'
      IO.popen("#{command} 2> #{stderr_file.path}", mode) do |io|
        @last_stdout = io.read
      end

      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end

  def run_spork_in_background
    pid = fork
    in_current_dir do
      if pid
        background_jobs << pid
      else
        # STDOUT.close
        # STDERR.close
        spork = `which spork`.strip
        cmd = "#{Cucumber::RUBY_BINARY} -I #{Cucumber::LIBDIR} #{spork} cuc"
        exec cmd
      end
    end
    sleep 0.2
  end

  def terminate_background_jobs
    if @background_jobs
      @background_jobs.each do |pid|
        Process.kill(Signal.list['TERM'], pid)
      end
    end
  end

end

World do
  CucumberWorld.new
end

Before do
  FileUtils.rm_rf CucumberWorld.working_dir
  FileUtils.mkdir CucumberWorld.working_dir
end

After do
  terminate_background_jobs
end

Before('@diffxml') do
  `diffxml --version`
  raise "Please install diffxml from http://diffxml.sourceforge.net/" if $? != 0
end
require 'helper'

class TestConfiguration < Test::Unit::TestCase
  context "loading configuration" do
    setup do
      @path = File.join(Dir.pwd, '_config.yml')
    end

    should "fire warning with no _config.yml" do
      mock(YAML).safe_load_file(@path) { raise SystemCallError, "No such file or directory - #{@path}" }
      mock($stderr).puts("Configuration file: none")
      assert_equal Jekyll::DEFAULTS, Jekyll.configuration({})
    end

    should "load configuration as hash" do
      mock(YAML).safe_load_file(@path) { Hash.new }
      mock($stdout).puts("Configuration file: #{@path}")
      assert_equal Jekyll::DEFAULTS, Jekyll.configuration({})
    end

    should "fire warning with bad config" do
      mock(YAML).safe_load_file(@path) { Array.new }
      mock($stderr).puts("           WARNING: Error reading configuration. Using defaults (and options).")
      mock($stderr).puts("Configuration file: (INVALID) #{@path}")
      assert_equal Jekyll::DEFAULTS, Jekyll.configuration({})
    end
  end
  context "loading config from external file" do
    setup do
      @paths = {
        :default => File.join(Dir.pwd, '_config.yml'),
        :other   => File.join(Dir.pwd, '_config.live.yml'),
        :empty   => ""
      }
    end

    should "load default config if no config_file is set" do
      mock(YAML).safe_load_file(@paths[:default]) { Hash.new }
      mock($stdout).puts("Configuration file: #{@paths[:default]}")
      assert_equal Jekyll::DEFAULTS, Jekyll.configuration({})
    end

    should "load different config if specified" do
      mock(YAML).safe_load_file(@paths[:other]) { {"baseurl" => "http://wahoo.dev"} }
      mock($stdout).puts("Configuration file: #{@paths[:other]}")
      assert_equal Jekyll::DEFAULTS.deep_merge({ "baseurl" => "http://wahoo.dev" }), Jekyll.configuration({ "config" => @paths[:other] })
    end

    should "load default config if path passed is empty" do
      mock(YAML).safe_load_file(@paths[:default]) { Hash.new }
      mock($stdout).puts("Configuration file: #{@paths[:default]}")
      assert_equal Jekyll::DEFAULTS, Jekyll.configuration({ "config" => @paths[:empty] })
    end
  end
end

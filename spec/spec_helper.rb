require "bundler/setup"
require "tfstats"

module FixtureHelpers
  def test_dir
    Pathname.new(File.dirname(__FILE__))
  end
  def fixture_dir
    test_dir.join('fixtures')
  end
  def fixture_file(filename, scope: nil)
    File.read fixture_file_path(filename, scope: scope)
  end
  def fixture_file_path(filename, scope: nil)
    if scope
      fixture_dir.join(scope.to_s, filename)
    else
      fixture_dir.join(filename)
    end
  end
end


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FixtureHelpers
end

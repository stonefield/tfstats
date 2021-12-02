# Tfstats - Terraform Statistics

This gem report code statistics (KLOCs, etc) from the terraform in current or specified directory. It also support recursion from a start point.

Supported:

* `tfstats` - command line
* `rake stats:terraform` - as a rake task


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tfstats'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tfstats


### Installing rake task

In your Rakefile add the following:

```rake
require 'rake/tfstats_task'
Rake::TfstatsTask.new do |task|
  task.directory = "."
  task.filespec = "*.tf"
  task.recursive = false
  task.tabseparated = false
end
```

All parameters are optional. The above shows the default:

| Parameter | Description | Example |
|---|---|---|
| `directory` | Specify the directory to run from. The directory specified is relative to current directory |  `task.directory = "terraform"` |
| `filespec` | You can specify a different filespec. |  `task.filespec = "*.{tf,sh,erb,tpl}"` |
| `recursive` | Set to true to operate recursively on sub-directories. If no files are found in the directory, it will not be listed. |  `task.recursive = true` |
| `tabseparated` | Output as a tab separated file and not as tabular text |  `task.tabseparated = true` |

## Usage

### Run directly from command line

```bash
  Usage: tfstats [options] [directory]

  Commands:
    -r / recursive    : run recursive.
    -f <filespec>     : specify filespec. Defaults to '*.tf' (use single quote!)
    -v / verbose      : Output debug information
    -t / tab          : Tab separated output

  If no directory is specified, statistics is collected from current directory
```


### Run as a rake task

```bash
  rake stats:terraform
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stonefield/tfstats. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stonefield/tfstats/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tfstats project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stonefield/tfstats/blob/master/CODE_OF_CONDUCT.md).

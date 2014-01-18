# StackProf Web navigator

__WARNING__: early version, no test, may have bugs.

Provides a web ui to inspect stackprof dumps.

![main screenshot][main-screenshot]

![method screenshot][method-screenshot]

![file screenshot][file-screenshot]

## Usage

### Install the gem
```bash
$ gem install stackprof-webnav
```

### Pass a dump to it
```bash
$ stackprof-webnav /path/to/stackprof.dump
```

See [stackprof gem][create-dump] homepage to learn how to create dumps.

### Profit
Open the browser at localhost:9292

## Caveats
- no tests, this gem was created for my personal usage in a hack stream,
  bugs may occur

## Contributing

1. Fork it ( http://github.com/<my-github-username>/stackprof-webnav/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[create-dump]: https://github.com/tmm1/stackprof#getting-started
[main-screenshot]: https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/main.png?raw=true
[method-screenshot]: https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/method.png?raw=true
[file-screenshot]: https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/file.png?raw=true

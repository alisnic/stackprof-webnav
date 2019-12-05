# StackProf Web navigator

Provides a web ui to inspect stackprof dumps.

## Screenshots

![](https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/directory.png?raw=true)

![](https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/overview.png?raw=true)

![](https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/method.png?raw=true)

![](https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/file.png?raw=true)

![](https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/callgraph.png?raw=true)

![](https://github.com/alisnic/stackprof-webnav/blob/master/screenshots/flamegraph.png?raw=true)

## Usage

### Install the gem
```bash
$ gem install stackprof-webnav
```

### Run the server

```bash
$ stackprof-webnav
```

By default it will list all files in the current directory. You can click in the
web interface to try to open any file as a dump.

Additionally, you can list another directory by passing the `-d` flag:

```bash
$ stackprof-webnav -d /my/folder/with/dumps
```

Or launch it with a dump preselected:

```bash
$ stackprof-webnav -f /path/to/stackprof.dump
```

See [stackprof gem][create-dump] homepage to learn how to create dumps.

### Profit
Open the browser at localhost:9292

## Contributing

1. Fork it ( http://github.com/<my-github-username>/stackprof-webnav/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[create-dump]: https://github.com/tmm1/stackprof#getting-started

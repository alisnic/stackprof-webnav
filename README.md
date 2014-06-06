# StackProf Web navigator

__WARNING__: early version, no tests, may have bugs.

Provides a web ui to inspect stackprof dumps.

## Screenshots

![main screenshot][main-screenshot]

![method screenshot][method-screenshot]

![file screenshot][file-screenshot]

## Usage

### Install the gem
```bash
$ gem install stackprof-webnav
```

### Pass a dump/URI to it
```bash
$ stackprof-webnav -f /path/to/stackprof.dump
$ stackprof-webnav -u http://path/to/stackprof.dump
$ stackprof-webnav -b http://amazon/s3/bucketlisting.xml
```

See [stackprof gem][create-dump] homepage to learn how to create dumps.
See [amazon s3 API docs][list-bucket-contents] to see the URI format for S3 bucket listings.

### Profit
Open the browser at localhost:9292. If you've used the -f or -u form, you can navigate the dump. If you've used the -b form, you'll see a listing of the keys in the bucket -- click on one that is a dump to browse through it.

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
[list-bucket-contents]: http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html

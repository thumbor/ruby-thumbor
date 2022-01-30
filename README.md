# ruby-thumbor
[![Github Actions - tests](https://github.com/thumbor/ruby-thumbor/actions/workflows/test.yml/badge.svg)](https://github.com/thumbor/ruby-thumbor/actions)
[![Github Actions - rubocop](https://github.com/thumbor/ruby-thumbor/actions/workflows/rubocop-analysis.yml/badge.svg)](https://github.com/thumbor/ruby-thumbor/actions)
[![Gem Version](https://badge.fury.io/rb/ruby-thumbor.svg)](https://rubygems.org/gems/ruby-thumbor)
[![Coverage Status](https://coveralls.io/repos/thumbor/ruby-thumbor/badge.svg?branch=master&service=github)](https://coveralls.io/github/thumbor/ruby-thumbor?branch=master)

ruby-thumbor is the Ruby client to the thumbor imaging service (http://github.com/thumbor/thumbor).

## Features
* Generate thumbor encrypted URLs
* Obtain metadata from image operations in thumbor

## Install
``` bash
gem install ruby-thumbor
```

## Using it
``` ruby
require 'ruby-thumbor'

image = Thumbor::Cascade.new('my-security-key', 'remote-image.com/path/to/image.jpg')
image.width(300).height(200).watermark_filter('http://remote-image.com/path/to/image.jpg', 30).generate

# url will contain something like:
# /2913921in321n3k2nj32hjhj3h22/remote-image.com/path/to/image.jpg

# Now you just need to concatenate this generated path, with your thumbor server url
```

### or
``` ruby
require 'ruby-thumbor'

crypto = Thumbor::CryptoURL.new 'my-security-key'

url = crypto.generate(width: 200, height: 300, image: 'remote-image.com/path/to/image.jpg')
```

## Available Thumbor arguments
``` ruby
meta: bool # flag that indicates that thumbor should return only meta-data on the operations it would otherwise perform;

crop: [<int>, <int>, <int>, <int>] # Coordinates for manual cropping. The first item is the two arguments are the coordinates for the left, top point and the last two are the coordinates for the right, bottom point (thus forming the square to crop);

width: <int> # the width for the thumbnail;

height: <int> # the height for the thumbnail;

flip: <bool> # flag that indicates that thumbor should flip horizontally (on the vertical axis) the image;

flop: <bool> # flag that indicates that thumbor should flip vertically (on the horizontal axis) the image;

halign: :left, :center or :right # horizontal alignment that thumbor should use for cropping;

valign: :top, :middle or :bottom # horizontal alignment that thumbor should use for cropping;

smart: <bool> # flag that indicates that thumbor should use smart cropping;

filters: ['blur(20)', 'watermark(http://my.site.com/img.png,-10,-10,50)'] # array of filters and their arguments
```

If you need more info on what each option does, check thumbor's documentation at https://thumbor.readthedocs.io/en/latest/index.html.

## Uploading to Rubygems
To upload a new version to Rubygems, simply update the version on the file `lib/thumbor/version.rb` then use the commit message `Bump to <new version>`, this will trigger the release process on Github actions.


## License
(The MIT License)

Copyright (c) 2022 Bernardo Heynemann <heynemann@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

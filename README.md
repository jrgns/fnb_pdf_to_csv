# FNB PDF Convert to CSV

This gem provides the ability to convert a PDF FNB statement to a CSV file or statement.

## Installation

Add this line to your application's Gemfile:

    gem 'fnb_pdf_to_csv'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fnb_pdf_to_csv

## Usage

```ruby
#!/usr/bin/env ruby
require 'thor'
require 'fnb_pdf_to_csv'

class Converter < Thor
  desc 'csvfile source destination', 'Convert the PDF from source to destination. Destination will be a plain CSV file'
  def csvfile(from, to)
    parser = FnbPdfToCsv.parse from
    parser.output to
  end

  desc 'file source destination', 'Convert the PDF from source to destination. Destination will be a tabbed CSV file'
  def file(from, to)
    parser = FnbPdfToCsv.parse from
    parser.output to, "\t"
  end

  desc 'statement source destination', 'Convert the PDF from source to destination. Destination will mimick a FNB statement'
  def statement(from, to)
    parser = FnbPdfToCsv.parse from
    parser.statement to
  end
end

Converter.start(ARGV)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

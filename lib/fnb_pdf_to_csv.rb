require 'version'
require 'pdf-reader'
require 'csv'

class FnbPdfToCsv
  attr_reader :lines

  AMOUNT = '\(?[0-9][0-9,]*\.[0-9]{2}\)?(Cr)?'
  DATE   = '\d{2} \w{3}'

  def initialize file
    @reader = ::PDF::Reader.new file
    @lines = []
  end

  def self.parse file
    parser = self.new(file)
    parser.parse
    parser
  end

  def parse
    @reader.pages.each { |page| parse_page page }
  end

  def output file
    f = File.new file, 'w'
    lines.each { |line| f.write line.to_csv }
  end

  def statement file
    f = File.new file, 'w'
    count = 1
    lines.each do |line|
      f.write statement_line(line, count).to_csv
      count = count + 1
    end
  end

  def statement_line line, count
    line.insert(0, 5)
    line.insert(1, count)
    line[2] = "'#{line[2]}'"
    line
  end

  def parse_page page
    page.text.each_line { |line| parse_line line }
  end

  def parse_line line
    #puts line
    line.match(/^\s*(#{DATE})(.*?)(#{AMOUNT})\s+(#{AMOUNT})(\s+#{AMOUNT})?$/) do |m|

      @lines.push clean_line(mangle_line(m.to_a))
    end
  end

  def clean_date(date)
    day, month = date.split(/\s/)
    Time.new(Time.new.year, month, day.to_i).strftime("%Y-%m-%d")
  end

  def clean_amount(amount)
    return amount if amount.nil?
    return 0 - amount[1..-2].to_f if amount[0] == '(' and amount[-1] == ')'
    if amount[-2..-1] == 'Cr'
      return amount[0..-3].to_f
    else
      return 0 - amount.to_f
    end
  end

  def clean_line(line)
    line[0] = clean_date line[0]
    line[4] = clean_amount line[4]
    line[5] = clean_amount line[5]
    line[6] = clean_amount line[6]

    line
  end

  def mangle_line arr
    arr.delete_at 0
    arr.map! { |elm| elm.strip unless elm.nil? } # Cleanup

    arr.delete_at 3
    arr.delete_at 4
    arr.delete_at 5
    arr[1] = arr[1].split(/\s{2,}/) # We get the three descriptions as one string
    arr.insert(2, arr[1][1])        # So split them up and add them back
    arr.insert(3, arr[1][2])
    arr[1] = arr[1][0]
    arr
  end
end

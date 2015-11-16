require 'fnb_pdf_to_csv/version'
require 'pdf-reader'
require 'csv'

class FnbPdfToCsv
  attr_reader :lines

  AMOUNT = '\(?[0-9][0-9,]*\.[0-9]{2}\)?\s?(Cr)?'
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

  def output file, separator = ','
    f = File.new file, 'w'
    f.write [
      'Date','Description1','Description2','Description3','Amount','Balance','Accrued Charges'
    ].to_csv(col_sep: separator)

    lines.each { |line| f.write clean_line(line).to_csv(col_sep: separator) }
  end

  def statement file
    f = File.new file, 'w'
    f.write "5,'Number','Date','Description1','Description2','Description3','Amount','Balance','Accrued Charges'\n"

    count = 1
    lines.each do |line|
      f.write statement_line(line, count).join(',') + "\n"
      count = count + 1
    end
  end

  def statement_line line, count
    sline = line.dup
    sline.insert(0, 5)
    sline.insert(1, count)
    sline[2] = "'#{sline[2]}'"
    sline[3] = '"' + sline[3] + '"' unless (sline[3].nil? or sline[3] == '')
    sline[4] = '"' + sline[4] + '"' unless (sline[4].nil? or sline[4] == '')
    sline[5] = '"' + sline[5] + '"' unless (sline[5].nil? or sline[5] == '')
    sline[6] = clean_amount(sline[6])
    sline[7] = clean_amount(sline[7])

    sline
  end

  def parse_page page
    page.text.each_line { |line| parse_line line }
  end

  def parse_line line
    line.match(/^\s*(#{DATE})(.*?)(#{AMOUNT})\s+(#{AMOUNT})(\s+#{AMOUNT})?$/) do |m|
      @lines.push mangle_line!(m.to_a)
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
      return amount[0..-3].tr(',', '').to_f
    else
      return 0 - amount.tr(',', '').to_f
    end
  end

  def clean_line(line)
    sline = line.dup
    sline[0] = clean_date sline[0]
    sline[4] = clean_amount sline[4]
    sline[5] = clean_amount sline[5]
    sline[6] = clean_amount sline[6]

    sline
  end

  def mangle_line! arr
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

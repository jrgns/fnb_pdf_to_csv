# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fnb_pdf_to_csv/version'

Gem::Specification.new do |spec|
  spec.name          = 'fnb_pdf_to_csv'
  spec.version       = FnbPdfToCsv::VERSION
  spec.authors       = ['Jurgens du Toit']
  spec.email         = ['jrgns@jrgns.net']
  spec.description   = %(Convert account statements from FNB in PDF to CSV)
  spec.summary       = %(Convert account statements from FNB in PDF to CSV)
  spec.homepage      = 'https://github.com/jrgns/fnb_pdf_to_csv'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'pdf-reader'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end

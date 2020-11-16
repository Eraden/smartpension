require_relative './lib/parser'

store = Parser.new.parse ARGV.first
Printer.new(store).print

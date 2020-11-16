require 'spec_helper'

RSpec.describe Printer do
  it 'must print visits' do
    store = Store.new
    store.update_page '/a', '0.0.0.0'
    stream = StringIO.new
    printer = Printer.new store, stream
    printer.print

    expect(stream.string.split("\n")).to eq ["/a 1 visits", "", "/a 1 unique views"]
  end

  it 'must print ordered output' do
    store = Store.new
    store.update_page '/b', '0.0.0.0'
    store.update_page '/a', '0.0.0.0'
    store.update_page '/a', '0.0.0.1'

    stream = StringIO.new
    printer = Printer.new store, stream
    printer.print

    expect(stream.string.split("\n")).to eq [
                                              "/a 2 visits",
                                              "/b 1 visits",
                                              "",
                                              "/a 2 unique views",
                                              '/b 1 unique views'
                                            ]
  end

  it 'must print ordered output when input is mixed' do
    store = Store.new
    store.update_page '/a', '0.0.0.0'
    store.update_page '/b', '0.0.0.0'
    store.update_page '/a', '0.0.0.1'

    stream = StringIO.new
    printer = Printer.new store, stream
    printer.print

    expect(stream.string.split("\n")).to eq [
                                              "/a 2 visits",
                                              "/b 1 visits",
                                              "",
                                              "/a 2 unique views",
                                              '/b 1 unique views'
                                            ]
  end
end

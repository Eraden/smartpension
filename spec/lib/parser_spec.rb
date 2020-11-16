require 'spec_helper'

RSpec.describe Parser do
  describe '#parse' do
    it 'must response to parse' do
      mtd = Parser.instance_method :parse
      expect(mtd).to be_a UnboundMethod
    end

    it 'must takes 1 parameter' do
      mtd = Parser.instance_method :parse
      arity = mtd&.arity.to_i
      expect(arity).to be 1
    end
  end

  it 'must raise error if file does not exists' do
    parser = Parser.new
    expect { parser.parse 'foo.log' }.to raise_exception FileNotFound
  end

  it 'should not raise exception if file exists' do
    parser = Parser.new
    file_path = File.absolute_path(File.join(__dir__, '..', 'fixtures', 'empty.log'))
    expect { parser.parse file_path }.to_not raise_exception FileNotFound
  end

  it 'must raise exception when line is malformed' do
    parser = Parser.new
    file_path = File.absolute_path(File.join(__dir__, '..', 'fixtures', 'malformed_line.log'))
    expect { parser.parse file_path }.to raise_exception LogMalformed
  end

  it 'should not raise exception when line is empty' do
    parser = Parser.new
    file_path = File.absolute_path(File.join(__dir__, '..', 'fixtures', 'valid_oneline.log'))
    expect { parser.parse file_path }.to_not raise_exception LogMalformed
  end

  it 'should raise exception when page is invalid' do
    parser = Parser.new
    file_path = File.absolute_path(File.join(__dir__, '..', 'fixtures', 'invalid_page.log'))
    expect { parser.parse file_path }.to raise_exception LogMalformed
  end

  it 'should raise exception when address is invalid' do
    parser = Parser.new
    file_path = File.absolute_path(File.join(__dir__, '..', 'fixtures', 'invalid_addr.log'))
    expect { parser.parse file_path }.to raise_exception LogMalformed
  end
end

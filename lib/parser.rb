class FileNotFound < StandardError
  def initialize(file_path)
    super "Failed to find file #{file_path}"
  end
end

class LogMalformed < StandardError
end

class PageVisit
  attr_reader :page, :counter

  # @param [String] page
  def initialize(page)
    @page = page.to_sym
    @counter = 0
    @addresses = {}
  end

  def equal?(o)
    page == o.page
  end

  def add_visit(addr)
    addr = addr.to_sym
    @addresses[addr] ||= 0
    @addresses[addr] += 1
    @counter += 1
  end

  # @return [Array<String>]
  def addresses
    @addresses.keys
  end

  # @return [Integer]
  def addresses_count
    @addresses.size
  end
end

class Store
  attr_reader :pages, :uniq_visit_per_page, :visit_per_page

  def initialize
    @visit_per_page = {}
    @uniq_visit_per_page = {}
    @pages = {}
  end

  # @param [String] page
  def update_page(page, addr)
    current = page_visit page

    # Old data processing
    init_cache(current)
    flush_old(current)

    current.add_visit addr

    # New data processing
    init_cache(current)
    push_new(current)
  end

  private

  def push_new(current)
    @visit_per_page[current.counter] << current
    @uniq_visit_per_page[current.addresses_count] << current
  end

  def flush_old(current)
    # Remove visit from cache
    @visit_per_page[current.counter].reject! { |p| p.page == current.page }
    @uniq_visit_per_page[current.addresses_count].reject! do |p|
      p.page == current.page
    end

    # Remove useless keys
    if @visit_per_page[current.counter].empty?
      @visit_per_page.delete(current.counter)
    end
    if @uniq_visit_per_page[current.addresses_count].empty?
      @uniq_visit_per_page.delete(current.addresses_count)
    end
  end

  def init_cache(current)
    @visit_per_page[current.counter] ||= []
    @uniq_visit_per_page[current.addresses_count] ||= []
  end

  # @param [String] page
  # @return [PageVisit]
  def page_visit(page)
    @pages[page] ||= PageVisit.new(page)
  end
end

class Parser
  def initialize
    @visit_per_page = {}
    @uniq_visit_per_page = {}
    @pages = {}
    @store = Store.new
  end

  # @param [String] file_path
  # @return [Store]
  def parse(file_path)
    validate_input! file_path
    File.open(file_path, &method(:consume_content))
    @store
  end

  private

  def consume_content(f)
    f.each_line(&method(:consume_line))
  end

  def consume_line(line)
    parts = line.strip.split ' '
    invalid_line!(line) if parts.size != 2
    page, addr = parts
    invalid_web_page!(page) unless web_page?(page)
    invalid_ip_addr!(addr) unless ip_addr?(addr)
    @store.update_page page, addr
  end

  def invalid_ip_addr!(addr)
    raise LogMalformed.new("invalid addr #{addr.inspect}")
  end

  def invalid_web_page!(page)
    raise LogMalformed.new("invalid page #{page.inspect}")
  end

  def invalid_line!(line)
    raise LogMalformed.new("invalid line #{line.inspect}")
  end

  def web_page?(page)
    page.start_with? '/'
  end

  def ip_addr?(addr)
    addr.match /\d{1,4}\.\d{1,4}\.\d{1,4}\.\d{1,4}/
  end

  def validate_input!(file_path)
    return if File.exist? file_path
    raise FileNotFound.new(file_path)
  end
end

class Printer
  # @param [Store] store
  # @param [IO] output
  def initialize(store, output = $stdout)
    @store = store
    @out = output
  end

  def print
    @store.visit_per_page.
      sort_by { |k, _v| -k }.
      flat_map { |(_, v)| v }.
      each do |visit|
      @out.write "#{visit.page} #{visit.counter} visits\n"
    end

    @out.write "\n"
    @out.flush

    @store.uniq_visit_per_page.
      sort_by { |k, _v| -k }.
      flat_map { |(_, v)| v }.
      each do |visit|
      @out.write "#{visit.page} #{visit.addresses_count} unique views\n"
    end
    @out.flush
  end
end

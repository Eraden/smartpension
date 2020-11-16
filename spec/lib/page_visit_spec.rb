require 'spec_helper'

RSpec.describe PageVisit do
  it 'must update visit counter' do
    visit = PageVisit.new '/a'
    visit.add_visit '0.0.0.0'

    expect { visit.add_visit '0.0.0.0' }.to(
      change { visit.counter }.by(1)
    )
  end

  it 'should not update addresses counter if address is not unique' do
    visit = PageVisit.new '/a'
    expect(visit.addresses_count).to be 0

    visit.add_visit '0.0.0.0'
    expect(visit.addresses_count).to be 1

    visit.add_visit '0.0.0.0'
    expect(visit.addresses_count).to be 1
  end

  it 'must update addresses counter if address is unique' do
    visit = PageVisit.new '/a'
    expect(visit.addresses_count).to be 0

    visit.add_visit '0.0.0.0'
    expect(visit.addresses_count).to be 1

    visit.add_visit '0.0.0.1'
    expect(visit.addresses_count).to be 2
  end
end

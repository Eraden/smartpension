require 'spec_helper'

RSpec.describe Store do
  it 'must add new page visit' do
    store = Store.new
    expect { store.update_page '/a', '0.0.0.0' }.to(
      change { store.pages.keys.size }.by(1)
    )
  end

  it 'must update uniq when new address was added' do
    store = Store.new
    store.update_page '/a', '0.0.0.0'
    expect(store.uniq_visit_per_page[1].count).to equal 1
    expect(store.uniq_visit_per_page[1].first).to equal PageVisit.new('/a')

    store.update_page '/a', '0.0.0.1'
    expect(store.uniq_visit_per_page[1]).to be nil

    expect(store.uniq_visit_per_page[2].count).to equal 1
    expect(store.uniq_visit_per_page[2].first).to equal PageVisit.new('/a')
  end

  it 'must update unique counter only for changed when new address was added' do
    store = Store.new
    store.update_page '/a', '0.0.0.0'
    store.update_page '/b', '0.0.0.0'

    expect(store.uniq_visit_per_page[1].count).to equal 2
    expect(store.uniq_visit_per_page[1].first).to equal PageVisit.new('/a')
    expect(store.uniq_visit_per_page[1].last).to equal PageVisit.new('/b')

    store.update_page '/a', '0.0.0.1'
    expect(store.uniq_visit_per_page[1].count).to equal 1
    expect(store.uniq_visit_per_page[1].first).to_not equal PageVisit.new('/a')
    expect(store.uniq_visit_per_page[1].first).to equal PageVisit.new('/b')

    expect(store.uniq_visit_per_page[2].count).to equal 1
    expect(store.uniq_visit_per_page[2].first).to equal PageVisit.new('/a')
  end
end

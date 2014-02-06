require 'spec_helper'

describe 'public page routes' do

  routes { Landable::Engine.routes }

  context 'should match' do
    let(:author) { create :author }
    let(:pages) do
      [ create(:page, status_code: 200),
        create(:page, status_code: 301, redirect_url: 'http://google.com/'),
        create(:page, status_code: 302, redirect_url: 'http://foobar.com/'),
      ].each do |page|
        page.publish! author: author, status_code: 200
      end
    end

    specify 'published pages' do
      pages.each do |page|
        expect(get: page.path).to route_to(controller: 'landable/public/pages', action: 'show', url: page.path[1..-1])
      end
    end

    specify 'not currently a 410' do
      page = create :page, status_code: 410
      page.publish! author: create(:author)

      page.status_code = 200
      page.save
      page.publish! author: create(:author)

      expect(get: page.path).to be_routable
    end
  end

  context 'should not match' do
    specify 'random stuff' do
      expect(get: '/foobar').to_not be_routable
    end

    specify 'unpublished pages' do
      page = create :page
      expect(get: page.path).to_not be_routable
    end
  end
end

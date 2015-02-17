xml.instruct!
xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @result.each do |p|
    xml.url do
      xml.loc construct_url(p, @locale)
      next if p.kind_of?(String)
      if p.xml_changefreq
        xml.changefreq p.xml_changefreq
      end
      if p.xml_update
        xml.lastmod p.xml_update.iso8601
      end
      if p.xml_priority
        xml.priority p.xml_priority
      end
    end
  end
end

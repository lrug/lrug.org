---
published_at: 2008-04-17 08:58:29 Z
title: As XML
created_at: 2008-04-17 15:57:41 Z
updated_at: 2013-02-12 23:09:21 Z
status: Published
created_by:
  email: murray.steele@gmail.com
  name: Murray Steele
layout: false
---

xml.instruct!
xml.content do
  xml.members do
    data.members.each do |member|
      xml.li class: 'vcard' do
        xml.a class: 'url', href: member.url, title: member.url do
          xml.span member.fn, class: 'fn'
        end
      end
    end
  end
end

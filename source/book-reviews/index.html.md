--- 
published_at: 2007-05-25 00:00:00 Z
updated_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
title: Book Reviews
created_at: 2007-05-25 09:30:44 Z
slug: book-reviews
breadcrumb: Book Reviews
layout: books
parts: 
  sidebar: 
    :content: |
      ### Reviews by Month
      <r:find url="/book-reviews/"><r:children:each order="desc">
      <r:header>* [<r:date format="%B %Y" />](<r:date format="/book-reviews/%Y/%m/" />)</r:header>
      </r:children:each></r:find>
    :filter: .md
updated_at: 2013-02-23 13:58:46 Z
status: Published
created_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
class_name: ArchivePage
---

LRUG members occasionally write book reviews of Ruby books.  We're collecting them here.

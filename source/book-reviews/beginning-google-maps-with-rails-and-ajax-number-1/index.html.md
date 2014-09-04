--- 
published_at: 2007-05-25 05:15:26 Z
title: "Beginning Google Maps with Rails and AJAX #1"
created_at: 2007-05-25 09:52:29 Z
slug: beginning-google-maps-with-rails-and-ajax-1
breadcrumb: "Beginning Google Maps with Rails and AJAX #1"
layout: book-review
parts: 
- extended
updated_at: 2013-02-12 23:09:15 Z
status: Published
created_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
class_name: ""
excerpt: |
  Graham Seaman reviews his copy of ['Beginning Google Maps Applications with Rails and Ajax - from novice to
  professional' by A. Lewis](http://www.amazon.co.uk/Beginning-Google-Maps-Applications-Rails/dp/1590597877/ref=sr_1_2/203-7531475-6650320?ie=UTF8&s=books&qid=1180086616&sr=1-2),  published by [Apress](http://www.apress.com/)
---

As it says on the tin, this book covers Google maps applications, that is, the Google API, rather than generic mapping principles. There is one very short chapter on projections of the surface of a sphere onto two dimensions, but that is it - this is not a GIS textbook. It is slightly unclear what level it is aimed at; as hinted by the title, it is either 'beginning' Google map applications, or 'from novice to professional'.  My guess would be that the 'beginning' version was the authors' choice and 'from novice to professional' added by the marketing department. The book does start with extremely simple examples (pretty much identical to what you get from Google's own site) and work towards gradually more complex applications, but from my personal experience of implementing just one Google map application the level of complexity of the final parts of the book is one you are likely to hit not long after starting to use the API, and not really one you could call 'professional'.

In introducing the Google API the book inevitably talks about Javascript much more than Rails. In part this is because the book is a rewrite of an earlier PHP version, in part because where the Ruby part of Rails is needed everything 'just works', so that the amount of Rails code needed is minimal (on the other hand the authors do spend a fair amount of time warning about potential pitfalls with Prototype, the Ajax library in Rails and ways round them). The meat of the book is therefore in the javascript applications presented, which are both clear and generally useful (though not always complete - the full code is available from the book's website).

The biggest downside of the book for me was not the fault of the authors, but of the British government. The book is oriented to the US in particular, and in general to countries which make their geographical data freely available to their populations. Some chapters are based on the assumption that you can do direct lookups of latitude and longitude from postcodes, or that large geographical datasets with all kinds of interesting information are freely available for experimentation. This makes the longer practical applications simply irrelevant to anyone British who wishes to produce real applications without large amounts of investment. The one example of UK-specific mapping given uses a file of 2,800 postcodes they found 'floating round the internet'. British users could do with a book which discusses such topics as organised and reliable attempts to bypass government-created restrictions on geocoding, how to convert UK Northing/Easting data to Google's latitude and longitude, how to make use of OpenStreetMap data, etc. This isn't that book, and doesn't claim to be.

Conclusion: this is a reasonable introduction to the Google map API from the US point of view. For a British user it does not give you much beyond what is available from Google itself, apart from the convenience of having all the information in one place wrapped around with a readable presentation.




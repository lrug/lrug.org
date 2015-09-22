---
updated_by:
  email: murray.steele@gmail.com
  name: Murray Steele
created_by:
  email: murray.steele@gmail.com
  name: Murray Steele
category: meeting
title: June 2013 Meeting
updated_at: 2013-05-28 11:27:02 Z
published_at: 2013-05-25 00:00:00 Z
created_at: 2013-05-25 11:40:27 Z
sponsors:
  - :name: Yammer
parts: {}
status: Published
---

The June 2013 meeting of LRUG will be on *Monday* the 10th of June, from 6:30pm to 8:00pm.  Our hosts [Skills Matter](http://skillsmatter.com/) will be providing the space, at their offices on Goswell Road; [The Skills Matter eXchange](http://skillsmatter.com/location-details/design-architecture/484/96).  <a href="#jun13registration">Registration details are given below</a>.

Agenda
------

### State Transitions Are People Too

[JB Steadman](https://twitter.com/jbsteadman) says:

> In this talk I present a simple ActiveRecord-based alternative
> to the many popular state machine gems.
>
> Suppose you're dealing with a school application system.
> Applications can be submitted, rejected, approved. Then
> you would have
>
> ``class Submission < StateTransition end``
>
> and so on. StateTransition is an STI subclass of
> ActiveRecord::Base.
>
> Inside each 'concrete' transition subclass, AR
> validations determine whether the transition can be
> created, given current system state. Callbacks make
> changes to other models that result from the
> transitions, as well as trigger other effects like emails.
>
> This shifts emphasis from the models to the transitions
> themselves. Model classes don't get cluttered with
> logic related to multiple transitions - that logic
> lives in the transition classes. It works nicely
> with REST. You are literally creating an Approval,
> rather than "approving". Logging of transitions is
> front and center. Nobody has to learn a new lib and
> you're never beholden to yesteryear's state machine
> gem-of-the-month.

JB originally proposed this talk for [Ruby Manor 4](http://rubymanor.org/4/) and you can read more about [his proposal on vestibule](http://vestibule.rubymanor.org/proposals/10)

### Application Example based on Gov.uk public code

[Jairo Diaz](http://www.codescrum.com) says:

> This talk describes an experience of reusing the public code
> available from the [GOV.UK project](https://www.gov.uk). It
> shows how we can implement custom customer service flows
> based on the [SmartAnswers project](https://github.com/alphagov/smart-answers).

Pub
---

We'll finish the formal talk-based part of the meeting at about 8pm and start the informal pub-based part about 5 minutes later in [The Slaughtered Lamb](http://www.theslaughteredlambpub.com/).  If you can't make the talks, do come along just for the pub, someone can get you caught up on what happened and no-one will know you weren't there!

{::sponsor name="Yammer" size="main" /}

Also, the nice folks at [Yammer](http://www.yammer.com/) are putting some money behind the bar to provide some drinks for us, so there are even more reasons to make it along!

Registration <a name="jun13registration">&nbsp;</a>
---------------------------------------------------

To secure a place at the meeting you *must* [register with our hosts Skills Matter](http://skillsmatter.com/event/ajax-ria/lrug-june-meetup).  It helps to make sure we have the room laid out with enough chairs, and in extreme cases that we get priority on the larger rooms over other groups using the space on the same night.  Also, it's polite (don't forget [MINASWAN](http://oreilly.com/ruby/excerpts/ruby-learning-rails/ruby-glossary.html#I_indexterm_d1e32036)), so please do [register with Skills Matter](http://skillsmatter.com/event/ajax-ria/lrug-june-meetup).

You can also follow [this meeting on lanyrd](http://lanyrd.com/2013/lrug-june/), but this is not a meaningful way to tell Skills Matter you wish to attend.  It's just for the lols, innit?

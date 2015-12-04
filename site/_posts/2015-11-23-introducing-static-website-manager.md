---
layout: post
title: 'Introducing Static Website Manager: A Jekyll CMS Your Whole Team Can Enjoy'
author: Theodore Kimble
excerpt: Static Website Manager is a <span class="bg-warning">new web-based CMS for your existing Jekyll website</span> or blog. We offer a collaborative git-based environment, a standardized content management system with live website previews, external deployments to your favorite hosting services, and form responders to bring your static website to life!
---

## Why another Website CMS?

I built Static Website Manager to solve a problem I first experienced over a decade ago: <span class="bg-warning">as a web designer, how do I provide uncompromising design work while enabling my clients and colleagues to control their own content?</span> There’s two sides to this problem.

On one hand, there’s a number of open-source content management systems that allow you to fully customize your website design. Wordpress, Drupal and Joomla all make it relatively easy for your team to write blog posts and edit pages. But these systems having moving parts that constantly rely on a running web server and database to compile your website for every single visit. This can be slow, error-prone and require maintenance even if you or your team are not making any changes.

On the other hand, there’s plenty of affordable website hosting services that hide the complexity of running a web server from you, but their options are even more limited. You must often select one of their few free themes or pay additional fees for their premium themes. At best they’ll let you customize their templates in accordance with their system and syntax. Weebly, Squarespace, Typepad and Wordpress.com are all good examples of these services.

## Liberate Website Designers

Static Website Manager solves our problem firstly by allowing website designers to use the open-source static website generator <a href="http://jekyllrb.com" target="_blank">Jekyll</a>. Because it’s a static website generator there are no moving parts – not constantly, that is. Jekyll still allows designers to use complex layouts and templates to compose beautiful websites. But rather than needing to be compiled for every request, Jekyll websites can be compiled once and then deployed as a static website to a service like Amazon AWS S3 (likely for just pennies per month).

## Empower Clients and Content Creators

The downside of static website generators is that anyone wishing to contribute must do so in the source code of the website repository itself. That might require potential contributors to know a few different templating languages, not to mention version control or command line tools!

This is where Static Website Manager comes in: we provide a standard content management system on top of your existing Jekyll website. We empower your team to write blog posts, edit webpages and manage data just like they’re used to. Plus, with smart Front Matter support you can provide powerful design customization that’s just a checkbox or dropdown away!

Static Website Manager works great with teams because it’s built on top of your Jekyll website’s git repository. Each user gets their own staging branch and can freely preview changes without the fear of breaking the production website. You can checkout feature branches, and it’s easy to view the project history or even go back in time to an earlier version!

## Go Further with Static Websites

All signed-in team member can preview all of their branches’ compiled websites through secure Static Website Manager URLs. You can also connect external deployments to any branch to have its compiled website be deployed to the associated location any time there’s a new change. Static Website Manager launches with support for deploying to <a href="https://aws.amazon.com/s3/" target="_blank">Amazon AWS S3</a> buckets.

Finally, Static Website Manager takes your static website to a new level with Form Responders! Now there’s no need to sign up for a third-party service to collect emails or notify you of appointments – Form Responders provide a form submission endpoint that you can use to accept data from your static website. We’ll notify up to 10 emails with the contents of the form submission and will even commit that data back into one of your repository’s data files!

<div class="text-center m-y-lg">
  <p class="lead"><a href="/subscribe" class="btn btn-lg btn-success">Try <span class="hidden-xs">Static Website Manager</span> Free for 14 Days</a></p>
</div>

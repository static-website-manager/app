---
layout: post
title: 'New Feature: Restore and Remove Commits'
author: Theodore Kimble
excerpt: We’re excited to release a pair of new features today. You can now restore and remove existing commits from our web-based interface. Restoring commits is great when you want to quickly go back in time without rewriting your history. We’ll add a single new commit with all of the changes necessary to restore your branch. And you can now remove any single commit, too. This rewrites your history, so it’s best for newer changes on your staging branch that haven’t been merged to production.
---

<p><img src="{% asset_path post-screenshot-restore-remove-commits.png %}" alt="Easily Restore and Remove Commits with the Click of a Button" class="thumbnail" /></p>
<p>You’ll now find links to “Restore” or “Remove” any commit on your branch. Restoring commits is safer, but removing commits can be really useful, particularly before you’ve merged your changes to a shared branch. Both links points to confirmation screens that explain these notes in more detail.</p>

## Restore Your Branch to a Specific Commit

<div class="panel panel-default">
  <div class="panel-heading panel-heading-sm">
    <img src="{% asset_path browser-icons.png %}" alt="" />
  </div>
  <img src="{% asset_path post-screenshot-restore-commit.png %}" alt="Restoring commits is a safe operation that preserves your history. A new commit will added that restores your branch to the same state as this commit. More specifically, we will run git commit revert with the --no-commit option." />
</div>

## Delete a Single Commit From Your Branch

<div class="panel panel-default display-inline-block">
  <div class="panel-heading panel-heading-sm">
    <img src="{% asset_path browser-icons.png %}" alt="" />
  </div>
  <img src="{% asset_path post-screenshot-remove-commit.png %}" alt="Restoring commits is a safe operation that preserves your history. A new commit will added that restores your branch to the same state as this commit. More specifically, we will run git commit revert with the --no-commit option." />
</div>

<div class="text-center m-y-lg">
  <p class="lead"><a href="/subscribe" class="btn btn-lg btn-success">Try <span class="hidden-xs">Static Website Manager</span> Free for 14 Days</a></p>
</div>

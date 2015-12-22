---
layout: post
title: 'New Feature: Squash Your Staging Work into a more Meaningful Commit Message when Merging to Production'
author: Theodore Kimble
excerpt: There’s now a great new method in Static Website Manager of merging your work into the production branch. You can now squash all of the unmerged commits in your branch into a single commit with a more meaningful commit message; we’ll then perform a fast-forward merge to ensure the production branch is up-to-date. This is a new option, and the default option will still retain all of your unmerged commits in addition to adding an explicit merge commit to both branches.
---

<img src="{% asset_path post-screenshot-squash-commits.png %}" alt="Easily Choose Whether to Keep Your Existing Commits and Add an Explicit Merge Commit or Squash All Unmerged Commits and Perform a Fast-Forward Production Merge" class="center-block thumbnail" />

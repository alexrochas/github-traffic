require 'octokit'
require 'pp'
require 'dotenv/load'

client = Octokit::Client.new(:login => 'alexrochas', :password => ENV['GITHUB_PASS'], per_page: 200)
# client.auto_paginate = true

# pp client.repos
repos = client
          .repos
          .select {|repo| !repo.private }
          .map {|repo| repo.full_name }
          .map { |repo| {:repo => repo, :views => client.views(repo, {accept: "application/vnd.github.squirrel-girl-preview+json"})} }

repos.size

repos.sort_by { |repo|
    -repo[:views][:uniques]
  }.take(10).each_with_index { |repo, index|
    puts "#{index+1}. #{repo[:repo]} with #{repo[:views][:uniques]} unique views"
  }

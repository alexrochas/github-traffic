require 'octokit'
require 'pp'
require 'dotenv/load'
require 'ruby-progressbar'

client = Octokit::Client.new(:login => 'alexrochas', :password => ENV['GITHUB_PASS'], per_page: 200)
client.auto_paginate = true

repos = client
          .repos
          .select {|repo| !repo.private }
          .tap {|repos|
            @progressbar = ProgressBar.create(total: repos.size, length: 50, format: '%t|%B|%c/%C')
          }
          .map {|repo| repo.full_name }
          .map { |repo|
            @progressbar.increment
            {:repo => repo, :views => client.views(repo, {accept: "application/vnd.github.squirrel-girl-preview+json"})}
          }

puts "\n"

repos.sort_by { |repo|
    -repo[:views][:uniques]
  }.take(10).each_with_index { |repo, index|
    puts "#{index+1}. #{repo[:repo]} with #{repo[:views][:uniques]} unique views"
  }

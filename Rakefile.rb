require "middleman-gh-pages"


desc "Build Middleman Github Pages"
task :build  do
	p "## Building Middleman Github Pages"
	system "bundle exec rake build"
end


desc "Deploy Middleman Github Pages"
task :deploy  do
	p "## Deploying Middleman Github Pages"
	system "bundle exec rake publish ALLOW_DIRTY=true"
end


desc "build and deploy"
task :publish do
	Rake::Task["build"].invoke
	Rake::Task["deploy"].invoke
end
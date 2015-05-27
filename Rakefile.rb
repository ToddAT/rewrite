require "middleman-gh-pages"


desc "build static pages"
task :build_gh do
  p "## Compiling static pages"
  system "bundle exec rake build"
end

desc "deploy to github pages"
task :deploy do
  p "## Deploying to Github Pages"
  cd "build" do
    system "git add -A"
    message = "Site updated at #{Time.now.utc}"
    p "## Commiting: #{message}"
    system "git commit -m \"#{message}\""
    p "## Pushing generated website"
    system "git push origin gh-pages"
    p "## Github Pages deploy complete"
  end
end

desc "build and deploy to github pages"
task :publish_gh do
  Rake::Task["build_gh"].invoke
  Rake::Task["deploy"].invoke
end
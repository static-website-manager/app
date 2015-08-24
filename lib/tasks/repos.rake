namespace :repos do
  namespace :fixtures do
    desc 'Push the sample test website data to the bare repository'
    task push: :environment do
      raise ArgumentError, 'must be run in test mode' unless Rails.env.test?

      sample_website = Website.find_by_name!('Sample')
      sample_website.send(:rugged_repository)
      sample_website_dir = Rails.root.join('test', 'fixtures', 'repos', 'sample_website')

      `
        cd #{sample_website_dir};
        git push #{sample_website.send(:repository_pathname)} master;
        git push #{sample_website.send(:repository_pathname)} custom
      `
    end
  end
end

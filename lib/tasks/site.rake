namespace :site do
  desc 'Build static site and recursively copy contents to /app/public, ignoring the /app/public/assets directory.'
  task build: :environment do |task|
    public_path = Rails.root.join('public')
    public_assets_path = public_path.join('assets')
    temp_public_path = Rails.root.join('tmp', 'public')
    temp_public_assets_path = temp_public_path.join('assets')
    site_path = Rails.root.join('site')

    FileUtils.rm_rf(temp_public_path)
    FileUtils.mkdir_p(temp_public_path)
    FileUtils.mkdir_p(public_path)

    system "jekyll build --source #{site_path} --destination #{temp_public_path}"

    if File.directory?(public_assets_path)
      FileUtils.cp_r(public_assets_path, temp_public_assets_path)
    end

    public_filenames = Dir[public_path.join('**', '*')].select do |filename|
      File.file?(filename)
    end.map do |filename|
      filename.sub(/#{public_path}\//, '')
    end

    temp_public_filenames = Dir[temp_public_path.join('**', '*')].select do |filename|
      File.file?(filename)
    end.map do |filename|
      filename.sub(/#{temp_public_path}\//, '')
    end

    (public_filenames - temp_public_filenames).each do |filename|
      FileUtils.rm(public_path.join(filename))
    end

    public_dirnames = Dir[public_path.join('**', '*')].select do |dirname|
      File.directory?(dirname)
    end.map do |dirname|
      dirname.sub(/#{public_path}\//, '')
    end

    temp_public_dirnames = Dir[temp_public_path.join('**', '*')].select do |dirname|
      File.directory?(dirname)
    end.map do |dirname|
      dirname.sub(/#{temp_public_path}\//, '')
    end

    (public_dirnames - temp_public_dirnames).each do |dirname|
      FileUtils.rm_r(public_path.join(dirname))
    end

    FileUtils.cp_r(temp_public_path, Rails.root)
    FileUtils.rm_rf(temp_public_path)
  end
end

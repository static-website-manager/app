require ::File.expand_path('../../../config/environment',  __FILE__)

module Jekyll
  class AssetPathTag < Liquid::Tag
    def initialize(tag_name, asset_name, tokens)
      super
      @asset = Rails.application.assets[asset_name.strip]
    end

    def render(context)
      if @asset
        if Rails.env.production?
          "/assets/#{@asset.digest_path}"
        else
          "/assets/#{@asset.logical_path}"
        end
      else
        ''
      end
    end
  end
end

Liquid::Template.register_tag('asset_path', Jekyll::AssetPathTag)

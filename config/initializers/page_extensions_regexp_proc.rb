PAGE_EXTENTIONS_REGEXP_PROC = Proc.new do |page_extensions|
  /\.(#{page_extensions.join('|')})\z/
end

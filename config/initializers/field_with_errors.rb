ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag =~ /<(input|textarea)/ && html_tag !~ /type="hidden"/
    "<div class=\"has-error has-feedback\">#{html_tag} <span class=\"glyphicon glyphicon-remove form-control-feedback\" aria-hidden=\"true\"></span></div>".html_safe
  elsif html_tag =~ /<(label)/
    "<div class=\"has-error has-feedback\">#{html_tag}</div>".html_safe
  else
    html_tag
  end
end

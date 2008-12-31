class Exceptions < Merb::Controller
  self._template_roots << [Feather.slice_path_for(:view), :_template_location] if Feather.respond_to?(:slice_path_for)

  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

  def unauthenticated
    render :format => :html, :layout => "admin"
  end
end
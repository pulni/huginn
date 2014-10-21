module ApplicationHelper
  def nav_link(name, path, options = {}, &block)
    if glyphicon = options.delete(:glyphicon)
      name = "<span class='glyphicon glyphicon-#{glyphicon}'></span> ".html_safe + name
    end
    content = link_to(name, path, options)
    active = current_page?(path)
    if block
      # Passing a block signifies that the link is a header of a hover
      # menu which contains what's in the block.
      begin
        @nav_in_menu = true
        @nav_link_active = active
        content += capture(&block)
        class_name = "dropdown dropdown-hover #{@nav_link_active ? 'active' : ''}"
      ensure
        @nav_in_menu = @nav_link_active = false
      end
    else
      # Mark the menu header active if it contains the current page
      @nav_link_active ||= active if @nav_in_menu
      # An "active" menu item may be an eyesore, hence `!@nav_in_menu &&`.
      class_name = !@nav_in_menu && active ? 'active' : ''
    end
    content_tag :li, content, class: class_name
  end

  def yes_no(bool)
    content_tag :span, bool ? 'Yes' : 'No', class: "label #{bool ? 'label-info' : 'label-default' }"
  end

  def working(agent)
    if agent.disabled?
      link_to 'Disabled', agent_path(agent), class: 'label label-warning'
    elsif agent.dependencies_missing?
      content_tag :span, 'Missing Gems', class: 'label label-danger'
    elsif agent.working?
      content_tag :span, 'Yes', class: 'label label-success'
    else
      link_to 'No', agent_path(agent, tab: (agent.recent_error_logs? ? 'logs' : 'details')), class: 'label label-danger'
    end
  end

  def omniauth_provider_icon(provider)
    case provider.to_sym
    when :twitter, :tumblr, :github, :dropbox
      content_tag :i, '', class: "fa fa-#{provider}"
    else
      content_tag :i, '', class: "fa fa-lock"
    end
  end

  def omniauth_provider_name(provider)
    t("devise.omniauth_providers.#{provider}")
  end

  def omniauth_button(provider)
    link_to [
      omniauth_provider_icon(provider),
      content_tag(:span, "Authenticate with #{omniauth_provider_name(provider)}")
    ].join.html_safe, user_omniauth_authorize_path(provider), class: "btn btn-default btn-service service-#{provider}"
  end

  def service_label_text(service)
    "#{omniauth_provider_name(service.provider)} - #{service.name}"
  end

  def service_label(service)
    content_tag :span, [
      omniauth_provider_icon(service.provider),
      service_label_text(service)
    ].join.html_safe, class: "label label-default label-service service-#{service.provider}"
  end
end

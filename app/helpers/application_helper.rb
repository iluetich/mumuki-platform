module ApplicationHelper
  include LinksRendering
  include Icons
  include Flags

  def limit(items, preserve_order = false)
    limited = items.last(5)
    limited = limited.reverse unless preserve_order
    limited
  end

  def highlighted_code(lang, code)
    "<pre><code class=\"hljs #{lang.name}\">#{code}</code></pre>".html_safe
  end

  def paginate(object, options={})
    "<div class=\"text-center\">#{super(object, {theme: 'twitter-bootstrap-3'}.merge(options))}</div>".html_safe
  end

  def taglist_tag(tags)
    #TODO use it also for writable inputs
    box_options, input_options = ['readonly', 'readonly disabled']
    %Q{<div class="taglist-box #{box_options}">
        <input type="text" value="#{tags}" data-role="tagsinput" #{input_options}>
       </div>}.html_safe
  end

  def link_to_tag_list(tags)
    tags.map { |tag| link_to "##{tag}", exercises_path(q: tag) }.join(', ').html_safe
  end

  def active_if(expected)
    'class="active"'.html_safe if expected == @current_tab
  end

  def time_ago_in_words_or_never(date)
    date ? time_ago_in_words(date) : t(:never)
  end

  def tab_list(tabs)
    ('<ul class="nav nav-tabs" role="tablist">' +
        tabs.map do |tab|
%Q{<li role="presentation" class="#{'active' if tab == tabs.first }">
<a href="##{tab}-panel" aria-controls="#{tab}" role="tab" data-toggle="tab">#{t(tab)}</a>
</li>}
        end.join("\n") +
        '</ul>').html_safe
  end

  def follow_button(user)
    restricted_to_other_user user do
      if current_user.following?(user)
        render 'users/unfollow', user: user, button_class: 'btn-warning'
      else
        render 'users/follow', user: user, button_class: 'btn-primary'
      end
    end
  end
end

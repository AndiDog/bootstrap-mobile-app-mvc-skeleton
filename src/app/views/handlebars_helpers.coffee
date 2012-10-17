Handlebars.registerHelper 'list', (items, options) ->
  out = '<ul class="nav nav-tabs nav-stacked">'

  for item in items
    out += """
      <li>
        <a href="#" onclick="return false;">
            #{options.fn(item)}
            <span class="pull-right"><img src="images/right_arrow.png"/></span>
        </a>
      </li>
      """

  return out + '</ul>'
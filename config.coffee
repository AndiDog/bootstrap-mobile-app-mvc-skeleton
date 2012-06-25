exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
      order:
        before: [
          'vendor/scripts/console-helper.js',
          'vendor/scripts/jquery-1.7.2.js',
          'vendor/scripts/underscore-1.3.3.js',
          'vendor/scripts/backbone-0.9.2.js',
          'vendor/scripts/jqm-routing-patch.js',
          'vendor/scripts/jquery.mobile-1.1.0.js'
        ]

    stylesheets:
      defaultExtension: 'styl'
      joinTo: 'stylesheets/app.css'
      order:
        before: []
        after: []

    templates:
      defaultExtension: 'hbs'
      joinTo: 'javascripts/app.js'

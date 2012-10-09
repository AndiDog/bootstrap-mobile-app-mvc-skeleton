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
          'vendor/scripts/jquery-1.8.2.min.js',
          'vendor/scripts/underscore-1.3.3.js',
          'vendor/scripts/backbone-0.9.2.js',
          'vendor/scripts/jqm-routing-patch.js',
          'vendor/scripts/jquery.mobile-1.2.0.min.js'
        ]

    stylesheets:
      defaultExtension: 'styl'
      joinTo: 'stylesheets/app.css'
      order:
        before: []
        ###
        If you want to customize the jQM theme, replace the complete CSS file (jquery.mobile-1.2.0.min.css) by the base
        file (jquery.mobile.structure-1.2.0.min.css) and add your customizations like so (note the order):

        before: [
            # Additional customizations
            'app/views/styles/application.styl',

            # Your jQM theme (e.g. exported by Theme Roller)
            'app/views/styles/your-jquery-theme.css',

            # jQM basic CSS
            'vendor/styles/jquery.mobile.structure-1.1.0.css'
        ]
        ###
        after: []

    templates:
      defaultExtension: 'hbs'
      joinTo: 'javascripts/app.js'

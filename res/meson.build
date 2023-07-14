

# CURRENT_SOURCE_DIR relative to BUILDDIR
output_dir = './res'
# This is a hack to make sure below target was run. For some reason you can't use example from blueprint docs.

blueprints = custom_target('blueprints',
  input: files(
    'gtk/window.blp',
    'gtk/welcome.blp',
    'gtk/recent-connection.blp',
    'gtk/connection-form.blp',
    'gtk/query-view.blp'
  ),
#   This does not run if you use an dot (.)
  output: 'dot',
  command: [find_program('blueprint-compiler'), 'batch-compile', output_dir , '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)


sequelize_resources = gnome.compile_resources('sequelize_resources',
  'sequelize.gresource.xml',
  c_name: 'sequelize_resources',
  dependencies: [blueprints],
)
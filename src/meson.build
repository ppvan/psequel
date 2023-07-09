# Source code
sequelize_sources = [
  'application.vala',
  'ui/window.vala',
  'ui/index.vala',
  'models/connection.vala',
]

# UI code?
blueprints = files(
    'gtk/window.blp',
    'gtk/index.blp',
)

blp_target = custom_target(
    'blueprints',
    input: blueprints,
    output: '.',
    command: [ find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@' ],
)


sequelize_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
]

sequelize_sources += gnome.compile_resources('sequelize-resources',
  'sequelize.gresource.xml',
#   source_dir: 'data',
  c_name: 'sequelize',
  dependencies: blp_target
)

executable('sequelize', sequelize_sources,
vala_args: [ '--gresourcesdir=src/' ],
  dependencies: sequelize_deps,
       install: true,
)

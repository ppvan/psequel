# Source code
sequelize_sources = [
  'application.vala',
   'ui/connection_form.vala',
   'ui/recent_connection.vala',
   'ui/welcome.vala',
   'ui/window.vala',
  'models/connection.vala',
  'models/utils.vala',
  'services/query_service.vala',
  'services/resource_manager.vala',
]

# UI code?
blueprints = files(
    'gtk/window.blp',
    'gtk/welcome.blp',
    'gtk/recent-connection.blp',
    'gtk/connection-form.blp',
)


blp_target = custom_target(
    'blueprints',
    input: blueprints,
    output: '.',
    command: [ find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@' ],
)

sequelize_deps = [
  dependency('glib-2.0', version: '>=2.74'),
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('libpq'),


  valac.find_library('config', dirs: vapi_dir),
]

sequelize_sources += gnome.compile_resources('sequelize-resources',
  'sequelize.gresource.xml',
  c_name: 'sequelize',
  dependencies: blp_target
)

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Sequelize')
conf.set_quoted('G_LOG_DOMAIN', 'Sequelize')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)

add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)
add_project_arguments(['--gresourcesdir', 'src/' ], language: 'vala')
add_project_arguments(['--enable-experimental' ], language: 'vala')
# add_project_arguments(['-DG_LOG_DOMAIN=\"Sequelize\"' ], language: 'c')


executable('sequelize', sequelize_sources,
  dependencies: sequelize_deps,
  install: true,
)

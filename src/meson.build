# Source code
psequel_sources = [
    'application.vala',
    'ui/connection_form.vala',
    'ui/recent_connection.vala',
    'ui/welcome.vala',
    'ui/window.vala',
    'ui/query_view.vala',
    'models/connection.vala',
    'models/schema.vala',
    'models/table.vala',
    'models/utils.vala',
    'services/query_service.vala',
    'services/resource_manager.vala',
]


add_project_arguments(['--gresourcesdir', 'res/' ], language: 'vala')
add_project_arguments(['--enable-experimental' ], language: 'vala')

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Psequel')
conf.set_quoted('G_LOG_DOMAIN', 'Psequel')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)

psequel_deps = [
  dependency('glib-2.0', version: '>=2.74'),
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('libpq'),

  valac.find_library('config', dirs: vapi_dir),
]


add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)


executable('psequel', [psequel_resources, psequel_sources],
  dependencies: psequel_deps,
  install: true,
)

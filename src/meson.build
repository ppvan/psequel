# Source code
psequel_sources = [
    'application.vala',
    'ui/connection/ConnectionForm.vala',
    'ui/connection/ConnectionSidebar.vala',
    'ui/connection/ConnectionView.vala',


    'ui/schema/SchemaView.vala',
    'ui/schema/SchemaSidebar.vala',
    'ui/schema/SchemaMain.vala',
    
    'ui/schema/QueryEditor.vala',
    'ui/schema/QueryResult.vala',


    'ui/schema/TableStructureView.vala',
    'ui/schema/ViewStructureView.vala',
    'ui/schema/TableColumnInfo.vala',
    'ui/schema/TableForeignKeyInfo.vala',
    'ui/schema/TableIndexInfo.vala',

    'ui/schema/TableDataView.vala',
    'ui/schema/ViewDataView.vala',

    'ui/Window.vala',
    'ui/PreferencesWindow.vala',

    'models/Connection.vala',
    'models/Schema.vala',
    'models/Relation.vala',
    'models/Table.vala',
    'models/Query.vala',
    # 'models/utils.vala',

    'services/SQLService.vala',
    'services/NavigationService.vala',
    'services/ConnectionService.vala',
    'services/Container.vala',
    'services/ResourceManager.vala',
    'services/SchemaService.vala',
    'services/SQLCompletionProvider.vala',

    'repositories/ConnectionRepository.vala',
    'repositories/QueryRepository.vala',
    'repositories/SchemaRepository.vala',

    'viewmodels/ConnectionViewModel.vala',
    'viewmodels/QueryViewModel.vala',
    'viewmodels/QueryHistoryViewModel.vala',
    'viewmodels/BaseViewModel.vala',
    'viewmodels/SchemaViewModel.vala',
    'viewmodels/TableViewModel.vala',
    'viewmodels/TableStructureViewModel.vala',
    'viewmodels/ViewStructureViewModel.vala',
    'viewmodels/TableDataViewModel.vala',
    'viewmodels/ViewViewModel.vala',
    'viewmodels/ViewDataViewModel.vala',

    'utils/ObservableList.vala',
    'utils/ValueConverter.vala',
    'utils/Event.vala',
    'utils/helpers.vala',
    'utils/logging.vala',
    'utils/errors.vala',
]


# add_project_arguments(['--gresourcesdir', 'res/' ], language: 'vala')
# add_project_arguments(['--enable-experimental' ], language: 'vala')

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
  dependency('gtk4', version: '>=4.10'),
  dependency('libadwaita-1', version: '>= 1'),
  dependency('json-glib-1.0', version: '>= 1.6'),
  dependency('gtksourceview-5', version: '>= 5.0'),
  dependency('libpq', version: '>= 15.3'),
  dependency('pgquery-vala'),

  valac.find_library('config', dirs: vapi_dir),
]


add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)


executable('psequel', [blueprint_hack, psequel_resources, psequel_sources],
  dependencies: psequel_deps,
  vala_args: [
    '--gresourcesdir=' + blueprints_output_dir,
  ],
  install: true,
)

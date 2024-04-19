# Source code
psequel_sources = files([
    'models/Connection.vala',
    'models/Schema.vala',
    'models/Relation.vala',
    'models/Table.vala',
    'models/Query.vala',
    # 'models/utils.vala',

    'services/SQLService.vala',
    'services/SQLCompletionService.vala',
    'services/ExportService.vala',
    'services/NavigationService.vala',
    'services/StorageService.vala',
    'services/Container.vala',
    'services/ResourceManager.vala',
    'services/SchemaService.vala',
    'services/MigrationService.vala',

    'repositories/ConnectionRepository.vala',
    'repositories/QueryRepository.vala',
    'repositories/SchemaRepository.vala',

    'viewmodels/ConnectionViewModel.vala',
    'viewmodels/QueryViewModel.vala',
    'viewmodels/QueryHistoryViewModel.vala',
    'viewmodels/BaseViewModel.vala',
    'viewmodels/SchemaViewModel.vala',
    'viewmodels/TableViewModel.vala',
    'viewmodels/ViewStructureViewModel.vala',
    'viewmodels/TableDataViewModel.vala',
    'viewmodels/ViewViewModel.vala',
    'viewmodels/ViewDataViewModel.vala',

    'utils/ObservableList.vala',
    'utils/ValueConverter.vala',
    'utils/Event.vala',
    'utils/logging.vala',
    'utils/errors.vala',
    'utils/types.vala',
])

ui_sources = files([
    'ui/views/ConnectionView.vala',
    'ui/views/SchemaView.vala',
    'ui/schema/QueryResult.vala',
    'ui/schema/ViewStructureView.vala',
    'ui/schema/TableDataView.vala',
    'ui/schema/ViewDataView.vala',

    'ui/widgets/DataCell.vala',
    'ui/widgets/TableRow.vala',
    'ui/widgets/TableGraph.vala',
    'ui/widgets/Shape.vala',
    'ui/widgets/StyleSwitcher.vala',

    'ui/editor/QueryEditor.vala',
    'ui/Window.vala',
    'ui/PreferencesWindow.vala',

    'utils/helpers.vala',

])

# Create config data, this will create a config.h file, then be bind to Config class.

vapi_dir = join_paths(meson.current_source_dir(), 'vapi')
conf = configuration_data()

conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Psequel')
conf.set_quoted('G_LOG_DOMAIN', 'Psequel')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)


csv_dep = dependency('csv', required : false)
if not csv_dep.found()
  libsimple_proj = subproject('libcsv')
  libsimple_dep = libsimple_proj.get_variable('libcsv_deps')
endif

cc = meson.get_compiler('c')
math_dep = cc.find_library('m', required : false)


psequel_deps = [
  dependency('glib-2.0', version: '>=2.74'),
  dependency('gtk4', version: '>=4.10'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('json-glib-1.0', version: '>= 1.6'),
  dependency('gtksourceview-5', version: '>= 5.0'),
  dependency('libpq', version: '>= 15.3'),
  dependency('sqlite3'),
  csv_dep,
  math_dep,
  dependency('pgquery-vala'),
  valac.find_library('config', dirs: vapi_dir),
]


add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

psequel_sources_main = psequel_sources + ui_sources + files(['application.vala'])

executable(meson.project_name(), [psequel_resources, psequel_sources_main],
  dependencies: psequel_deps,
  vala_args: '--gresourcesdir=' + psequel_resources_dir,
  install: true,
)
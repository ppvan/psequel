# Source code
psequel_sources = files(
    'models/Connection.vala',
    'models/Query.vala',
    'models/Relation.vala',
    'models/Schema.vala',
    'models/Table.vala',
    'repositories/ConnectionRepository.vala',
    'repositories/QueryRepository.vala',
    'repositories/SchemaRepository.vala',
    'services/BackupService.vala',
    'services/Container.vala',
    'services/ExportService.vala',
    'services/MigrationService.vala',
    'services/NavigationService.vala',
    'services/ResourceManager.vala',
    'services/SQLCompletionService.vala',
    'services/TableColumnCompletionService.vala',
    'services/SQLService.vala',
    'services/SchemaService.vala',
    'services/StorageService.vala',
    'utils/Event.vala',
    'utils/ObservableList.vala',
    'utils/ValueConverter.vala',
    'utils/errors.vala',
    'utils/logging.vala',
    'utils/types.vala',
    'viewmodels/BaseViewModel.vala',
    'viewmodels/ConnectionViewModel.vala',
    'viewmodels/DataViewModel.vala',
    'viewmodels/QueryHistoryViewModel.vala',
    'viewmodels/QueryViewModel.vala',
    'viewmodels/SchemaViewModel.vala',
    'viewmodels/TableDataViewModel.vala',
    'viewmodels/TableViewModel.vala',
    'viewmodels/ViewDataViewModel.vala',
    'viewmodels/ViewStructureViewModel.vala',
    'viewmodels/ViewViewModel.vala',

)

ui_sources = files(
    'ui/PreferencesWindow.vala',
    'ui/Window.vala',
    'ui/editor/QueryEditor.vala',
    'ui/schema/QueryResult.vala',
    'ui/schema/TableDataView.vala',
    'ui/schema/TableStructureView.vala',
    'ui/schema/ViewDataView.vala',
    'ui/schema/ViewStructureView.vala',
    'ui/views/ConnectionView.vala',
    'ui/views/SchemaView.vala',
    'ui/widgets/WhereEntry.vala',
    'ui/widgets/BackupDialog.vala',
    'ui/widgets/EditRowDialog.vala',
    'ui/widgets/DataCell.vala',
    'ui/widgets/RestoreDialog.vala',
    'ui/widgets/Shape.vala',
    'ui/widgets/StyleSwitcher.vala',
    'ui/widgets/TableColumnInfo.vala',
    'ui/widgets/TableGraph.vala',
    'ui/widgets/TableIndexInfo.vala',
    'ui/widgets/TableRow.vala',
    'utils/helpers.vala',
)

# Create config data, this will create a config.h file, then be bind to Config class.

vapi_dir = join_paths(meson.current_source_dir(), 'vapi')
conf = configuration_data()

conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Psequel')
conf.set_quoted('G_LOG_DOMAIN', 'Psequel')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted(
    'DATADIR',
    join_paths(get_option('prefix'), get_option('datadir')),
)
conf.set_quoted(
    'GNOMELOCALEDIR',
    join_paths(get_option('prefix'), get_option('localedir')),
)
configure_file(output: 'config.h', configuration: conf)

cc = meson.get_compiler('c')
math_dep = cc.find_library('m', required: false)

psequel_deps = [
    # assume exists typical gtk system
    dependency('glib-2.0', version: '>=2.80'),
    dependency('gtk4', version: '>=4.16'),
    dependency('libadwaita-1', version: '>= 1.6'),
    dependency('json-glib-1.0', version: '>= 1.6'),
    dependency('gtksourceview-5', version: '>= 5.0'),
    dependency('libpq', version: '>= 15.3'),
    math_dep,

    # custom, fallback to subproject
    dependency('sqlite3', version: '>= 3.46'),
    dependency('pgquery-vala'),
    dependency('csv'),
    valac.find_library('config', dirs: vapi_dir),
]

add_project_arguments(
    [
        '--target-glib=2.80',
        '--vapidir', vapi_dir,
        '--gresourcesdir', psequel_resources_dir,
        '--enable-deprecated',
        '--pkg', 'csv'
    ],
    language: 'vala',
)


add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c',
)

add_project_arguments(
    [
        '-Wno-pointer-sign',
        '-Wno-deprecated-declarations',
        '-Wno-format',
        '-Wno-unused',
        '-Wno-address',
        '-Wno-switch',
        '-Wno-incompatible-pointer-types',
        '-Wno-discarded-qualifiers'
    ],
    language: 'c',
)

psequel_sources_main = psequel_sources + ui_sources + files('application.vala')

executable(
    app_name,
    [psequel_resources, psequel_sources_main],
    dependencies: psequel_deps,
    vala_args: [
        '--gresourcesdir=' + psequel_resources_dir,
    ],
    install: true,
)
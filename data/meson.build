desktop_file = i18n.merge_file(
        input: 'me.ppvan.psequel.desktop.in',
       output: 'me.ppvan.psequel.desktop',
         type: 'desktop',
       po_dir: '../po',
      install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif


appstream_file = i18n.merge_file(
        input: 'me.ppvan.psequel.metainfo.xml.in',
       output: 'me.ppvan.psequel.metainfo.xml',
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

# Disable redudant check.
appstreamcli = find_program('appstreamcli', required: false, disabler: true)
if appstreamcli.found()
  test('Validate appstream file', appstreamcli,
     args: ['validate', '--no-net', '--explain', appstream_file])
endif


install_data('me.ppvan.psequel.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file',
       compile_schemas,
       args: ['--strict', '--dry-run', meson.current_source_dir()])
endif

subdir('icons')

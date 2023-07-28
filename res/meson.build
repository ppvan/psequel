

# CURRENT_SOURCE_DIR relative to BUILDDIR
output_dir = meson.current_build_dir()
# This is a hack to make sure below target was run. For some reason you can't use example from blueprint docs.

blueprints = custom_target('blueprints',
  input: files(
    'gtk/connection-form.blp',
    'gtk/connection-recent.blp',
    'gtk/connection-view.blp',

    'gtk/main.blp',
    'gtk/query-view.blp',
    'gtk/query-editor.blp',
    'gtk/query-results.blp',
    
    'gtk/table-data-view.blp',
    
    'gtk/table-cols.blp',
    'gtk/table-fk.blp',
    'gtk/table-index.blp',
    'gtk/table-structure-view.blp',
    
    'gtk/window.blp',
  ),
  build_by_default: true,
#   This does not run if you use an dot (.)
  output: 'dot',
  command: [find_program('blueprint-compiler'), 'batch-compile', output_dir , '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)


psequel_resources = gnome.compile_resources('psequel_resources',
  'psequel.gresource.xml',
  c_name: 'psequel_resources',
  dependencies: [blueprints],
)
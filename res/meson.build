

# CURRENT_SOURCE_DIR relative to BUILDDIR
blueprints_output_dir = meson.current_build_dir()
# This is a hack to make sure below target was run. For some reason you can't use example from blueprint docs.

blueprints = custom_target('blueprints',
  input: files(
    'gtk/connection-form.blp',
    'gtk/connection-sidebar.blp',
    'gtk/connection-view.blp',
    'gtk/connection-row.blp',
    'gtk/connection-listitem.blp',

    'gtk/query-editor.blp',
    'gtk/query-results.blp',

    'gtk/schema-view.blp',
    'gtk/schema-sidebar.blp',
    'gtk/schema-main.blp',
    
    'gtk/table-data-view.blp',
    'gtk/view-data-view.blp',
    
    'gtk/table-cols.blp',
    'gtk/table-listitem.blp',
    'gtk/query-listitem.blp',
    'gtk/view-listitem.blp',
    'gtk/table-fk.blp',
    'gtk/table-index.blp',
    'gtk/table-structure-view.blp',
    'gtk/view-structure-view.blp',
    
    'gtk/preferences-window.blp',
    'gtk/window.blp',
  ),
  build_by_default: true,
#   This does not run if you use an dot (.)
  output: 'dot',
  command: [find_program('blueprint-compiler'), 'batch-compile', blueprints_output_dir , '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

blueprint_vala = 'blueprint.vala'

blueprint_hack = custom_target('blueprint-hack',
  input: blueprints,
  output: blueprint_vala,
  command: [find_program('touch'), '@OUTPUT@']
)


psequel_resources = gnome.compile_resources('psequel_resources',
  'psequel.gresource.xml',
  c_name: 'psequel_resources',
  dependencies: [blueprints],
)
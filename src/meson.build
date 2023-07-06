# Source code
hellowolrd_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

# UI code?
blueprints = files(
    'ui/window.blp',
)

blp_target = custom_target(
    'blueprints',
    
    input: blueprints,
    output: '.',
    command: [ find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@' ],
)


hellowolrd_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
]

hellowolrd_sources += gnome.compile_resources('hellowolrd-resources',
  'hellowolrd.gresource.xml',
#   source_dir: 'data',
  c_name: 'hellowolrd',
  dependencies: blp_target
)

executable('hellowolrd', hellowolrd_sources,
vala_args: [ '--gresourcesdir=src/' ],
  dependencies: hellowolrd_deps,
       install: true,
)

project('sequelize', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.62.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)
app_id = 'me.ppvan.sequelize'


i18n = import('i18n')
gnome = import('gnome')
cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

vapi_dir = join_paths (meson.project_source_root(), 'src', 'vapi')

add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

subdir('data')
subdir('res')
subdir('src')
subdir('po')

gnome.post_install(
     glib_compile_schemas: true,
    gtk_update_icon_cache: true,
  update_desktop_database: true,
)

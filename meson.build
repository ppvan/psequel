project(
    'psequel',
    ['c', 'vala'],
    version: '0.2.0',
    meson_version: '>= 1.2.0',
    default_options: [
        'warning_level=2',
        'werror=false',
    ],
)

app_is_development = false
app_id = 'me.ppvan.psequel'

if get_option('buildtype') == 'debug'
  add_project_arguments('--debug', language: 'vala')
  app_is_development = true
endif




i18n = import('i18n')
gnome = import('gnome')
# cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')


# Pass custom vapi to compiler (for libpq)
vapi_dir = join_paths(meson.project_source_root(), 'src', 'vapi')
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

subdir('data')
subdir('res')
subdir('src')
subdir('po')

# Using gnome module to do some task after the app is installed, like compile schema (settings data)
# Update icon cache.
gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
    update_desktop_database: true,
)

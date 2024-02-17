

# VSGI tests
psequel_tests = [
    'connection',
]




configure_file(output: 'config.h', configuration: conf)
# env = environment()
# env.set('G_MESSAGES_DEBUG', 'Psequel')

foreach name : psequel_tests
    test(name,
        executable(name, name + '_test.vala', [psequel_sources], dependencies: psequel_deps),
        env: [
            'G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()),
            'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir()),
        ],
        protocol: 'tap',
    )
endforeach


# if get_option('with_query')
#     test('query',
#         executable('query', 'query_test.vala', [psequel_sources], dependencies: psequel_deps),
#         env: [
#             'G_TEST_SRCDIR=@0@'.format(meson.current_source_dir()),
#             'G_TEST_BUILDDIR=@0@'.format(meson.current_build_dir()),
#         ],
#         protocol: 'tap',
#     )
# endif

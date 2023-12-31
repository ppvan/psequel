
test_sources = [
    'sample',
]
configure_file(output: 'config.h', configuration: conf)
env = environment()

env.set('G_MESSAGES_DEBUG', 'Psequel')

foreach name : test_sources
    test(name, executable(name, name + '_test.vala', [psequel_sources], dependencies: psequel_deps))
endforeach


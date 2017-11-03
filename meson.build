project('practica4', 'c')
glibdep = dependency('glib-2.0')

src = 'src/main.c'

tabla_src = 'src/tabla.c'
inc = include_directories('include')
tabla_lib = static_library('tabla', tabla_src, dependencies: glibdep, include_directories: inc)

executable('p4', sources : src, dependencies : glibdep, include_directories : inc, link_with: tabla_lib)

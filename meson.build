project('practica4', 'c')
glibdep = dependency('glib-2.0')

flex = find_program('flex')
bison = find_program('bison')

flex_gen = generator(
  flex,
  output: '@BASENAME@.yy.c',
  arguments: ['-o', '@OUTPUT@', '@INPUT@']
)

bison_gen = generator(
  bison,
  output: ['@BASENAME@.c', '@BASENAME@.h'],
  arguments: ['-d', '@INPUT@' ,'-o', '@OUTPUT0@']
)

flexfiles = flex_gen.process('src/lex.l')
bisonfiles = bison_gen.process('src/looli.y')

src = 'src/main.c'

tabla_src = 'src/table.c'
inc = include_directories('include')
tabla_lib = static_library(
  'table',
  tabla_src,
  dependencies: glibdep,
  include_directories: inc
)

executable(
  'p4',
  flexfiles,
  bisonfiles,
  dependencies : glibdep,
  include_directories : inc,
  link_with: tabla_lib
)

executable(
  'manitest',
  'src/main.c',
  dependencies : glibdep,
  include_directories : inc,
  link_with : tabla_lib
)

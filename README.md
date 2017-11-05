# Practica4-Compiladores

Por 

* Carrillo Verduzco Diego
* Hernández Chiapa David Felipe

## Cómo compilar el proyecto

El proyecto utiliza [meson](http://mesonbuild.com/) como sistema
de compilación. Por lo tanto se requiere tanto de `meson` como
de `python3` y `ninja` para compilar. Una vez obtenido todo esto,
se puede compilar de la siguiente manera:

    $ meson build
    $ ninja -C build

tras lo cual se generará el binario `p4` en el directorio `build`.
El proyecto se puede recompilar sin necesidad de volver a 
generar `build`, ejecutando solamente

    $ ninja -C build


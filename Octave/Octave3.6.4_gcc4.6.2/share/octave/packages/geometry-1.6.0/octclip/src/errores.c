/* -*- coding: utf-8 -*- */
/**
\ingroup anespec errores eop fichero general geodesia geom geopot gshhs marea
\ingroup matriz mmcc orden snx texto
@{
\file errores.c
\brief Definición de funciones para el tratamiento de errores.

En el momento de la compilación ha de seleccionarse el comportamiento de la
función \ref GeocError. Para realizar la selección es necesario definir las
variables para el preprocesador \em ESCRIBE_MENSAJE_ERROR si se quiere que la
función imprima un mensaje de error y/o \em FIN_PROGRAMA_ERROR si se quiere que
la función termine la ejecución del programa en curso. Si no se define ninguna
variable, la función no ejecuta ninguna acción. En \p gcc, las variables para el
preprocesador se pasan como \em -DXXX, donde \em XXX es la variable a
introducir.
\author José Luis García Pallero, jgpallero@gmail.com
\date 09 de enero de 2011
\section Licencia Licencia
Copyright (c) 2009-2011, José Luis García Pallero. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.
- Neither the name of the copyright holders nor the names of its contributors
  may be used to endorse or promote products derived from this software without
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/******************************************************************************/
/******************************************************************************/
#include"libgeoc/errores.h"
/******************************************************************************/
/******************************************************************************/
int GeocTipoError(void)
{
    //variable de salida
    int valor=GEOC_TIPO_ERR_NADA;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //distinguimos los posibles casos según las variables del preprocesador
#if defined(ESCRIBE_MENSAJE_ERROR) && defined(FIN_PROGRAMA_ERROR)
    //mensaje de error y terminación del programa
    valor = GEOC_TIPO_ERR_MENS_Y_EXIT;
#elif defined(ESCRIBE_MENSAJE_ERROR)
    //mensaje de error
    valor = GEOC_TIPO_ERR_MENS;
#elif defined(FIN_PROGRAMA_ERROR)
    //terminación del programa
    valor = GEOC_TIPO_ERR_EXIT;
#endif
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return valor;
}
/******************************************************************************/
/******************************************************************************/
void GeocError(const char mensaje[],
               const char funcion[])
{
    //hacemos una copia para que en la compilación no dé warning si sólo se
    //termina la ejecución del programa o no se hace nada
    mensaje = mensaje;
    funcion = funcion;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //distinguimos los posibles casos según las variables del preprocesador
#if defined(ESCRIBE_MENSAJE_ERROR) && defined(FIN_PROGRAMA_ERROR)
    //imprimimos el nombre de la función y el mensaje
    fprintf(stderr,"En la función '%s'\n",funcion);
    fprintf(stderr,"%s\n",mensaje);
    //indicamos que el programa finalizará
    fprintf(stderr,"El programa finalizará mediante la llamada a la función "
                   "'exit(EXIT_FAILURE)'\n");
    //detenemos la ejecución del programa
    exit(EXIT_FAILURE);
#elif defined(ESCRIBE_MENSAJE_ERROR)
    //imprimimos el nombre de la función y el mensaje
    fprintf(stderr,"En la función '%s'\n",funcion);
    fprintf(stderr,"%s\n",mensaje);
    //salimos de la función
    return;
#elif defined(FIN_PROGRAMA_ERROR)
    //indicamos que el programa finalizará
    fprintf(stderr,"El programa finalizará mediante la llamada a la función "
                   "'exit(EXIT_FAILURE)'\n");
    //detenemos la ejecución del programa
    exit(EXIT_FAILURE);
#else
    //salimos de la función
    return;
#endif
}
/******************************************************************************/
/******************************************************************************/
/** @} */
/******************************************************************************/
/******************************************************************************/
/* kate: encoding utf-8; end-of-line unix; syntax c; indent-mode cstyle; */
/* kate: replace-tabs on; space-indent on; tab-indents off; indent-width 4; */
/* kate: line-numbers on; folding-markers on; remove-trailing-space on; */
/* kate: backspace-indents on; show-tabs on; */
/* kate: word-wrap-column 80; word-wrap-marker-color #D2D2D2; word-wrap off; */

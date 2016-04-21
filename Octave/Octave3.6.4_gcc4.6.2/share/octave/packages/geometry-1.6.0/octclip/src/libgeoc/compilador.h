/* -*- coding: utf-8 -*- */
/**
\ingroup general geopot
@{
\file compilador.h
\brief Declaración de funciones para la detección de compiladores.
\author José Luis García Pallero, jgpallero@gmail.com
\date 28 de abril de 2011
\version 1.0
\section Licencia Licencia
Copyright (c) 2011, José Luis García Pallero. All rights reserved.

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
#ifndef _COMPILADOR_H_
#define _COMPILADOR_H_
/******************************************************************************/
/******************************************************************************/
#include<stdio.h>
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si el compilador utilizado para compilar este fichero es de la
       familia GCC.
\param[out] noGnu Identificador de que estamos ante un compilador que no es de
            la familia GCC, diga lo que diga la variable devuelta por la función
            (ver nota al final de la documentación). Este argumento sólo es
            utilizado si en la entrada su valor es distinto de \p NULL. Dos
            posibles valores de salida:
            - 0: El compilador \b *ES* de la familia GCC.
            - Distinto de 0: El compilador \b *NO* \b *ES* de la familia GCC.
\return Dos posibilidades:
        - 0: El compilador no pertenece a la familia GCC.
        - Distinto de 0: El compilador sí pertenece a la familia GCC (para una
          validez total de este valor hay que tener en cuenta el argumento
          \em noGnu).
\note Esta función realiza la comprobación mediante el chequeo de la existencia
      de la constante simbólica \p __GNUC__. Este hecho hace que la detección
      del compilador se lleve a cabo durante la compilación del fichero que
      contiene a esta función, por lo que  hay que tener en cuenta si ésta es
      llamada desde una función contenida en otro fichero que no fue compilado
      con un compilador de la familia GCC.
\note Algunos compiladores, como el Intel C/C++ Compiler (\p icc), definen por
      defecto la macro \p __GNUC__, por lo que la detección puede ser errónea.
      Para estos casos ha de tenerse en cuenta el argumento \em noGnu.
\note En las versiones más recientes de \p icc, el argumento \p -no-gcc suprime
      la definición de \p __GNUC__.
\date 11 de octubre de 2009: Creación de la función.
*/
int EsCompiladorGNU(int* noGnu);
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
#endif
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

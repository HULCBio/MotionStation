/* -*- coding: utf-8 -*- */
/**
\defgroup geocnan Módulo GEOCNAN
\ingroup geom matriz gshhs
\brief En este módulo se reúnen constantes y funciones para el trabajo con
       valores Not-a-Number.
@{
\file geocnan.h
\brief Declaración de constantes y funciones para el trabajo con valores
       Not-a-Number.
\author José Luis García Pallero, jgpallero@gmail.com
\date 26 de mayo de 2011
\version 1.0
\section Licencia Licencia
Copyright (c) 2010-2011, José Luis García Pallero. All rights reserved.

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
#ifndef _GEOCNAN_H_
#define _GEOCNAN_H_
/******************************************************************************/
/******************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include"libgeoc/errores.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_NAN
\brief Constante \em Not-a-Number (\em NaN). Se define como \em 0.0/0.0.
\date 21 de diciembre de 2010: Creación de la constante.
*/
#define GEOC_NAN (0.0/0.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_NAN_TXT
\brief Constante \em Not-a-Number (\em NaN), como cadena de texto.
\date 22 de septiembre de 2011: Creación de la constante.
*/
#define GEOC_NAN_TXT "NaN"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_NAN_LON_FORM_NUM_SIMPLE
\brief Longitud de una cadena de texto auxiliar para el cálculo de la longitud
       de una cadena de formato numérico simple.
\date 22 de septiembre de 2011: Creación de la constante.
*/
#define GEOC_NAN_LON_FORM_NUM_SIMPLE 100
/******************************************************************************/
/******************************************************************************/
/**
\brief Devuelve el número que representa el valor \em Not-a-Number (\em NaN),
       que se define como el resultado de la evaluación de la operación
       \em 0.0/0.0.
\return Valor NaN.
\note Esta función devuelve el valor almacenado en la constante #GEOC_NAN.
\date 21 de diciembre de 2010: Creación de la función.
\date 24 de mayo de 2011: Ahora la función devuelve el valor absoluto de
      #GEOC_NAN, calculado con la función <tt>fabs()</tt> de C estándar. Se ha
      hecho así porque, a veces, al imprimir un valor normal de #GEOC_NAN, éste
      aparecía con un signo negativo delante.
\date 22 de septiembre de 2011: Lo del <tt>fabs()</tt> no funciona. Parece que
      los problemas en la impresión dependen del compilador y los flags de
      optimización utilizados. No obstante, se mantiene el uso de la función
      <tt>fabs()</tt> en el código.
\todo Esta función todavía no está probada.
*/
double GeocNan(void);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un número es \em Not-a-Number (\em NaN).
\param[in] valor Un número.
\return Dos posibilidades:
        - 0: El número pasado no es NaN.
        - Distinto de 0: El número pasado sí es NaN.
\note Esta función ha sido adaptada de LAPACK 3.2.1, disnan.f,
      (http://www.netlib.org/lapack).
\date 21 de diciembre de 2010: Creación de la función.
\todo Esta función todavía no está probada.
*/
int EsGeocNan(const double valor);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca valores #GEOC_NAN es un vector de datos.
\param[in] datos Vector de trabajo.
\param[in] nDatos Número de elementos que contiene el vector \em datos.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em datos. Este argumento siempre ha de ser un número positivo.
\param[out] nNan Número de valores #GEOC_NAN encontrados, que es el número de
            elementos del vector de salida.
\return Varias posibilidades:
        - Si todo ha ido bien, vector que contiene las posiciones en el vector
          original donde se almacena el valor #GEOC_NAN.
        - NULL: Pueden haber ocurrido dos cosas:
          - Si \em nNan vale 0, en los datos de entrada no hay ningún valor
            #GEOC_NAN.
          - Si \em nNan es mayor que 0, ha ocurrido un error interno de
            asignación de memoria.
\note Esta función no comprueba si el número de elementos del vector \em datos
      es congruente con los valores pasados en \em nDatos e \em incDatos.
\note Las posiciones de los elementos #GEOC_NAN encontradas se refieren al
      número de elementos \em nDatos del vector de trabajo. Para encontrar la
      posición real en memoria es necesario tener en cuenta la variable
      \em incDatos.
\date 26 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
size_t* PosGeocNanEnVector(const double* datos,
                           const size_t nDatos,
                           const size_t incDatos,
                           size_t* nNan);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula el número de carácteres que ocupa un valor numérico imprimido con
       determinado formato.
\param[in] formato Cadena de formato para imprimir \b *UN \b ÚNICO* valor
           numérico (de cualquier tipo).
\return Número de carácteres que ocupa un valor numérico imprimido según el
        formato pasado.
\note Esta función no comprueba internamente si la cadena de formato es
      correcta.
\note \em formato no puede dar lugar a un texto impreso de más de
      #GEOC_NAN_LON_FORM_NUM_SIMPLE carácteres.
\date 22 de septiembre de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
size_t LonFormatoNumSimple(const char formato[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Convierte una cadena de formato para imprimir un \b *ÚNICO* número en una
       cadena para imprimir texto con el mismo ancho que el que tendría de haber
       sido imprimida como número.
\param[in] formatoNum Cadena de formato para imprimir \b *UN \b ÚNICO* valor
           numérico (de cualquier tipo).
\param[out] formatoTexto Cadena de texto que almacenará la cadena de formato
            para la impresión en modo texto.
\note Esta función no comprueba internamente si la cadena de formato numérico es
      correcta.
\note \em formatoNum no puede dar lugar a un texto impreso de más de
      #GEOC_NAN_LON_FORM_NUM_SIMPLE carácteres.
\note Esta función asume que \em formatoTexto tiene espacio suficiente para
      almacenar la cadena de salida.
\note Si \em formatoNum contiene al final carácteres de retorno de carro y salto
      de línea, estos no son tenidos en cuenta en la creación de la cadena de
      salida (no son tenidos en cuenta en el sentido de que no se añaden al
      formato de salida, pero el espacio que ocupan sí se computa).
\date 22 de septiembre de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void FormatoNumFormatoTexto(const char formatoNum[],
                            char formatoTexto[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Imprime valores Not-a-Number en modo texto (#GEOC_NAN_TXT) es un fichero.
\param[in] idFich Identificador del fichero de trabajo, abierto para escribir.
\param[in] nNan Número de veces que se ha de imprimir el valor #GEOC_NAN_TXT,
           una a continuación de otra.
\param[in] formato Cadena de formato para la impresión de cada valor
           #GEOC_NAN_TXT.
\param[in] retCarro Identificador para añadir un retorno de carro y cambio de
           línea al final de la impresión de datos, independientemente del valor
           pasado en el argumento \em formato. Dos posibilidades:
           - 0: No se imprime retorno de carro y cambio de línea al final.
           - Distinto de 0: Sí se imprime retorno de carro y cambio de línea al
             final.
\note Esta función no comprueba internamente si el fichero de entrada está
      abierto correctamente.
\note Esta función no comprueba internamente si la cadena de formato es
      correcta.
\note Si se ha indicado que se imprima salto de línea y retorno de carro al
      final, este se imprime aunque \em nNan valga 0.
\date 22 de septiembre de 2011: Creación de la función.
\todo Esta función no está probada.
*/
void ImprimeGeocNanTexto(FILE* idFich,
                         const size_t nNan,
                         const char formato[],
                         const int retCarro);
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

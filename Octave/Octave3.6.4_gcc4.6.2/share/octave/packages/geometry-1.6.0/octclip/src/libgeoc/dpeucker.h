/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file dpeucker.h
\brief Declaración de funciones para el aligerado de polilíneas basadas en el
       algoritmo de Douglas-Peucker.
\author José Luis García Pallero, jgpallero@gmail.com
\date 04 de julio de 2011
\section Licencia Licencia
Copyright (c) 2009-2010, José Luis García Pallero. All rights reserved.

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
#ifndef _DPEUCKER_H_
#define _DPEUCKER_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include<math.h>
#include"libgeoc/calctopo.h"
#include"libgeoc/constantes.h"
#include"libgeoc/eucli.h"
#include"libgeoc/fgeneral.h"
#include"libgeoc/segmento.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_DPEUCKER_BUFFER_PTOS
\brief Número de puntos para ir asignando memoria en bloques para el vector de
       salida en la funcion \ref AligeraPolilinea.
\date 06 de julio de 2011: Creación de la constante.
*/
#define GEOC_DPEUCKER_BUFFER_PTOS 100
/******************************************************************************/
/******************************************************************************/
/** \enum GEOC_DPEUCKER_ROBUSTO
\brief Aplicación o no del algoritmo robusto de aligerado de polilíneas.
\date 10 de julio de 2011: Creación del tipo.
*/
enum GEOC_DPEUCKER_ROBUSTO
{
    /** \brief \b *NO* se realiza aligerado robusto. */
    GeocDPeuckerRobNo=111,
    /** \brief \b *SÍ* se realiza aligerado robusto. */
    GeocDPeuckerRobSi=112,
    /** \brief Aligerado semi robusto con \ref AligPolilRobIntersecOrig. */
    GeocDPeuckerRobOrig=113,
    /** \brief Aligerado semi robusto con \ref AligPolilRobAutoIntersec. */
    GeocDPeuckerRobAuto=114
};
/******************************************************************************/
/******************************************************************************/
/**
\brief Elimina vértices de una polilínea mediante un algoritmo inspirado en el
       de Douglas-Peucker.

       Este algoritmo, comenzando por el primer punto de la polilínea, va
       uniendo puntos en segmentos de tal forma que se eliminan todos aquellos
       puntos que queden a una distancia perpendicular menor o igual a \em tol
       del segmento de trabajo. Así aplicado, pueden ocurrir casos singulares en
       los que la polilínea aligerada tenga casos de auto intersección entre sus
       lados resultantes. Para evitar esto, se puede aplicar la versión robusta
       del algoritmo.
\param[in] x Vector que contiene las coordenadas X de los vértices de la
           polilínea de trabajo.
\param[in] y Vector que contiene las coordenadas Y de los vértices de la
           polilínea de trabajo.
\param[in] nPtos Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[in] tol Tolerancia para eliminar vértices, en las mismas unidades que las
           coordenadas de los vértices.
\param[in] robusto Identificador para realizar o no un aligerado robusto. Ha de
           ser un elemento del tipo enumerado #GEOC_DPEUCKER_ROBUSTO. Varias
           posibilidades:
           - #GeocDPeuckerRobNo: No se aplica el algoritmo robusto.
           - #GeocDPeuckerRobSi: Se aplica el algoritmo robusto completo, que
             garantiza la no ocurrencia de auto intersecciones en la polilínea
             resultante. Internamente, primero se aplica el tratamiento robusto
             de la opción #GeocDPeuckerRobOrig y luego el de la opción
             #GeocDPeuckerRobAuto.
           - #GeocDPeuckerRobOrig: Se aplica un algoritmo semi robusto que
             consiste en garantizar que los segmentos de la polilínea aligerada
             que se van creando no intersectarán con ninguno de los segmentos
             que forman los vértices que quedan por procesar de la polilínea
             original. En casos muy especiales, este algoritmo puede seguir
             dando lugar a auto intersecciones.
           - #GeocDPeuckerRobAuto: Se aplica un algoritmo semi robusto que
             consiste en garantizar que los segmentos de la polilínea aligerada
             que se van creando no intersectarán con ninguno de los segmentos de
             la polilínea aligerada creados con anterioridad. En casos muy
             especiales, este algoritmo puede seguir dando lugar a auto
             intersecciones.
\param[in] nPtosRobusto Número de puntos de la polilínea original a utilizar en
           el caso de tratamiento robusto con las opciones #GeocDPeuckerRobSi o
           #GeocDPeuckerRobOrig. Si se pasa el valor 0, se utilizan todos los
           puntos hasta el final de la polilínea original.
\param[in] nSegRobusto Número de segmentos de la polilínea aligerada a utilizar
           en el caso de tratamiento robusto con las opciones #GeocDPeuckerRobSi
           o #GeocDPeuckerRobAuto. Si se pasa el valor 0, se utilizan todos los
           segmentos hasta el inicio de la polilínea aligerada.
\param[out] nPtosSal Número de puntos de la polilínea aligerada.
\return Vector de \em nPtosSal elementos que contiene los índices en los
        vectores \em x e \em y de los vértices que formarán la polilínea
        aligerada. Si ocurre algún error de asignación de memoria se devuelve el
        valor \p NULL.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con el valor pasado en \em nPtos.
\note Esta función asume que \em nPtos es mayor que 0. En caso contrario,
      devuelve \p NULL.
\date 07 de julio de 2011: Creación de la función.
\date 10 de julio de 2011: Cambio del tipo del argumento \em robusto al tipo
      enumerado #GEOC_DPEUCKER_ROBUSTO.
\todo Esta función todavía no está probada.
*/
size_t* AligeraPolilinea(const double* x,
                         const double* y,
                         const size_t nPtos,
                         const size_t incX,
                         const size_t incY,
                         const double tol,
                         const enum GEOC_DPEUCKER_ROBUSTO robusto,
                         const size_t nPtosRobusto,
                         const size_t nSegRobusto,
                         size_t* nPtosSal);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aproximación robusta al aligerado de líneas consistente en evitar que los
       segmentos creados intersecten con los de la polilínea original a partir
       del punto de trabajo actual.
\param[in] x Vector que contiene las coordenadas X de los vértices de la
           polilínea de trabajo.
\param[in] y Vector que contiene las coordenadas Y de los vértices de la
           polilínea de trabajo.
\param[in] nPtos Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[in] ptosAUsar Número de puntos a utilizar de la polilínea original. Si se
           pasa el valor 0 se utilizan todos los puntos que quedan desde el
           punto de trabajo hasta el final.
\param[in] posIni Posición inicial del segmento a chequear.
\param[in,out] posFin Posición final del segmento a chequear. Al término de la
               ejecución de la función almacena la posición del punto que hace
               que el segmento de la polilínea aligerada no intersecte con
               ninguno de los que quedan de la polilínea original.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con el valor pasado en \em nPtos.
\note Esta función no comprueba si los índices pasados en los argumentos
      \em posIni y \em posFin son congruentes con el tamaño de los vectores
      pasado en \em nPtos.
\note Esta función no comprueba internamente si la variable \em ptosAUsar es
      congruente con el valor pasado en \em nPtos.
\date 07 de julio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void AligPolilRobIntersecOrig(const double* x,
                              const double* y,
                              const size_t nPtos,
                              const size_t incX,
                              const size_t incY,
                              const size_t ptosAUsar,
                              const size_t posIni,
                              size_t* posFin);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aproximación robusta al aligerado de líneas consistente en evitar que los
       segmentos creados intersecten con los anteriores de la polilínea
       aligerada.
\param[in] x Vector que contiene las coordenadas X de los vértices de la
           polilínea de trabajo.
\param[in] y Vector que contiene las coordenadas Y de los vértices de la
           polilínea de trabajo.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[in] posAlig Vector de posiciones de \em x e \em y utilizadas en la
           polilínea aligerada.
\param[in] nPosAlig Número de elementos de \em posAlig menos el último punto
           añadido. Esto se hace así para evitar chequear el segmento
           inmediatamente anterior, que siempre tiene un punto en común (su
           extremo final) con el de trabajo.
\param[in] segAUsar Número de segmentos a utilizar de la polilínea aligerada. Si
           se pasa el valor 0 se utilizan todos los segmentos anteriores.
\param[in] posIni Posición inicial del segmento a chequear.
\param[in,out] posFin Posición final del segmento a chequear. Al término de la
               ejecución de la función almacena la posición del punto que hace
               que el segmento de la polilínea aligerada no intersecte con
               ninguno de los anteriormente calculados.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con el valor pasado en \em nPtos.
\note Esta función no comprueba si los índices pasados en los argumentos
      \em posIni y \em posFin son congruentes con el tamaño de los vectores
      pasado en \em nPtos.
\note Esta función trabaja internamente con el valor absoluto del argumento
      \em tamRect.
\date 05 de julio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void AligPolilRobAutoIntersec(const double* x,
                              const double* y,
                              const size_t incX,
                              const size_t incY,
                              const size_t* posAlig,
                              const size_t nPosAlig,
                              const size_t segAUsar,
                              const size_t posIni,
                              size_t* posFin);
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

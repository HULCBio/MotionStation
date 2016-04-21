/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file segmento.h
\brief Declaración de funciones para la realización de cálculos con segmentos.
\author José Luis García Pallero, jgpallero@gmail.com
\date 22 de abril de 2011
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
#ifndef _SEGMENTO_H_
#define _SEGMENTO_H_
/******************************************************************************/
/******************************************************************************/
#include"libgeoc/fgeneral.h"
#include"libgeoc/ptopol.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SEG_NO_INTERSEC
\brief Identificador de que dos segmentos no se cortan.
\date 14 de mayo de 2011: Creación de la constante.
*/
#define GEOC_SEG_NO_INTERSEC 0
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SEG_INTERSEC
\brief Identificador de que dos segmentos se cortan en un punto, pero no son
       colineales.
\date 14 de mayo de 2011: Creación de la constante.
*/
#define GEOC_SEG_INTERSEC 1
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN
\brief Identificador de que dos segmentos se cortan en un punto, el cual es un
       extremo que está encima del otro segmento, pero no son colineales.
\date 14 de mayo de 2011: Creación de la constante.
*/
#define GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN 2
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SEG_INTERSEC_EXTREMO_COLIN
\brief Identificador de que dos segmentos tienen un punto común y son
       colineales.
\date 14 de mayo de 2011: Creación de la constante.
*/
#define GEOC_SEG_INTERSEC_EXTREMO_COLIN 3
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SEG_INTERSEC_MISMO_SEG
\brief Identificador de que dos segmentos tienen todos sus puntos extremos en
       común.
\date 21 de mayo de 2011: Creación de la constante.
*/
#define GEOC_SEG_INTERSEC_MISMO_SEG 4
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SEG_INTERSEC_COLIN
\brief Identificador de que dos segmentos tienen más de un punto en común.
\date 14 de mayo de 2011: Creación de la constante.
*/
#define GEOC_SEG_INTERSEC_COLIN 5
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la posición relativa de un punto con respecto a una recta en el
       plano.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] xIni Coordenada X del punto inicial del segmento que define la recta.
\param[in] yIni Coordenada Y del punto inicial del segmento que define la recta.
\param[in] xFin Coordenada X del punto final del segmento que define la recta.
\param[in] yFin Coordenada Y del punto final del segmento que define la recta.
\return Varias posibilidades:
        - Menor que 0: El punto está a la derecha de la recta.
        - 0: El punto pertenece a la recta.
        - Mayor que 0: El punto está a la izquierda de la recta.
\note Para la definición de derecha e izquierda, se considera que el sentido de
      la recta es aquél que se define del punto de inicio al punto final del
      segmento de trabajo.
\note El resultado de esta función no es robusto, es decir, puede dar resultados
      incorrectos debido a errores de redondeo (salvo que todas las coordenadas
      pasadas sean números enteros).
\note El código de esta función ha sido tomado de la función orient2dfast(), de
      http://www.cs.cmu.edu/afs/cs/project/quake/public/code/predicates.c
\date 20 de abril de 2010: Creación de la función.
\date 14 de mayo de 2011: Cambio de nombre a la función.
*/
double PosPtoRecta2D(const double x,
                     const double y,
                     const double xIni,
                     const double yIni,
                     const double xFin,
                     const double yFin);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si tres puntos (A, B, C) del plano son colineales.
\param[in] xA Coordenada X del punto A.
\param[in] yA Coordenada Y del punto A.
\param[in] xB Coordenada X del punto B.
\param[in] yB Coordenada Y del punto B.
\param[in] xC Coordenada X del punto C.
\param[in] yC Coordenada Y del punto C.
\return Dos posibilidades:
        - 0: Los puntos no son colineales.
        - Distinto de 0: Los puntos son colineales.
\note Esta función utiliza internamente la función \ref PtoComunSegmParalelos2D,
      que no es robusta. En consecuencia, los resultados de esta función tampoco
      lo son.
\note Estafunción sirve de apoyo para \ref PtoComunSegmParalelos2D.
\date 14 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int TresPuntosColineales2D(const double xA,
                           const double yA,
                           const double xB,
                           const double yB,
                           const double xC,
                           const double yC);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está situado entre dos puntos (pero no es igual a
       ninguno de ellos) en el plano. Se asume que los tres puntos con
       colineales.
\param[in] x Coordenada X del punto a comprobar.
\param[in] y Coordenada Y del punto a comprobar.
\param[in] xA Coordenada X del primer punto del segmento.
\param[in] yA Coordenada Y del primer punto del segmento.
\param[in] xB Coordenada X del segundo punto del segmento.
\param[in] yB Coordenada Y del segundo punto del segmento.
\return Dos posibilidades:
        - 0: El punto de trabajo no está situado entre los dos puntos dato o es
             igual a alguno de ellos.
        - Distinto de 0: El punto de trabajo sí está situado entre los dos
          puntos dato.
\note Esta función sirve de apoyo para \ref PtoComunSegmParalelos2D.
\date 14 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PuntoEntreDosPuntos2DColin(const double x,
                               const double y,
                               const double xA,
                               const double yA,
                               const double xB,
                               const double yB);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula un punto común entre dos segmentos paralelos AB y CD.
\param[in] xA Coordenada X del punto A.
\param[in] yA Coordenada Y del punto A.
\param[in] xB Coordenada X del punto B.
\param[in] yB Coordenada Y del punto B.
\param[in] xC Coordenada X del punto C.
\param[in] yC Coordenada Y del punto C.
\param[in] xD Coordenada X del punto D.
\param[in] yD Coordenada Y del punto D.
\param[out] x Coordenada X del punto común.
\param[out] y Coordenada Y del punto común.
\return Dos posibilidades:
        - #GEOC_SEG_NO_INTERSEC: Los segmentos no tienen ningún punto en común.
        - #GEOC_SEG_INTERSEC_EXTREMO_COLIN: Los segmentos tienen un extremo
          común y son colineales.
        - #GEOC_SEG_INTERSEC_MISMO_SEG: Los dos segmentos son idénticos.
        - #GEOC_SEG_INTERSEC_COLIN: Los segmentos tienen más de un punto en
          común.
\note Esta función sirve de apoyo para \ref IntersecSegmentos2D.
\note Esta función utiliza internamente la función \ref TresPuntosColineales2D,
      que no es robusta. En consecuencia, los resultados de esta función tampoco
      lo son.
\note Si los segmentos se tocan en los dos extremos (son el mismo segmento), las
      coordenadas devueltas son siempre las del vértice A.
\note Si los segmentos tienen más de un punto en común, pero no son el mismo
      segmento, las coordenadas de salida siempre son las de un punto extremo de
      un segmento. Este punto extremo se intentará que sea uno de los puntos
      iniciales de algún segmento, anque si no lo es, será uno de los finales.
      El orden de preferencia de las coordenadas de salida es: A, C, B, D.
\date 14 de mayo de 2011: Creación de la función.
\date 21 de mayo de 2011: Adición de nuevos valores de salida:
      #GEOC_SEG_INTERSEC_EXTREMO_COLIN y #GEOC_SEG_INTERSEC_MISMO_SEG.
\todo Esta función no está probada.
*/
int PtoComunSegmParalelos2D(const double xA,
                            const double yA,
                            const double xB,
                            const double yB,
                            const double xC,
                            const double yC,
                            const double xD,
                            const double yD,
                            double* x,
                            double* y);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la intersección de dos segmentos AB y CD en el plano.
\param[in] xA Coordenada X del punto A.
\param[in] yA Coordenada Y del punto A.
\param[in] xB Coordenada X del punto B.
\param[in] yB Coordenada Y del punto B.
\param[in] xC Coordenada X del punto C.
\param[in] yC Coordenada Y del punto C.
\param[in] xD Coordenada X del punto D.
\param[in] yD Coordenada Y del punto D.
\param[out] x Coordenada X del punto común.
\param[out] y Coordenada Y del punto común.
\return Cinco posibilidades:
        - #GEOC_SEG_NO_INTERSEC: Los segmentos no tienen ningún punto en común.
        - #GEOC_SEG_INTERSEC: Los segmentos se cortan en un punto.
        - #GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN: El extremo de un segmento toca
          al otro segmento, pero los segmentos no son colineales.
        - #GEOC_SEG_INTERSEC_EXTREMO_COLIN: Los segmentos tienen un extremo
          común y son colineales.
        - #GEOC_SEG_INTERSEC_MISMO_SEG: Los dos segmentos son idénticos.
        - #GEOC_SEG_INTERSEC_COLIN: Los segmentos tienen más de un punto en
          común.
\note Esta función utiliza internamente la función \ref PtoComunSegmParalelos2D,
      que no es robusta. En consecuencia, los resultados de esta función tampoco
      lo son.
\note Si los segmentos se tocan en los dos extremos (son el mismo segmento), las
      coordenadas devueltas son siempre las del vértice A.
\note Si los segmentos tienen más de un punto en común, pero no son el mismo
      segmento, las coordenadas de salida siempre son las de un punto extremo de
      un segmento. Este punto extremo se intentará que sea uno de los puntos
      iniciales de algún segmento, anque si no lo es, será uno de los finales.
      El orden de preferencia de las coordenadas de salida es: A, C, B, D.
\date 14 de mayo de 2011: Creación de la función.
\date 21 de mayo de 2011: Adición de un nuevo valor de salida:
      #GEOC_SEG_INTERSEC_MISMO_SEG.
\date 06 de julio de 2011: Adición de chequeo rápido al principio de la función
      para descartar que los segmentos no tienen ningún punto en común.
*/
int IntersecSegmentos2D(const double xA,
                        const double yA,
                        const double xB,
                        const double yB,
                        const double xC,
                        const double yC,
                        const double xD,
                        const double yD,
                        double* x,
                        double* y);
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

/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file polig.h
\brief Definición de estructuras y declaración de funciones para el trabajo con
       polígonos.
\author José Luis García Pallero, jgpallero@gmail.com
\note Este fichero contiene funciones paralelizadas con OpenMP.
\date 20 de abril de 2011
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
#ifndef _POLIG_H_
#define _POLIG_H_
/******************************************************************************/
/******************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include"libgeoc/dpeucker.h"
#include"libgeoc/errores.h"
#include"libgeoc/fgeneral.h"
#include"libgeoc/geocnan.h"
#include"libgeoc/geocomp.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/** \struct polig
\brief Estructura contenedora de los vértices que definen el contorno de uno o
       varios polígono.
\date 20 de abril de 2011: Creación de la estructura.
\date 26 de mayo de 2011: Reorganización total de la estructura.
\date 28 de mayo de 2011: Adición de los campos polig::hayArea, polig::area,
      polig::hayLim, polig::xMin, polig::xMax, polig::yMin e polig::yMax.
*/
typedef struct
{
    /** \brief Número de elementos de los vectores de coordenadas. */
    size_t nElem;
    /**
    \brief Vector de polig::nElem elementos, que almacena las coordenadas X de
           los vértices del polígono (o los polígonos), así como los separadores
           entre polígonos. La primera coordenada de cada polígono se repite al
           final.
    */
    double* x;
    /**
    \brief Vector de polig::nElem elementos, que almacena las coordenadas Y de
           los vértices del polígono (o los polígonos), así como los separadores
           entre polígonos. La primera coordenada de cada polígono se repite al
           final.
    */
    double* y;
    /** \brief Número de polígonos almacenados. */
    size_t nPolig;
    /**
    \brief Vector de polig::nPolig elementos, que almacena las posiciones en los
           vectores \em x e \em y de inicio de cada polígono almacenado.
    */
    size_t* posIni;
    /**
    \brief Vector de polig::nPolig elementos, que almacena el número de vértices
           de cada polígono almacenado. El último vértice de cada polígono, que
           es el primero repetido, también entra en la cuenta.
    */
    size_t* nVert;
    /**
    \brief Identificador de si la estructura contiene información acerca de los
           límites del rectángulo que encierra a cada polígono almacenado.

           Dos posibilidades:
           - 0: La estructura no contiene información de los límites.
           - Distinto de 0: La estructura sí contiene información de los
                            límites.
    */
    int hayLim;
    /**
    \brief Vector de polig::nPolig elementos, que almacena la coordenada X
           mínima de cada polígono almacenado. Este campo sólo contiene
           información si el campo polig::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* xMin;
    /**
    \brief Vector de polig::nPolig elementos, que almacena la coordenada X
           máxima de cada polígono almacenado. Este campo sólo contiene
           información si el campo polig::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* xMax;
    /**
    \brief Vector de polig::nPolig elementos, que almacena la coordenada Y
           mínima de cada polígono almacenado. Este campo sólo contiene
           información si el campo polig::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* yMin;
    /**
    \brief Vector de polig::nPolig elementos, que almacena la coordenada Y
           máxima de cada polígono almacenado. Este campo sólo contiene
           información si el campo polig::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* yMax;
    /**
    \brief Identificador de si la estructura contiene información acerca de la
           superficie de los polígonos almacenados.

           Dos posibilidades:
           - 0: La estructura no contiene información de superficie.
           - Distinto de 0: La estructura sí contiene información de superficie.
    */
    int hayArea;
    /**
    \brief Vector de polig::nPolig elementos, que almacena la superficie de cada
           polígono almacenado. Este campo sólo contiene información si el campo
           polig::hayArea es distinto de 0; si no, es igual a \p NULL. La
           superficie almacenada sólo es correcta si el polígono es simple, esto
           es, si sus lados no se cortan entre ellos mismos.

           El área de los polígono puede ser negativa o positiva, de tal forma
           que:
           - Si es negativa: Los vértices de polígono están ordenados en el
             sentido de las agujas del reloj.
           - Si es positiva: Los vértices de polígono están ordenados en sentido
             contrario al de las agujas del reloj.
    */
    double* area;
}polig;
/******************************************************************************/
/******************************************************************************/
/**
\brief Indica si hay alguna función compilada en paralelo con OpenMP en el
       fichero \ref polig.c.
\param[out] version Cadena identificadora de la versión de OpenMP utilizada.
            Este argumento sólo se utiliza si su valor de entrada es distinto de
            \p NULL y si hay alguna función compilada con OpenMP.
\return Dos posibles valores:
        - 0: No hay ninguna función compilada en paralelo con OpenMP.
        - Distinto de 0: Sí hay alguna función compilada en paralelo con OpenMP.
\note Esta función asume que el argumento \em version tiene suficiente memoria
      asignada (si es distinto de \p NULL).
\date 27 de mayo de 2011: Creación de la función.
\date 25 de agosto de 2011: Adición del argumento de entrada \em version.
*/
int GeocParOmpPolig(char version[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una estructura \ref polig vacía.
\return Estructura \ref polig vacía. Los campos escalares se inicializan con el
        valor 0 y los vectoriales con \p NULL. Si se devuelve \p NULL ha
        ocurrido un error de asignación de memoria.
\date 26 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
polig* IniciaPoligVacio(void);
/******************************************************************************/
/******************************************************************************/
/**
\brief Función auxiliar para la rutina de creación de una estructura \ref polig
       a partir de dos vectores que contienen las coordenadas de los vértices.

       Esta función calcula el número máximo de elementos que almacenarán los
       vectores de coordenadas de una estructura \ref polig y el número de
       polígonos almacenados en los vectores de trabajo.
\param[in] nElem Número de elementos de los vectores de coordenadas originales.
\param[in] posNanX Vector que almacena las posiciones de los elementos #GEOC_NAN
           en el vector \em x de coordenadas originales.
\param[in] posNanY Vector que almacena las posiciones de los elementos #GEOC_NAN
           en el vector \em y de coordenadas originales.
\param[in] nNanX Número de elementos del vector \em posNanX.
\param[in] nNanY Número de elementos del vector \em posNanY.
\param[out] nElemMax Número máximo de elementos que contendrán los vectores de
            coordenadas de los elementos de la estructura.
\param[out] nPolig Número de polígonos almacenados en los vectores \em x e
            \em y de coordenadas originales.
\return Variable de error. Tres posibilidades:
        - #GEOC_ERR_NO_ERROR: Si todo ha ido bien.
        - #GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG: Si los vectores \em x e \em y
          de coordenadas originales almacenan un número distinto de polígonos,
          es decir, \em nNanX es distinto que \em nNanY.
        - #GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG: Si algunos polígonos almacenados
          en \em x e \em y son distintos, es decir, las posiciones almacenadas
          en \em posNanX son distintas de las almacenadas en \em posNanY.
\note Esta función no comprueba si el número de elementos de los vectores
      \em posNanX y \em posNanY es congruente con los valores pasados en
      \em nNanX y \em nNanY.
\date 26 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int AuxCreaPolig1(const size_t nElem,
                  const size_t* posNanX,
                  const size_t* posNanY,
                  const size_t nNanX,
                  const size_t nNanY,
                  size_t* nElemMax,
                  size_t* nPolig);
/******************************************************************************/
/******************************************************************************/
/**
\brief Función auxiliar para la rutina de creación de una estructura \ref polig
       a partir de dos vectores que contienen las coordenadas de los vértices.

       Esta función copia una serie de datos de dos vectores en otros dos.
\param[in] x Vector que contiene las coordenadas X de los vértices a copiar.
\param[in] y Vector que contiene las coordenadas Y de los vértices a copiar.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[out] xSal Vector para almacenar los elementos copiados del vector \em x.
            Ha de tener la suficiente memoria asignada para copiar \em nElem
            elementos más un posible elemento adicional, que es el primer
            elemento de \em x, si éste no se repite al final.
\param[out] ySal Vector para almacenar los elementos copiados del vector \em y.
            Ha de tener la suficiente memoria asignada para copiar \em nElem
            elementos más un posible elemento adicional, que es el primer
            elemento de \em y, si éste no se repite al final.
\param[out] nCopias Número de elementos copiados en los vectores \em xSal e
            \em ySal, incluido el primer punto repetido al final, si se copia.
\note Esta función no comprueba si el número de elementos de los vectores \em x,
      \em y, \em xSal e \em ySal es congruente con los valores pasados en
      \em nElem, \em incX e \em incY.
\date 26 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void AuxCreaPolig2(const double* x,
                   const double* y,
                   const size_t nElem,
                   const size_t incX,
                   const size_t incY,
                   double* xSal,
                   double* ySal,
                   size_t* nCopias);
/******************************************************************************/
/******************************************************************************/
/**
\brief Función auxiliar para las rutinas de creación de estructuras \ref polig
       a partir de dos vectores que contienen las coordenadas de los vértices.

       Esta función crea los polígonos en el formato de almacenamiento de
       \ref polig a partir de los vectores de entrada.
\param[in] x Vector que contiene las coordenadas X de los vértices de trabajo.
\param[in] y Vector que contiene las coordenadas Y de los vértices de trabajo.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[in] posNan Vector que almacena las posiciones de los elementos #GEOC_NAN
           en los vectores \em x e \em y.
\param[in] nNan Número de elementos del vector \em posNan.
\param[out] xSal Vector para almacenar las coordenadas X de los vértices de los
            polígonos creados.
\param[out] ySal Vector para almacenar las coordenadas Y de los vértices de los
            polígonos creados.
\param[out] posIni Vector para almacenar las posiciones de inicio de los
            polígonos creados.
\param[out] nVert Vector para almacenar el número de vértices de los polígonos
            creados.
\param[out] nPtos Número de posiciones con información almacenada en los
            vectores \em xSal e \em ySal.
\param[out] nPolig Número de posiciones con información almacenada en los
            vectores \em posIni y \em nVert.
\note Esta función no comprueba si el número de elementos de los vectores \em x,
      \em y y \em posNan es congruente con los valores pasados en \em nElem,
      \em incX, \em incY y \em nNan.
\note Esta función asume que los vectores \em xSal, \em ySal, \em posIni y
      \em nVert tienen asignada suficiente memoria.
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void AuxCreaPolig3(const double* x,
                   const double* y,
                   const size_t nElem,
                   const size_t incX,
                   const size_t incY,
                   const size_t* posNan,
                   const size_t nNan,
                   double* xSal,
                   double* ySal,
                   size_t* posIni,
                   size_t* nVert,
                   size_t* nPtos,
                   size_t* nPolig);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una estructura \ref polig a partir de dos vectores que contienen las
       coordenadas de los vértices de uno o varios polígonos.
\param[in] x Vector que contiene las coordenadas X de los vértices del polígono
           o polígonos de trabajo. Si hay varios polígonos, han de estar
           separados por un valor #GEOC_NAN.
\param[in] y Vector que contiene las coordenadas Y de los vértices del polígono
           o polígonos de trabajo. Si hay varios polígonos, han de estar
           separados por un valor #GEOC_NAN.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[out] idError Identificador de error. Varias posibilidades:
            - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
            - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de
              memoria.
            - #GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG: Los vectores \em x e \em y
              contienen un número distinto de polígonos. No contienen el mismo
              número de identificadores #GEOC_NAN.
            - #GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG: Los vectores \em x e \em y
              contienen distintos polígonos. Los marcadores #GEOC_NAN no están
              colocados en las mismas posiciones.
\return Estructura \ref polig con los polígonos pasados. Si ocurre algún error,
        se devuelve \p NULL y el motivo del fallo se codifica en la variable
        \em idError.
\note Esta función está paralelizada con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados de \em nElem, \em incX e
      \em incY.
\note Si los vectores \em x e \em y almacenan varios polígonos, éstos se separan
      mediante valores #GEOC_NAN. Poner #GEOC_NAN en la primera posición y/o la
      última es opcional.
\note Los posibles valores #GEOC_NAN han de estar en las mismas posiciones en
      \em x e \em y.
\note Para los polígonos, es opcional repetir las coordenadas del primer vértice
      al final del listado del resto de vértices.
\note Esta función no calcula los límites de los polígonos ni su área, por lo
      que los campos polig::hayLim y polig::hayArea se inicializan a 0 y los
      campos polig::xMin, polig::xMax, polig::yMin, polig::yMax y polig::area se
      inicializan a \p NULL.
\date 26 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
polig* CreaPolig(const double* x,
                 const double* y,
                 const size_t nElem,
                 const size_t incX,
                 const size_t incY,
                 int* idError);
/******************************************************************************/
/******************************************************************************/
/**
\brief Enlaza el contenido de una estructura \ref polig a otra.
\param[in] poliEnt Estructura \ref polig de entrada, que almacena los datos a
           enlazar.
\param[out] poliSal Estructura \ref polig, cuyos campos serán enlazados a los de
            la estructura \em poliEnt. Esta estructura ha de estar, como mínimo,
            inicializada. Al término de la ejecución de la función, las
            estructuras \em poliEnt y \em poliSal comparten el mismo espacio de
            memoria en sus argumentos vectoriales.
\note Esta función asume que la estructura de entrada \em poligEnt tiene memoria
      asignada.
\note Esta función asume que la estructura de salida \em poligSal está, como
      mínimo, inicializada.
\note Esta función libera la posible memoria asignada a los campos de
      \em poliSal antes de realizar el enlace.
\date 19 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void EnlazaCamposPolig(polig* poliEnt,
                       polig* poliSal);
/******************************************************************************/
/******************************************************************************/
/**
\brief Copia el contenido de una estructura \ref polig en otra.
\param[in] poli Estructura \ref polig de entrada, que almacena los datos a
           copiar.
\param[out] idError Identificador de error. Varias posibilidades:
            - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
            - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de
              memoria.
            - #GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG: Los campos polig::x e
              polig::y del polígono de entrada contienen un número distinto de
              polígonos. No contienen el mismo número de identificadores
              #GEOC_NAN.
            - #GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG: Los campos polig::x e
              polig::y del polígono de entrada contienen distintos polígonos.
              Los marcadores #GEOC_NAN no están colocados en las mismas
              posiciones.
\return Polígono con los datos contenidos en \em poli copiados. Si ocurre algún
        error se devuelve \p NULL y la causa se almacena en el argumento
        \em idError.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\date 09 de julio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
polig* CopiaPolig(const polig* poli,
                  int* idError);
/******************************************************************************/
/******************************************************************************/
/**
\brief Añade el contenido de una estructura \ref polig a otra.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se han añadido los
               polígonos de la estructura \em anyade.
\param[in] anyade Estructura cuyo contenido será añadido a \em poli.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función asume que la estructura de entrada \ref polig tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de las estructuras
      de entrada no se libera.
\note Si la estructura \em poli guarda información de superficie y límites de
      los polígonos almacenados, esta información se calcula también para los
      nuevos datos (en realidad, si la estructura \em anyade ya los tiene
      calculados, simplemente se copian).
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int AnyadePoligPolig(polig* poli,
                     const polig* anyade);
/******************************************************************************/
/******************************************************************************/
/**
\brief Añade al contenido de una estructura \ref polig un conjunto de polígonos
       definidos a partir de un listado con las coordenadas de sus vértices, de
       la misma forma que el utilizado en la función \ref CreaPolig.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se han añadido los
               polígonos pasados en \em x e \em y.
\param[in] x Vector que contiene las coordenadas X de los vértices del polígono
           o polígonos a añadir. Si hay varios polígonos, han de estar separados
           por un valor #GEOC_NAN.
\param[in] y Vector que contiene las coordenadas Y de los vértices del polígono
           o polígonos a añadir. Si hay varios polígonos, han de estar separados
           por un valor #GEOC_NAN.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
        - #GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG: Los vectores \em x e \em y
           contienen un número distinto de polígonos. No contienen el mismo
           número de identificadores #GEOC_NAN.
        - #GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG: Los vectores \em x e \em y
           contienen distintos polígonos. Los marcadores #GEOC_NAN no están
           colocados en las mismas posiciones.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de la estructura y
      los vectores de entrada no se libera.
\note Si la estructura \em poli guarda información de superficie y límites de
      los polígonos almacenados, esta información se calcula también para los
      nuevos datos.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados de \em nElem, \em incX e
      \em incY.
\note Si los vectores \em x e \em y almacenan varios polígonos, éstos se separan
      mediante valores #GEOC_NAN. Poner #GEOC_NAN en la primera posición y/o la
      última es opcional.
\note Los posibles valores #GEOC_NAN han de estar en las mismas posiciones en
      \em x e \em y.
\note Para los polígonos, es opcional repetir las coordenadas del primer vértice
      al final del listado del resto de vértices.
\note Esta función crea internamente una estructura \ref polig para luego
      añadirla a \em poli con la función \ref AnyadePoligPolig.
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int AnyadeDatosPolig(polig* poli,
                     const double* x,
                     const double* y,
                     const size_t nElem,
                     const size_t incX,
                     const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Libera la memoria asignada a una estructura \ref polig.
\param[in] datos Estructura \ref polig.
\date 20 de abril de 2011: Creación de la estructura.
\date 26 de mayo de 2011: Reescritura de la función para el trabajo con la nueva
      versión de la estructura.
\note Esta función todavía no está probada.
*/
void LibMemPolig(polig* datos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula los límites de todos los polígonos almacenados en una estructura
       \ref polig.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se han añadido los
               límites de los polígonos almacenados.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función está paralelizada con OpenMP.
\note Esta función asume que la estructura de entrada \ref polig tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de la estructura de
      entrada no se libera.
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int CalcLimitesPolig(polig* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula los límites de un polígono a partir de las coordenadas de sus
       vértices.
\param[in] x Vector que contiene las coordenadas X de los vértices del polígono
           de trabajo.
\param[in] y Vector que contiene las coordenadas Y de los vértices del polígono
           de trabajo.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[out] xMin Coordenada X mímina del polígono.
\param[out] xMax Coordenada X máxima del polígono.
\param[out] yMin Coordenada Y mímina del polígono.
\param[out] yMax Coordenada Y máxima del polígono.
\note Esta función está paralelizada con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados de \em nElem, \em incX e
      \em incY.
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void LimitesPoligono(const double* x,
                     const double* y,
                     const size_t nElem,
                     const size_t incX,
                     const size_t incY,
                     double* xMin,
                     double* xMax,
                     double* yMin,
                     double* yMax);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula los límites de una serie de polígonos a partir de las coordenadas
       de sus vértices, almacenadas en vectores en el formato de la estructura
       \ref polig.
\param[in] x Vector que contiene las coordenadas X de los vértices del polígono
           de trabajo, tal y como se almacenan en una estructura \ref polig.
\param[in] y Vector que contiene las coordenadas Y de los vértices del polígono
           de trabajo, tal y como se almacenan en una estructura \ref polig.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[in] posIni Vector de \em nPolig elementos, que almacena las posiciones de
           inicio de los polígonos de trabajo.
\param[in] nVert Vector de \em nPolig elementos, que almacena el número de
           vértices de los polígonos de trabajo.
\param[in] nPolig Número de polígonos de trabajo.
\param[in] restaPosIni Número de posiciones a restar a los valores almacenados
           en \em posIni, de tal forma que los índices de los vértices se
           refieran al inicio pasado mediante los punteros \em x e \em y.
\param[out] xMin Vector de \em nPolig elementos para almacenar las coordenadas
            X mínimas calculadas de los polígonos.
\param[out] xMax Vector de \em nPolig elementos para almacenar las coordenadas
            X máximas calculadas de los polígonos.
\param[out] yMin Vector de \em nPolig elementos para almacenar las coordenadas
            Y mínimas calculadas de los polígonos.
\param[out] yMax Vector de \em nPolig elementos para almacenar las coordenadas
            Y máximas calculadas de los polígonos.
\note Esta función está paralelizada con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores \em x,
      \em y, \em posIni, \em nVert, \em xMin, \em xMax, \em yMin e \em yMax es
      congruente con los valores pasados de \em incX, \em incY, \em nPolig y
      \em restaPoliIni.
\note Esta función no comprueba si las coordenadas almacenadas en los vectores
      \em x e \em y están en el formato de la estructura \ref polig.
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void LimitesPoligonosPolig(const double* x,
                           const double* y,
                           const size_t incX,
                           const size_t incY,
                           const size_t* posIni,
                           const size_t* nVert,
                           const size_t nPolig,
                           const size_t restaPosIni,
                           double* xMin,
                           double* xMax,
                           double* yMin,
                           double* yMax);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula el área de todos los polígonos almacenados en una estructura
       \ref polig.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se han añadido las
               superficies de los polígonos almacenados.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función asume que la estructura de entrada \ref polig tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de la estructura de
      entrada no se libera.
\date 29 de mayo de 2011: Creación de la función.
\date 01 de agosto de 2011: Corregido error que hacía que se calculasen mal las
      superficies debido a un incorrecto uso del argumento \em restaPosIni de la
      función \ref AreaPoligonosSimplesPolig.
\note Esta función todavía no está probada.
*/
int CalcAreaPolig(polig* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula el área de un polígono simple (sin intersecciones consigo mismo)
       a partir de las coordenadas de sus vértices.
\param[in] x Vector que contiene las coordenadas X de los vértices del polígono
           de trabajo. Las coordenadas del primer punto pueden repetirse o no al
           final, indistintamente.
\param[in] y Vector que contiene las coordenadas Y de los vértices del polígono
           de trabajo. Las coordenadas del primer punto pueden repetirse o no al
           final, indistintamente.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\return Superficie del polígono de trabajo. Dos posibilidades:
        - Número negativo: Los vértices del polígono están ordenados en el
          sentido de las agujas del reloj.
        - Número positivo: Los vértices del polígono están ordenados en el
          sentido contrario al de las agujas del reloj.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados de \em nElem, \em incX e
      \em incY.
\note El algoritmo implementado es el correspondiente a la ecuación 21.4.20 del
      Numerical Recipes, tercera edición, página 1127. Este algoritmo trabaja
      con vectores de coordenadas en los que el primer punto no se repite al
      final. Esta función comprueba internamente si el primer punto se repite al
      final de los vectores pasados y actua en consecuencia para proporcionar un
      resultado correcto.
\date 29 de mayo de 2011: Creación de la función.
\date 23 de junio de 2011: Adición de la capacidad de trabajar con vectores de
      coordenadas en los que se repite el primer punto al final.
\note Esta función todavía no está probada.
*/
double AreaPoligonoSimple(const double* x,
                          const double* y,
                          const size_t nElem,
                          const size_t incX,
                          const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula el área de una serie de polígonos simples (sin intersecciones
       consigo mismo) a partir de las coordenadas de sus vértices, almacenadas
       en vectores en el formato de la estructura \ref polig.
\param[in] x Vector que contiene las coordenadas X de los vértices del polígono
           de trabajo, tal y como se almacenan en una estructura \ref polig.
\param[in] y Vector que contiene las coordenadas Y de los vértices del polígono
           de trabajo, tal y como se almacenan en una estructura \ref polig.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[in] posIni Vector de \em nPolig elementos, que almacena las posiciones de
           inicio de los polígonos de trabajo.
\param[in] nVert Vector de \em nPolig elementos, que almacena el número de
           vértices de los polígonos de trabajo.
\param[in] nPolig Número de polígonos de trabajo.
\param[in] restaPosIni Número de posiciones a restar a los valores almacenados
           en \em posIni, de tal forma que los índices de los vértices se
           refieran al inicio pasado mediante los punteros \em x e \em y.
\param[out] area Vector de \em nPolig elementos para almacenar las superficies
            calculadas de los polígonos. Los valores pueden ser positivos o
            negativos:
            - Número negativo: Los vértices del polígono están ordenados en el
              sentido de las agujas del reloj.
            - Número positivo: Los vértices del polígono están ordenados en el
              sentido contrario al de las agujas del reloj.
\note Esta función está paralelizada con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores \em x,
      \em y, \em posIni, \em nVert y \em area es congruente con los valores
      pasados de \em incX, \em incY, \em nPolig y \em restaPoliIni.
\note Esta función no comprueba si las coordenadas almacenadas en los vectores
      \em x e \em y están en el formato de la estructura \ref polig.
\date 29 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void AreaPoligonosSimplesPolig(const double* x,
                               const double* y,
                               const size_t incX,
                               const size_t incY,
                               const size_t* posIni,
                               const size_t* nVert,
                               const size_t nPolig,
                               const size_t restaPosIni,
                               double* area);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica un factor de escala y una traslación (en este orden) a las
       coordenadas de todos los polígonos almacenados en una estructura
       \ref polig.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se ha aplicado un
               factor de escala y una traslación (en este orden) a las
               coordenadas de todos los polígonos almacenados y, si se indica, a
               los límites y las superficies.
\param[in] escalaX Factor de escala a aplicar a las coordenadas X.
\param[in] escalaY Factor de escala a aplicar a las coordenadas Y.
\param[in] trasladaX Traslación a aplicar a las coordenadas X.
\param[in] trasladaY Traslación a aplicar a las coordenadas Y.
\param[in] aplicaLim Identificador para aplicar o no los factores de escala y
           las traslaciones a los límites de los polígonos (sólo si están
           previemente calculados). Dos posibilidades:
           - 0: No se aplican los factores de escala ni las traslaciones a los
             límites.
           - Distinto de 0: Sí se aplican los factores de escala y las
             traslaciones a los límites, si estos están calculados en la
             estructura de entrada.
\param[in] aplicaArea Identificador para aplicar o no los factores de escala
           (que se aplican como un único factor \em escalaX*escalaY) a las áreas
           de los polígonos (sólo si están previemente calculadas). Dos
           posibilidades:
           - 0: No se aplican los factores a las áreas.
           - Distinto de 0: Sí se aplican los factores a las áreas, si estas
             están calculadas en la estructura de entrada.
\note Esta función está paralelizada con OpenMP.
\note Primero se aplican los factores de escala y luego las traslaciones.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\note A las áreas sólo se aplican los factores de escala, ya que son invariantes
      ante traslaciones.
\note A las áreas, los factores de escala se aplican como uno solo, igual a
      \em escalaX*escalaY, para que éstas queden correctamente expresadas en las
      nuevas unidades a las que da lugar el escalado.
\date 02 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Distinción entre factores de escala y traslaciones
      para las coordenadas X e Y.
\note Esta función todavía no está probada.
*/
void EscalaYTrasladaPolig(polig* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim,
                          const int aplicaArea);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica una traslación y un factor de escala (en este orden) a las
       coordenadas de todos los polígonos almacenados en una estructura
       \ref polig.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se ha aplicado una
               traslación y un factor de escala (en este orden) a las
               coordenadas de todos los polígonos almacenados y, si se indica, a
               los límites y las superficies.
\param[in] escalaX Factor de escala a aplicar a las coordenadas X.
\param[in] escalaY Factor de escala a aplicar a las coordenadas Y.
\param[in] trasladaX Traslación a aplicar a las coordenadas X.
\param[in] trasladaY Traslación a aplicar a las coordenadas Y.
\param[in] aplicaLim Identificador para aplicar o no las traslaciones y los
           factores de escala a los límites de los polígonos (sólo si están
           previemente calculados). Dos posibilidades:
           - 0: No se aplican las traslaciones ni los factores de escala a los
             límites.
           - Distinto de 0: Sí se aplican las traslaciones y los factores de
             escala a los límites, si estos están calculados en la estructura de
             entrada.
\param[in] aplicaArea Identificador para aplicar o no los factores de escala
           (que se aplican como un único factor \em escalaX*escalaY) a las áreas
           de los polígonos (sólo si están previemente calculadas). Dos
           posibilidades:
           - 0: No se aplican los factores a las áreas.
           - Distinto de 0: Sí se aplican los factores a las áreas, si estas
             están calculadas en la estructura de entrada.
\note Esta función está paralelizada con OpenMP.
\note Primero se aplican las traslaciones y luego los factores de escala.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\note A las áreas sólo se aplican los factores de escala, ya que son invariantes
      ante traslaciones.
\note A las áreas, los factores de escala se aplican como uno solo, igual a
      \em escalaX*escalaY, para que éstas queden correctamente expresadas en las
      nuevas unidades a las que da lugar el escalado.
\date 02 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Distinción entre factores de escala y traslaciones
      para las coordenadas X e Y.
\note Esta función todavía no está probada.
*/
void TrasladaYEscalaPolig(polig* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim,
                          const int aplicaArea);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica un factor de escala y una traslación (el orden de aplicación se ha
       de seleccionar) a las coordenadas de todos los polígonos almacenados en
       una estructura \ref polig.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se ha aplicado un
               factor de escala y una traslación (orden a seleccionar) a las
               coordenadas de todos los polígonos almacenados y, si se indica, a
               los límites y las superficies.
\param[in] escalaX Factor de escala a aplicar a las coordenadas X.
\param[in] escalaY Factor de escala a aplicar a las coordenadas Y.
\param[in] trasladaX Traslación a aplicar a las coordenadas X.
\param[in] trasladaY Traslación a aplicar a las coordenadas Y.
\param[in] orden Orden de aplicación de los factores de escala y traslación. Dos
           posibilidades:
           - 0: Primero se aplican los factores de escala y luego las
             traslaciones \f$x'=f\cdot x+t\f$.
           - Distinto de 0: Primero se aplican las traslaciones y luego los
             factores de escala \f$x'=(x+t)\cdot f\f$.
\param[in] aplicaLim Identificador para aplicar o no los factores de escala y
           las traslaciones a los límites de los polígonos (sólo si están
           previemente calculados). Dos posibilidades:
           - 0: No se aplican los factores de escala ni las traslaciones a los
             límites.
           - Distinto de 0: Sí se aplican los factores de escala y las
             traslaciones a los límites, si estos están calculados en la
             estructura de entrada.
\param[in] aplicaArea Identificador para aplicar o no los factores de escala
           (que se aplican como un único factor \em escalaX*escalaY) a las áreas
           de los polígonos (sólo si están previemente calculadas). Dos
           posibilidades:
           - 0: No se aplican los factores a las áreas.
           - Distinto de 0: Sí se aplican los factores a las áreas, si estas
             están calculadas en la estructura de entrada.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\note A las áreas sólo se aplican los factores de escala, ya que son invariantes
      ante traslaciones.
\note A las áreas, los factores de escala se aplican como uno solo, igual a
      \em escalaX*escalaY, para que éstas queden correctamente expresadas en las
      nuevas unidades a las que da lugar el escalado.
\date 02 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Distinción entre factores de escala y traslaciones
      para las coordenadas X e Y.
\note Esta función todavía no está probada.
*/
void MuevePolig(polig* poli,
                const double escalaX,
                const double escalaY,
                const double trasladaX,
                const double trasladaY,
                const int orden,
                const int aplicaLim,
                const int aplicaArea);
/******************************************************************************/
/******************************************************************************/
/**
\brief Elimina vértices de los polígonos almacenados en una estructura
       \ref polig mediante un algoritmo inspirado en el de Douglas-Peucker. Se
       usa internamente la función \ref AligeraPolilinea.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, almacena el resultado
               de la aplicación a cada polígono del algoritmo de aligerado de
               vértices implementado en la función \ref AligeraPolilinea.
\param[in] tol Tolerancia para eliminar vértices, en las mismas unidades que las
           coordenadas de los vértices. Ver la ayuda de la función
           \ref AligeraPolilinea.
\param[in] robusto Identificador para realizar o no un aligerado robusto. Ha de
           ser un elemento del tipo enumerado #GEOC_DPEUCKER_ROBUSTO. Varias
           posibilidades:
           - #GeocDPeuckerRobNo: No se aplica el algoritmo robusto.
           - #GeocDPeuckerRobSi: Se aplica el algoritmo robusto completo, que
             garantiza la no ocurrencia de auto intersecciones en el polígono
             resultante. Internamente, primero se aplica el tratamiento robusto
             de la opción #GeocDPeuckerRobOrig y luego el de la opción
             #GeocDPeuckerRobAuto.
           - #GeocDPeuckerRobOrig: Se aplica un algoritmo semi robusto que
             consiste en garantizar que los segmentos del polígono aligerado que
             se van creando no intersectarán con ninguno de los segmentos que
             forman los vértices que quedan por procesar del polígono original.
             En casos muy especiales, este algoritmo puede seguir dando lugar a
             auto intersecciones.
           - #GeocDPeuckerRobAuto: Se aplica un algoritmo semi robusto que
             consiste en garantizar que los segmentos del polígono aligerado que
             se van creando no intersectarán con ninguno de los segmentos del
             polígono aligerado creados con anterioridad. En casos muy
             especiales, este algoritmo puede seguir dando lugar a auto
             intersecciones.
\param[in] nPtosRobusto Número de puntos del polígono original a utilizar en el
           caso de tratamiento robusto con las opciones #GeocDPeuckerRobSi o
           #GeocDPeuckerRobOrig. Si se pasa el valor 0, se utilizan todos los
           puntos hasta el final del polígono original.
\param[in] nSegRobusto Número de segmentos del polígono aligerado a utilizar en
           el caso de tratamiento robusto con las opciones #GeocDPeuckerRobSi o
           #GeocDPeuckerRobAuto. Si se pasa el valor 0, se utilizan todos los
           segmentos hasta el inicio del polígono aligerado.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función asume que \em poli está, como mínimo, inicializado.
\note Si \em poli tiene límites y/o áreas calculadas en la entrada, también los
      tendrá en la salida.
\note Un polígono aligerado sólo será válido si después de aplicarle la función
      \ref AligeraPolilinea mantiene un mínimo de 3 puntos no alineados por lo
      que, al término de la ejecución de esta función, el resultado puede ser
      una estructura \ref polig vacía.
\date 09 de julio de 2011: Creación de la función.
\date 10 de julio de 2011: Cambio del tipo del argumento \em robusto al tipo
      enumerado #GEOC_DPEUCKER_ROBUSTO.
\date 31 de julio de 2011: Corregido error con índices a la hora de guardar los
      resultados y comprobación de que los polígonos de salida no estén
      compuestos por tres puntos alineados.
\todo Esta función todavía no está probada.
*/
int AligeraPolig(polig* poli,
                 const double tol,
                 const enum GEOC_DPEUCKER_ROBUSTO robusto,
                 const size_t nPtosRobusto,
                 const size_t nSegRobusto);
/******************************************************************************/
/******************************************************************************/
/**
\brief Imprime una línea de cabecera para un polígono almacenado en una
       estructura \ref polig.
\param[in] poli Estructura \ref polig.
\param[in] indice Índice del polígono de trabajo en la estructura.
\param[in] iniCab Cadena de texto con la que comenzará la cabecera.
\param[in] impLim Identificador para imprimir o no los límites de coordenadas
           del polígono de trabajo. Dos posibles valores:
           - 0: No se imprimen.
           - Distinto de 0: Sí se imprimen.
\param[in] formCoor Cadena de carácteres indicadora del formato para escribir
           las coordenadas de los límites. Este argumento sólo se usa
           internamente si se ha indicado la impresión de límites.
\param[in] impArea Identificador para imprimir o no la superficie del polígono
           de trabajo. Dos posibles valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] formArea Cadena de carácteres indicadora del formato para escribir el
           valor de la superficie. Este argumento sólo se usa internamente si se
           ha indicado la impresión de la superficie del polígono.
\param[in] factorX Factor para multiplicar las coordenadas X de los vértices
           antes de imprimirlas.
\param[in] factorY Factor para multiplicar las coordenadas Y de los vértices
           antes de imprimirlas.
\param[in] repitePrimerPunto Identificador para tener o no en cuenta el primer
           vértice del polígono repetido al final del listado de coordenadas
           para el cálculo del número de vértices del polígono. Dos posibles
           valores:
           - 0: No se repite, luego no se tiene en cuenta.
           - Distinto de 0: Sí se repite, luego sí se tiene en cuenta.
\param[in] idFich Identificador de fichero abierto para escribir.
\note Esta función está paralelizada con OpenMP.
\note La cabecera completa tiene el siguiente formato:
      <tt>iniCab númVert área xMín xMáx yMín yMáx</tt>.
\note Si la estructura no tiene información de límites y/o áreas y se indica que
      se impriman, los valores se calculan internamente.
\note Esta función asume que \em poli es una estructura \ref polig correctamente
      almacenada.
\note Esta función no comprueba si la estructura pasada tiene memoria asignada.
\note Esta función no comprueba internamente la validez de los argumentos de
      formato.
\note Esta función no comprueba internamente si el identificador pasado
      corresponde a un fichero abierto para escribir.
\date 18 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void ImprimeCabeceraPoligFichero(const polig* poli,
                                 const size_t indice,
                                 const char iniCab[],
                                 const int impLim,
                                 const char formCoor[],
                                 const int impArea,
                                 const char formArea[],
                                 const double factorX,
                                 const double factorY,
                                 const int repitePrimerPunto,
                                 FILE* idFich);
/******************************************************************************/
/******************************************************************************/
/**
\brief Imprime una estructura \ref polig en un fichero.
\param[in] poli Estructura \ref polig.
\param[in] factorX Factor para multiplicar las coordenadas X de los vértices
           antes de imprimirlas.
\param[in] factorY Factor para multiplicar las coordenadas Y de los vértices
           antes de imprimirlas.
\param[in] repitePrimerPunto Identificador para repetir o no el primer vértice
           del polígono al final del listado de coordenadas. Dos posibles
           valores:
           - 0: No se repite.
           - Distinto de 0: Sí se repite.
\param[in] iniNan Identificador para imprimir o no la marca de separación de
           polígonos (\p NaN) delante del primer polígono. Dos posibles valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] finNan Identificador para imprimir o no la marca de separación de
           polígonos (\p NaN) detrás del último polígono. Dos posibles valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] formCoor Cadena de carácteres indicadora del formato de cada
           coordenada a imprimir.
\param[in] impCabecera Identificador para imprimir o no una cabecera con
           información general por cada polígono. Dos posibles valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] iniCab Cadena de texto con la que comenzará la cabecera.
\param[in] impLim Identificador para imprimir o no en la cabecera los límites de
           coordenadas de los polígonos de trabajo. Dos posibles valores:
           - 0: No se imprimen.
           - Distinto de 0: Sí se imprimen.
\param[in] impArea Identificador para imprimir o no en la cabecera la superficie
           de los polígonos de trabajo. Dos posibles valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] formArea Cadena de carácteres indicadora del formato para escribir el
           valor de la superficie. Este argumento sólo se usa internamente si se
           ha indicado la impresión de la superficie de los polígonos.
\param[in] idFich Identificador de fichero abierto para escribir.
\note La cabecera completa tiene el siguiente formato:
      <tt>iniCab númVert área xMín xMáx yMín yMáx</tt>.
\note Si la estructura no tiene información de límites y/o áreas y se indica que
      se impriman, los valores se calculan internamente.
\note Esta función asume que \em poli es una estructura \ref polig correctamente
      almacenada.
\note Esta función no comprueba si la estructura pasada tiene memoria asignada.
\note Esta función no comprueba internamente la validez de los argumentos de
      formato.
\note Esta función no comprueba internamente si el identificador pasado
      corresponde a un fichero abierto para escribir.
\date 26 de mayo de 2011: Creación de la función.
\date 30 de mayo de 2011: Adición del argumento de entrada \em factor.
\date 18 de junio de 2011: Adición de la capacidad de escritura de una cabecera
      y del uso de factores de escala independientes para las coordenadas X e Y.
\date 22 de septiembre de 2011: Corregido bug que hacía que, dependiendo del
      compilador y/o los flags de optimización en la compilación, se imprimiesen
      mal (con un signo menos delante) los valores Not-a-Number.
\note Esta función todavía no está probada.
*/
void ImprimePoligFichero(const polig* poli,
                         const double factorX,
                         const double factorY,
                         const int repitePrimerPunto,
                         const int iniNan,
                         const int finNan,
                         const char formCoor[],
                         const int impCabecera,
                         const char iniCab[],
                         const int impLim,
                         const int impArea,
                         const char formArea[],
                         FILE* idFich);
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

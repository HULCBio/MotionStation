/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file polil.h
\brief Definición de estructuras y declaración de funciones para el trabajo con
       polilíneas.
\author José Luis García Pallero, jgpallero@gmail.com
\note Este fichero contiene funciones paralelizadas con OpenMP.
\date 03 de junio de 2011
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
#ifndef _POLIL_H_
#define _POLIL_H_
/******************************************************************************/
/******************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include"libgeoc/dpeucker.h"
#include"libgeoc/errores.h"
#include"libgeoc/fgeneral.h"
#include"libgeoc/geocnan.h"
#include"libgeoc/geocomp.h"
#include"libgeoc/polig.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/** \struct polil
\brief Estructura contenedora de los vértices que definen el contorno de una o
       varias polilíneas.
\date 03 de junio de 2011: Creación de la estructura.
*/
typedef struct
{
    /** \brief Número de elementos de los vectores de coordenadas. */
    size_t nElem;
    /**
    \brief Vector de polil::nElem elementos, que almacena las coordenadas X de
           los vértices de la polilínea (o las polilíneas), así como los
           separadores entre polilíneas. La primera coordenada de cada polilínea
           se repite al final.
    */
    double* x;
    /**
    \brief Vector de polil::nElem elementos, que almacena las coordenadas Y de
           los vértices de la polilínea (o las polilíneas), así como los
           separadores entre polilíneas. La primera coordenada de cada polilínea
           se repite al final.
    */
    double* y;
    /** \brief Número de polilíneas almacenadas. */
    size_t nPolil;
    /**
    \brief Vector de polil::nPolig elementos, que almacena las posiciones en los
           vectores \em x e \em y de inicio de cada polilínea almacenada.
    */
    size_t* posIni;
    /**
    \brief Vector de polil::nPolig elementos, que almacena el número de vértices
           de cada polilínea almacenada.
    */
    size_t* nVert;
    /**
    \brief Identificador de si la estructura contiene información acerca de los
           límites del rectángulo que encierra a cada polilínea almacenada.

           Dos posibilidades:
           - 0: La estructura no contiene información de los límites.
           - Distinto de 0: La estructura sí contiene información de los
                            límites.
    */
    int hayLim;
    /**
    \brief Vector de polil::nPolig elementos, que almacena la coordenada X
           mínima de cada polilínea almacenada. Este campo sólo contiene
           información si el campo polil::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* xMin;
    /**
    \brief Vector de polil::nPolig elementos, que almacena la coordenada X
           máxima de cada polilínea almacenada. Este campo sólo contiene
           información si el campo polil::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* xMax;
    /**
    \brief Vector de polil::nPolig elementos, que almacena la coordenada Y
           mínima de cada polilínea almacenada. Este campo sólo contiene
           información si el campo polil::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* yMin;
    /**
    \brief Vector de polil::nPolig elementos, que almacena la coordenada Y
           máxima de cada polilínea almacenada. Este campo sólo contiene
           información si el campo polil::hayLim es distinto de 0; si no, es
           igual a \p NULL.
    */
    double* yMax;
}polil;
/******************************************************************************/
/******************************************************************************/
/**
\brief Indica si hay alguna función compilada en paralelo con OpenMP en el
       fichero \ref polil.c.
\param[out] version Cadena identificadora de la versión de OpenMP utilizada.
            Este argumento sólo se utiliza si su valor de entrada es distinto de
            \p NULL y si hay alguna función compilada con OpenMP.
\return Dos posibles valores:
        - 0: No hay ninguna función compilada en paralelo con OpenMP.
        - Distinto de 0: Sí hay alguna función compilada en paralelo con OpenMP.
\note Esta función asume que el argumento \em version tiene suficiente memoria
      asignada (si es distinto de \p NULL).
\date 03 de junio de 2011: Creación de la función.
\date 25 de agosto de 2011: Adición del argumento de entrada \em version.
*/
int GeocParOmpPolil(char version[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una estructura \ref polil vacía.
\return Estructura \ref polil vacía. Los campos escalares se inicializan con el
        valor 0 y los vectoriales con \p NULL. Si se devuelve \p NULL ha
        ocurrido un error de asignación de memoria.
\date 26 de mayo de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
polil* IniciaPolilVacia(void);
/******************************************************************************/
/******************************************************************************/
/**
\brief Función auxiliar para la rutina de creación de una estructura \ref polil
       a partir de dos vectores que contienen las coordenadas de los vértices.

       Esta función calcula el número máximo de elementos que almacenarán los
       vectores de coordenadas de una estructura \ref polil y el número de
       polilíneas almacenadas en los vectores de trabajo.
\param[in] nElem Número de elementos de los vectores de coordenadas originales.
\param[in] posNanX Vector que almacena las posiciones de los elementos #GEOC_NAN
           en el vector \em x de coordenadas originales.
\param[in] posNanY Vector que almacena las posiciones de los elementos #GEOC_NAN
           en el vector \em y de coordenadas originales.
\param[in] nNanX Número de elementos del vector \em posNanX.
\param[in] nNanY Número de elementos del vector \em posNanY.
\param[out] nElemMax Número máximo de elementos que contendrán los vectores de
            coordenadas de los elementos de la estructura.
\param[out] nPolil Número de polilíneas almacenadas en los vectores \em x e
            \em y de coordenadas originales.
\return Variable de error. Tres posibilidades:
        - #GEOC_ERR_NO_ERROR: Si todo ha ido bien.
        - #GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL: Si los vectores \em x e \em y
          de coordenadas originales almacenan un número distinto de polilíneas,
          es decir, \em nNanX es distinto que \em nNanY.
        - #GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL: Si algunas polilíneas almacenadas
          en \em x e \em y son distintas, es decir, las posiciones almacenadas
          en \em posNanX son distintas de las almacenadas en \em posNanY.
\note Esta función no comprueba si el número de elementos de los vectores
      \em posNanX y \em posNanY es congruente con los valores pasados en
      \em nNanX y \em nNanY.
\date 03 de junio de 2011: Creación de la función.
\date 13 de junio de 2011: Corrección de error que hacía que el argumento
      \em nElemMax que calculase mal si los argumentos \em nNanX y/o \em nNanY
      valían 0.
\note Esta función todavía no está probada.
*/
int AuxCreaPolil1(const size_t nElem,
                  const size_t* posNanX,
                  const size_t* posNanY,
                  const size_t nNanX,
                  const size_t nNanY,
                  size_t* nElemMax,
                  size_t* nPolil);
/******************************************************************************/
/******************************************************************************/
/**
\brief Función auxiliar para la rutina de creación de una estructura \ref polil
       a partir de dos vectores que contienen las coordenadas de los vértices.

       Esta función copia una serie de datos de dos vectores en otros dos.
\param[in] x Vector que contiene las coordenadas X de los vértices a copiar.
\param[in] y Vector que contiene las coordenadas Y de los vértices a copiar.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[out] xSal Vector de \em nElem elementos para almacenar los elementos
            copiados del vector \em x.
\param[out] ySal Vector de \em nElem elementos para almacenar los elementos
            copiados del vector \em y.
\note Esta función no comprueba si el número de elementos de los vectores \em x,
      \em y, \em xSal e \em ySal es congruente con los valores pasados en
      \em nElem, \em incX e \em incY.
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void AuxCreaPolil2(const double* x,
                   const double* y,
                   const size_t nElem,
                   const size_t incX,
                   const size_t incY,
                   double* xSal,
                   double* ySal);
/******************************************************************************/
/******************************************************************************/
/**
\brief Función auxiliar para las rutinas de creación de estructuras \ref polil
       a partir de dos vectores que contienen las coordenadas de los vértices.

       Esta función crea las polilíneas en el formato de almacenamiento de
       \ref polil a partir de los vectores de entrada.
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
\param[out] xSal Vector para almacenar las coordenadas X de los vértices de las
            polilíneas creadas.
\param[out] ySal Vector para almacenar las coordenadas Y de los vértices de las
            polilíneas creadas.
\param[out] posIni Vector para almacenar las posiciones de inicio de las
            polilíneas creadas.
\param[out] nVert Vector para almacenar el número de vértices de las polilíneas
            creadas.
\param[out] nPtos Número de posiciones con información almacenada en los
            vectores \em xSal e \em ySal.
\param[out] nPolil Número de posiciones con información almacenada en los
            vectores \em posIni y \em nVert.
\note Esta función no comprueba si el número de elementos de los vectores \em x,
      \em y y \em posNan es congruente con los valores pasados en \em nElem,
      \em incX, \em incY y \em nNan.
\note Esta función asume que los vectores \em xSal, \em ySal, \em posIni y
      \em nVert tienen asignada suficiente memoria.
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void AuxCreaPolil3(const double* x,
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
                   size_t* nPolil);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una estructura \ref polil a partir de dos vectores que contienen las
       coordenadas de los vértices de una o varias polilíneas.
\param[in] x Vector que contiene las coordenadas X de los vértices de la
           polilínea o polilíneas de trabajo. Si hay varias polilíneas, han de
           estar separados por un valor #GEOC_NAN.
\param[in] y Vector que contiene las coordenadas Y de los vértices de la
           polilínea o polilíneas de trabajo. Si hay varias polilíneas, han de
           estar separados por un valor #GEOC_NAN.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[out] idError Identificador de error. Varias posibilidades:
            - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
            - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de
              memoria.
            - #GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL: Los vectores \em x e \em y
              contienen un número distinto de polilíneas. No contienen el mismo
              número de identificadores #GEOC_NAN.
            - #GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL: Los vectores \em x e \em y
              contienen distintas polilíneas. Los marcadores #GEOC_NAN no están
              colocados en las mismas posiciones.
\return Estructura \ref polil con las polilíneas pasadas. Si ocurre algún error,
        se devuelve \p NULL y el motivo del fallo se codifica en la variable
        \em idError.
\note Esta función está paralelizada con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados de \em nElem, \em incX e
      \em incY.
\note Si los vectores \em x e \em y almacenan varias polilíneas, éstas se
      separan mediante valores #GEOC_NAN. Poner #GEOC_NAN en la primera posición
      y/o la última es opcional.
\note Los posibles valores #GEOC_NAN han de estar en las mismas posiciones en
      \em x e \em y.
\note Esta función no calcula los límites de las polilíneas, por lo que el
      campo polil::hayLim se inicializa a 0 y los campos polil::xMin,
      polil::xMax, polil::yMin y polil::yMax se inicializan a \p NULL.
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
polil* CreaPolil(const double* x,
                 const double* y,
                 const size_t nElem,
                 const size_t incX,
                 const size_t incY,
                 int* idError);
/******************************************************************************/
/******************************************************************************/
/**
\brief Enlaza el contenido de una estructura \ref polil a otra.
\param[in] poliEnt Estructura \ref polil de entrada, que almacena los datos a
           enlazar.
\param[out] poliSal Estructura \ref polil, cuyos campos serán enlazados a los de
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
void EnlazaCamposPolil(polil* poliEnt,
                       polil* poliSal);
/******************************************************************************/
/******************************************************************************/
/**
\brief Copia el contenido de una estructura \ref polil en otra.
\param[in] poli Estructura \ref polil de entrada, que almacena los datos a
           copiar.
\param[out] idError Identificador de error. Varias posibilidades:
            - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
            - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de
              memoria.
            - #GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL: Los campos polil::x e
              polil::y de la polilínea de entrada contienenun número distinto de
              polilíneas. No contienen el mismo número de identificadores
              #GEOC_NAN.
            - #GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL: Los campos polig::x e
              polig::y de la polilínea de entrada contienen distintas
              polilíneas. Los marcadores #GEOC_NAN no están colocados en las
              mismas posiciones.
\return Polilínea con los datos contenidos en \em poli copiados. Si ocurre algún
        error se devuelve \p NULL y la causa se almacena en el argumento
        \em idError.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\date 09 de julio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
polil* CopiaPolil(const polil* poli,
                  int* idError);
/******************************************************************************/
/******************************************************************************/
/**
\brief Añade el contenido de una estructura \ref polil a otra.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, se han añadido las
               polilíneas de la estructura \em anyade.
\param[in] anyade Estructura cuyo contenido será añadido a \em poli.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función asume que la estructura de entrada \ref polil tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de las estructuras
      de entrada no se libera.
\note Si la estructura \em poli guarda información de límites de las polilíneas
      almacenadas, esta información se calcula también para los nuevos datos (en
      realidad, si la estructura \em anyade ya los tiene calculados, simplemente
      se copian).
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int AnyadePolilPolil(polil* poli,
                     const polil* anyade);
/******************************************************************************/
/******************************************************************************/
/**
\brief Añade al contenido de una estructura \ref polil un conjunto de polilíneas
       definidas a partir de un listado con las coordenadas de sus vértices, de
       la misma forma que el utilizado en la función \ref CreaPolil.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, se han añadido las
               polilíneas pasados en \em x e \em y.
\param[in] x Vector que contiene las coordenadas X de los vértices de la
           polilínea o polilíneas a añadir. Si hay varias polilíneas, han de
           estar separadas por un valor #GEOC_NAN.
\param[in] y Vector que contiene las coordenadas Y de los vértices de la
           polilínea o polilíneas a añadir. Si hay varias polilíneas, han de
           estar separadas por un valor #GEOC_NAN.
\param[in] nElem Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
        - #GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL: Los vectores \em x e \em y
           contienen un número distinto de polilíneas. No contienen el mismo
           número de identificadores #GEOC_NAN.
        - #GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL: Los vectores \em x e \em y
           contienen distintas polilíneas. Los marcadores #GEOC_NAN no están
           colocados en las mismas posiciones.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de la estructura y
      los vectores de entrada no se libera.
\note Si la estructura \em poli guarda información de límites de las polilíneas
      almacenadas, esta información se calcula también para los nuevos datos.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados de \em nElem, \em incX e
      \em incY.
\note Si los vectores \em x e \em y almacenan varias polilíneas, éstas se
      separan mediante valores #GEOC_NAN. Poner #GEOC_NAN en la primera posición
      y/o la última es opcional.
\note Los posibles valores #GEOC_NAN han de estar en las mismas posiciones en
      \em x e \em y.
\note Esta función crea internamente una estructura \ref polil para luego
      añadirla a \em poli con la función \ref AnyadePolilPolil.
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int AnyadeDatosPolil(polil* poli,
                     const double* x,
                     const double* y,
                     const size_t nElem,
                     const size_t incX,
                     const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Libera la memoria asignada a una estructura \ref polil.
\param[in] datos Estructura \ref polil.
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void LibMemPolil(polil* datos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula los límites de todas las polilíneas almacenados en una estructura
       \ref polil.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, se han añadido los
               límites de las polilíneas almacenadas.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función está paralelizada con OpenMP.
\note Esta función asume que la estructura de entrada \ref polil tiene memoria
      asignada.
\note En caso de error de asignación de memoria, la memoria de la estructura de
      entrada no se libera.
\date 03 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
int CalcLimitesPolil(polil* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica un factor de escala y una traslación (en este orden) a las
       coordenadas de todas las polilíneas almacenadas en una estructura
       \ref polil.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, se ha aplicado un
               factor de escala y una traslación (en este orden) a las
               coordenadas de todas las polilíneas almacenadas y, si se indica,
               a los límites.
\param[in] escalaX Factor de escala a aplicar a las coordenadas X.
\param[in] escalaY Factor de escala a aplicar a las coordenadas Y.
\param[in] trasladaX Traslación a aplicar a las coordenadas X.
\param[in] trasladaY Traslación a aplicar a las coordenadas Y.
\param[in] aplicaLim Identificador para aplicar o no los factores de escala y
           las traslaciones a los límites de las polilíneas (sólo si están
           previemente calculados). Dos posibilidades:
           - 0: No se aplican los factores de escala ni las traslaciones a los
             límites.
           - Distinto de 0: Sí se aplican los factores de escala y las
             traslaciones a los límites, si estos están calculados en la
             estructura de entrada.
\note Esta función está paralelizada con OpenMP.
\note Primero se aplican los factores de escala y luego las traslaciones.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\date 03 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Distinción entre factores de escala y traslaciones
      para las coordenadas X e Y.
\note Esta función todavía no está probada.
*/
void EscalaYTrasladaPolil(polil* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica una traslación y un factor de escala (en este orden) a las
       coordenadas de todas las polilíneas almacenadss en una estructura
       \ref polil.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, se ha aplicado una
               traslación y un factor de escala (en este orden) a las
               coordenadas de todas las polilíneas almacenadas y, si se indica,
               a los límites.
\param[in] escalaX Factor de escala a aplicar a las coordenadas X.
\param[in] escalaY Factor de escala a aplicar a las coordenadas Y.
\param[in] trasladaX Traslación a aplicar a las coordenadas X.
\param[in] trasladaY Traslación a aplicar a las coordenadas Y.
\param[in] aplicaLim Identificador para aplicar o no las traslaciones y los
           factores de escala a los límites de las polilíneas (sólo si están
           previemente calculados). Dos posibilidades:
           - 0: No se aplican las traslaciones ni los factores de escala a los
             límites.
           - Distinto de 0: Sí se aplican las traslaciones y los factores de
             escala a los límites, si estos están calculados en la estructura de
             entrada.
\note Esta función está paralelizada con OpenMP.
\note Primero se aplican las traslaciones y luego los factores de escala.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\date 03 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Distinción entre factores de escala y traslaciones
      para las coordenadas X e Y.
\note Esta función todavía no está probada.
*/
void TrasladaYEscalaPolil(polil* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica un factor de escala y una traslación (el orden de aplicación se ha
       de seleccionar) a las coordenadas de todas las polilíneas almacenadas en
       una estructura \ref polil.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, se ha aplicado un
               factor de escala y una traslación (orden a seleccionar) a las
               coordenadas de todas las polilíneas almacenadas y, si se indica,
               a los límites.
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
           las traslaciones a los límites de las polilíneas (sólo si están
           previemente calculados). Dos posibilidades:
           - 0: No se aplican los factores de escala ni las traslaciones a los
             límites.
           - Distinto de 0: Sí se aplican los factores de escala y las
             traslaciones a los límites, si estos están calculados en la
             estructura de entrada.
\note Esta función asume que la estructura de entrada \em poli tiene memoria
      asignada.
\date 03 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Distinción entre factores de escala y traslaciones
      para las coordenadas X e Y.
\note Esta función todavía no está probada.
*/
void MuevePolil(polil* poli,
                const double escalaX,
                const double escalaY,
                const double trasladaX,
                const double trasladaY,
                const int orden,
                const int aplicaLim);
/******************************************************************************/
/******************************************************************************/
/**
\brief Elimina vértices de las polilíneas almacenadas en una estructura
       \ref polil mediante un algoritmo inspirado en el de Douglas-Peucker. Se
       usa internamente la función \ref AligeraPolilinea.
\param[in,out] poli Estructura \ref polil, que almacena una serie de polilíneas.
               Al término de la ejecución de la función, almacena el resultado
               de la aplicación a cada polilínea del algoritmo de aligerado de
               vértices implementado en la función \ref AligeraPolilinea.
\param[in] tol Tolerancia para eliminar vértices, en las mismas unidades que las
           coordenadas de los vértices. Ver la ayuda de la función
           \ref AligeraPolilinea.
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
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función asume que \em poli está, como mínimo, inicializada.
\note Si \em poli tiene límites calculados en la entrada, también los tendrá en
      la salida.
\note Una polilínea aligerada sólo será válida si después de aplicarle la
      función \ref AligeraPolilinea mantiene un mínimo de 2 puntos que no sean
      el mismo (esto sólo puede ocurrir si se pasa un polígono -los vértices de
      inicio y final coinciden- y sólo quedan al final los extremos). Al término
      de la ejecución de esta función, el resultado puede ser una estructura
      \ref polil vacía.
\date 09 de julio de 2011: Creación de la función.
\date 10 de julio de 2011: Cambio del tipo del argumento \em robusto al tipo
      enumerado #GEOC_DPEUCKER_ROBUSTO.
\date 31 de julio de 2011: Corregido error con índices a la hora de guardar los
      resultados y modificación para no tomar como válidas las polilíneas que se
      quedan en sólo dos vértices que sean el mismo.
\todo Esta función todavía no está probada.
*/
int AligeraPolil(polil* poli,
                 const double tol,
                 const enum GEOC_DPEUCKER_ROBUSTO robusto,
                 const size_t nPtosRobusto,
                 const size_t nSegRobusto);
/******************************************************************************/
/******************************************************************************/
/**
\brief Imprime una línea de cabecera para una polilínea almacenada en una
       estructura \ref polil.
\param[in] poli Estructura \ref polil.
\param[in] indice Índice de la polilínea de trabajo en la estructura.
\param[in] iniCab Cadena de texto con la que comenzará la cabecera.
\param[in] impLim Identificador para imprimir o no los límites de coordenadas
           de la polilínea de trabajo. Dos posibles valores:
           - 0: No se imprimen.
           - Distinto de 0: Sí se imprimen.
\param[in] formCoor Cadena de carácteres indicadora del formato para escribir
           las coordenadas de los límites. Este argumento sólo se usa
           internamente si se ha indicado la impresión de límites.
\param[in] factorX Factor para multiplicar las coordenadas X de los vértices
           antes de imprimirlas.
\param[in] factorY Factor para multiplicar las coordenadas Y de los vértices
           antes de imprimirlas.
\param[in] idFich Identificador de fichero abierto para escribir.
\note Esta función está paralelizada con OpenMP.
\note La cabecera completa tiene el siguiente formato:
      <tt>iniCab númVert xMín xMáx yMín yMáx</tt>.
\note Si la estructura no tiene información de límites y se indica que se
      impriman, los valores se calculan internamente.
\note Esta función asume que \em poli es una estructura \ref polil correctamente
      almacenada.
\note Esta función no comprueba si la estructura pasada tiene memoria asignada.
\note Esta función no comprueba internamente la validez de los argumentos de
      formato.
\note Esta función no comprueba internamente si el identificador pasado
      corresponde a un fichero abierto para escribir.
\date 18 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void ImprimeCabeceraPolilFichero(const polil* poli,
                                 const size_t indice,
                                 const char iniCab[],
                                 const int impLim,
                                 const char formCoor[],
                                 const double factorX,
                                 const double factorY,
                                 FILE* idFich);
/******************************************************************************/
/******************************************************************************/
/**
\brief Imprime una estructura \ref polil en un fichero.
\param[in] poli Estructura \ref polil.
\param[in] factorX Factor para multiplicar las coordenadas X de los vértices
           antes de imprimirlas.
\param[in] factorY Factor para multiplicar las coordenadas Y de los vértices
           antes de imprimirlas.
\param[in] iniNan Identificador para imprimir o no la marca de separación de
           polilíneas (\p NaN) delante de la primera polilínea. Dos posibles
           valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] finNan Identificador para imprimir o no la marca de separación de
           polilíneas (\p NaN) delante de la última polilínea. Dos posibles
           valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] formCoor Cadena de carácteres indicadora del formato de cada
           coordenada a imprimir.
\param[in] impCabecera Identificador para imprimir o no una cabecera con
           información general por cada polilínea. Dos posibles valores:
           - 0: No se imprime.
           - Distinto de 0: Sí se imprime.
\param[in] iniCab Cadena de texto con la que comenzará la cabecera.
\param[in] impLim Identificador para imprimir o no en la cabecera los límites de
           coordenadas de las polilíneas de trabajo. Dos posibles valores:
           - 0: No se imprimen.
           - Distinto de 0: Sí se imprimen.
\param[in] idFich Identificador de fichero abierto para escribir.
\note La cabecera completa tiene el siguiente formato:
      <tt>iniCab númVert xMín xMáx yMín yMáx</tt>.
\note Si la estructura no tiene información de límites y se indica que se
      impriman, los valores se calculan internamente.
\note Esta función asume que \em poli es una estructura \ref polil correctamente
      almacenada.
\note Esta función no comprueba si la estructura pasada tiene memoria asignada.
\note Esta función no comprueba internamente la validez de los argumentos de
      formato.
\note Esta función no comprueba internamente si el identificador pasado
      corresponde a un fichero abierto para escribir.
\date 03 de junio de 2011: Creación de la función.
\date 18 de junio de 2011: Adición de la capacidad de escritura de una cabecera
      y del uso de factores de escala independientes para las coordenadas X e Y.
\date 22 de septiembre de 2011: Corregido bug que hacía que, dependiendo del
      compilador y/o los flags de optimización en la compilación, se imprimiesen
      mal (con un signo menos delante) los valores Not-a-Number.
\note Esta función todavía no está probada.
*/
void ImprimePolilFichero(const polil* poli,
                         const double factorX,
                         const double factorY,
                         const int iniNan,
                         const int finNan,
                         const char formCoor[],
                         const int impCabecera,
                         const char iniCab[],
                         const int impLim,
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

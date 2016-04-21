/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file recpolil.h
\brief Definición de estructuras y declaración de funciones para el recorte de
       polilíneas por medio de polígonos.
\author José Luis García Pallero, jgpallero@gmail.com
\date 04 de junio de 2011
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
#ifndef _RECPOLIL_H_
#define _RECPOLIL_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include<math.h>
#include"libgeoc/errores.h"
#include"libgeoc/eucli.h"
#include"libgeoc/geocnan.h"
#include"libgeoc/greiner.h"
#include"libgeoc/polig.h"
#include"libgeoc/polil.h"
#include"libgeoc/ptopol.h"
#include"libgeoc/segmento.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_RECPOLIL_BUFFER_PTOS
\brief Número de puntos para ir asignando memoria en bloques para las polilíneas
       de salida en la funcion \ref Paso2Recpolil. Ha de ser un número mayor o
       igual a 2.
\date 04 de junio de 2011: Creación de la constante.
*/
#define GEOC_RECPOLIL_BUFFER_PTOS 100
/******************************************************************************/
/******************************************************************************/
/** \enum GEOC_OP_BOOL_POLIL
\brief Operación booleana entre polilínea y polígono.
\date 04 de junio de 2011: Creación del tipo.
*/
enum GEOC_OP_BOOL_POLIL
{
    /** \brief Polilínea interior al polígono. */
    GeocOpBoolDentro=111,
    /** \brief Polilínea exterior al polígono. */
    GeocOpBoolFuera=112
};
/******************************************************************************/
/******************************************************************************/
/** \struct _vertPolilClip
\brief Estructura de definición de un vértice de una polilínea usada en
       operaciones de recorte. La polilínea se almacena en memoria como una
       lista doblemente enlazada de vértices.
\date 04 de junio de 2011: Creación de la estructura.
*/
typedef struct _vertPolilClip
{
    /** \brief Coordenada X del vértice. */
    double x;
    /** \brief Coordenada Y del vértice. */
    double y;
    /** \brief Vértice anterior. */
    struct _vertPolilClip* anterior;
    /** \brief Vértice siguiente. */
    struct _vertPolilClip* siguiente;
    /**
    \brief Indicador de punto de la polilínea original.

           Dos posibilidades:
           - 0: No es un punto de la polilínea original.
           - Distinto de 0: Sí es un punto de la polilínea original.
    */
    char orig;
    /**
    \brief Posición del vértice con respecto al polígono de recorte.

           Tres posibilidades:
           - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
           - #GEOC_PTO_BORDE_POLIG: El punto está en el borde o en un vértice
             del polígono.
           - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
    */
    char pos;
    /** \brief Distancia, en tanto por uno, de un nodo de intersección con
               respecto al primer vértice del segmento que lo contiene. */
    double alfa;
}vertPolilClip;
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea un vértice de tipo \ref _vertPolilClip y lo inserta entre otros dos.
\param[in] x Coordenada X del vértice.
\param[in] y Coordenada Y del vértice.
\param[in] anterior Vértice anterior (puede ser \p NULL).
\param[in] siguiente Vértice siguiente (puede ser \p NULL).
\param[in] orig Campo _vertPolilClip::orig.
\param[in] pos Campo _vertPolilClip::pos.
\param[in] alfa Campo _vertPolilClip::alfa.
\return Puntero al nuevo vértice creado. Si se devuelve \p NULL, ha ocurrido un
        error de asignación de memoria.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPolilClip* CreaVertPolilClip(const double x,
                                 const double y,
                                 vertPolilClip* anterior,
                                 vertPolilClip* siguiente,
                                 const char orig,
                                 const char pos,
                                 const double alfa);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una polilínea, como una lista doblemente enlazada de elementos
       \ref _vertPolilClip.
\param[in] x Vector de coordenadas X de los nodos de la polilínea.
\param[in] y Vector de coordenadas Y de los nodos de la polilínea.
\param[in] nCoor Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\return Puntero al primer vértice de la lista. Si se devuelve \p NULL, ha
        ocurrido un error de asignación de memoria.
\note Esta función asume que el argumento \em nCoor es mayor que 0.
\note Si en los vectores de coordenadas \em x e \em y hay valores #GEOC_NAN,
      éstos no se tienen en cuenta a la hora de la creación de la estructura de
      salida.
\note Que los vectores de coordenadas \em x e \em y admitan vértices con
      coordenadas (#GEOC_NAN,#GEOC_NAN) no quiere decir que éstos sean
      separadores de múltiples polilíneas. \em x e \em y \b *SÓLO* deben
      almacenar una única polilínea.
\note Esta función asigna el valor 0 a todos los campos _vertPolilClip::pos de
      los elementos creados.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPolilClip* CreaPolilClip(const double* x,
                             const double* y,
                             const size_t nCoor,
                             const size_t incX,
                             const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Libera la memoria asignada a una polilínea almacenada como una lista
       doblemente enlazada de elementos \ref _vertPolilClip.
\param[in] poli Puntero al primer elemento de la polilínea.
\note Esta función no comprueba si hay vértices de la polilínea anteriores al
      vértice de entrada, por lo que si se quiere liberar toda la memoria
      asignada a una polilínea, el vértice pasado ha de ser el primero de la
      lista.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void LibMemPolilClip(vertPolilClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Elimina los vértices no originales de una polilínea almacenada como una
       lista doblemente enlazada de elementos \ref _vertPolilClip.
\param[in] poli Puntero al primer elemento de la polilínea.
\return Puntero al primer elemento de la polilínea original. Si se devuelve
        \p NULL, ninguno de los vértices pertenecía a la polilínea original.
\note Los vértices eliminados por esta función son todos aquéllos cuyo campo
      _vertPolilClip::orig sea igual a 0.
\note Aunque se supone que el primer vértice de una polilínea siempre es un
      vértice original, si no lo es, la variable de entrada queda modificada.
      Por tanto, siempre es recomendable capturar la variable de salida, que
      garantiza la posición del primer elemento.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPolilClip* ReiniciaPolilClip(vertPolilClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el siguiente vértice original en una polilínea.
\param[in] vert Puntero al vértice a partir del cual se ha de buscar.
\return Puntero al siguiente vértice original en la polilínea. Si se devuelve
        \p NULL, se ha llegado al final.
\note Los vértices no originales son todos aquéllos cuyo campo
      _vertPolilClip::orig es distinto de 0.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPolilClip* SiguienteVertOrigPolilClip(vertPolilClip* vert);
/******************************************************************************/
/******************************************************************************/
/**
\brief Inserta un vértice de tipo \ref _vertPolilClip entre otros dos,
       atendiendo al campo _vertPolilClip::alfa.
\param[in] ins Vértice a insertar.
\param[in] extremoIni Extremo inicial del segmento donde se insertará \em ins.
\param[in] extremoFin Extremo final del segmento donde se insertará \em ins.
\note Esta función asume que todos los elementos pasados tienen memoria
      asignada.
\note Si entre \em extremoIni y \em extremoFin hay más vértices, \em ins se
      insertará de tal modo que los campos _vertPolilClip::alfa queden ordenados
      de menor a mayor.
\note Si el campo _vertPolilClip::alfa de \em ins tiene el mismo valor que el
      de \em extremoIni, \em ins se insertará justo a continuación de
      \em extremoIni.
\note Si el campo _vertPolilClip::alfa de \em ins tiene el mismo valor que el
      de \em extremoFin, \em ins se insertará justo antes de \em extremoIni.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void InsertaVertPolilClip(vertPolilClip* ins,
                          vertPolilClip* extremoIni,
                          vertPolilClip* extremoFin);
/******************************************************************************/
/******************************************************************************/
/**
\brief Cuenta el número de vértices originales que hay en una polilínea
       almacenada como una lista doblemente enlazada de elementos
       \ref _vertPolilClip.
\param[in] poli Polilínea, almacenado como una lista doblemente enlazada de
           elementos \ref _vertPolilClip. Sólo se tienen en cuenta los vértices
           originales de la polilínea, que son todos aquéllos cuyo campo
           _vertPolilClip::orig es distinto de 0.
\return Número de vértices originales almacenados.
\note Esta función no comprueba si la variable \em poli es una polilínea
      correctamente almacenada.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
size_t NumeroVertOrigPolilClip(vertPolilClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Cuenta el número total de vértices que hay en una polilínea almacenada
       como una lista doblemente enlazada de elementos \ref _vertPolilClip.
\param[in] poli Polilínea, almacenado como una lista doblemente enlazada de
           elementos \ref _vertPolilClip. Se tienen en cuenta todos los
           vértices.
\return Número total de vértices almacenados.
\note Esta función no comprueba si la variable \em poli es una polilínea
      correctamente almacenada.
\date 04 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
size_t NumeroVertPolilClip(vertPolilClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza el paso número 1 del algoritmo de recorte de polilíneas, que
       consiste en el cálculo de los puntos de intersección de la polilínea de
       trabajo con el polígono de recorte.

       Este paso está inspirado en el primer paso del algoritmo de
       Greiner-Hormann.
\param[in,out] poli Polilínea de trabajo, representada como una lista doblemente
               enlazada de elementos \ref _vertPolilClip. Al término de la
               ejecución de la función se le han añadido los puntos de
               intersección con el polígono de recorte y se han asignado los
               valores correctos al campo _vertPolilClip::pos de cada vértice.
\param[in] poliRec Polígono de recorte, representado como una lista doblemente
           enlazada de elementos \ref _vertPoliClip.
\param[out] nIntersec Número de intersecciones (intersecciones propiamente
            dichas y puntos en el borde del polígono) calculadas.
\return Variable de estado. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si las variables \em polil y \em poliRec son
      estructuras correctamente almacenadas.
\note El polígono \em poliRec puede provenir de una operación booleana previa
      entre polígonos, ya que sólo se recorrerán sus vértices originales, que
      serán aquéllos cuyo campo _vertPoliClip::interseccion valga 0.
\date 06 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int Paso1Recpolil(vertPolilClip* poli,
                  vertPoliClip* poliRec,
                  size_t* nIntersec);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza el paso número 2 del algoritmo de recorte de polilíneas, que
       consiste en la generación de lss polilíneas resultado.
\param[in] poli Polilínea a recortar, representada como una lista doblemente
                enlazada de elementos \ref _vertPolilClip, tal y como sale de la
                función \ref Paso1Recpolil.
\param[in] op Identificador de la operación a realizar. Ha de ser un elemento
           del tipo enumerado #GEOC_OP_BOOL_POLIL.
\return Estructura \ref polil con las polilíneas resultado de la operación. Si
        se devuelve \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si la variable \em polil es una polilínea
      correctamente almacenada.
\date 06 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
polil* Paso2Recpolil(vertPolilClip* poli,
                     const enum GEOC_OP_BOOL_POLIL op);
/******************************************************************************/
/******************************************************************************/
/**
\brief Recorta una polilínea según un polígono de recorte.
\param[in,out] poli Polilínea de trabajo, representada como una lista doblemente
               enlazada de elementos \ref _vertPolilClip. Al término de la
               ejecución de la función se le han añadido los puntos de
               intersección con el polígono de recorte y se han asignado los
               valores correctos al campo _vertPolilClip::pos de cada vértice.
\param[in] poliRec Polígono de recorte, representado como una lista doblemente
           enlazada de elementos \ref _vertPoliClip.
\param[in] op Identificador de la operación a realizar. Ha de ser un elemento
           del tipo enumerado #GEOC_OP_BOOL_POLIL. Varias posibilidades:
           - #GeocOpBoolDentro: Calcula la porción de \em poli que está dentro
             \em poliRec.
           - #GeocOpBoolFuera: Calcula la porción de \em poli que está fuera
             \em poliRec.
\param[out] nIntersec Número de intersecciones calculadas.
\return Estructura \ref polil con las polilíneas resultado de la operación. Si
        se devuelve \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si las variables \em poli y \em poliRec son
      estructuras correctamente almacenadas.
\note Esta función no comprueba internamente si \em op pertenece al tipo
      enumerado #GEOC_OP_BOOL_POLIL. Si se introduce un valor no perteneciente
      al tipo, se realiza la operación #GeocOpBoolDentro.
\note Esta función asume que los puntos de borde pertenecen al interior del
      polígono de recorte.
\note Esta función asume que los puntos de borde sólo pertenecen al exterior del
      polígono de recorte cuando son principio o final de polilínea recortada.
\date 06 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
polil* RecortaPolil(vertPolilClip* poli,
                    vertPoliClip* poliRec,
                    const enum GEOC_OP_BOOL_POLIL op,
                    size_t* nIntersec);
/******************************************************************************/
/******************************************************************************/
/**
\brief Recorta múltiples polilíneas según múltiples polígonos de recorte.
\param[in] poli Estructura \ref polil que almacena las polilíneas de trabajo.
\param[in] poliRec Estructura \ref polig que almacena los polígonos de recorte.
\param[in] op Identificador de la operación a realizar. Ha de ser un elemento
           del tipo enumerado #GEOC_OP_BOOL_POLIL. Varias posibilidades:
           - #GeocOpBoolDentro: Calcula la porción de las polilíneas almacenadas
             en \em poli que están dentro de los polígonos almacenados en
             \em poliRec.
           - #GeocOpBoolFuera: Calcula la porción de las polilíneas almacenadas
             en \em poli que están fuera de los polígonos almacenados en
             \em poliRec.
\param[out] nIntersec Número total de intersecciones calculadas entre todas las
            polilíneas con todos los polígonos.
\return Estructura \ref polil con las polilíneas resultado de las operaciones.
        Si se devuelve \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función realiza la operación \em op con todas las combinaciones
      posibles de polilíneas y polígonos. Es decir, se recorren todas las
      polilíneas y con cada una de ellas se realiza la operación \em op con cada
      polígono almacenado en \em poliRec.
\note Esta función no comprueba si las variables \em poli y \em poliRec son
      estructuras correctamente almacenadas.
\note Esta función no comprueba internamente si \em op pertenece al tipo
      enumerado #GEOC_OP_BOOL_POLIL. Si se introduce un valor no perteneciente
      al tipo, se realiza la operación #GeocOpBoolDentro.
\note Esta función asume que los puntos de borde pertenecen al interior de los
      polígonos de recorte.
\note Esta función asume que los puntos de borde sólo pertenecen al exterior de
      los polígonos de recorte cuando son principio o final de polilínea
      recortada.
\date 06 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
polil* RecortaPolilMult(const polil* poli,
                        const polig* poliRec,
                        const enum GEOC_OP_BOOL_POLIL op,
                        size_t* nIntersec);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una estructura \ref polil a partir de todos los vértices de una
       polilínea almacenada como una lista doblemente enlazada de elementos
       \ref _vertPolilClip.
\param[in] poli Polilínea de trabajo, representada como una lista doblemente
                enlazada de elementos \ref _vertPolilClip. El puntero pasado ha
                de apuntar al primer elemento de la polilínea (no se controla
                internamente).
\return Estructura \ref polil que representa la polilínea. Si se devuelve
        \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si la variable \em poli es una polilínea
      correctamente almacenada.
\note Esta función realiza una copia en memoria de las coordenadas de los
      vértices de la estructura \em poli a la estructura de salida.
\date 06 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
polil* CreaPolilPolilClip(vertPolilClip* poli);
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

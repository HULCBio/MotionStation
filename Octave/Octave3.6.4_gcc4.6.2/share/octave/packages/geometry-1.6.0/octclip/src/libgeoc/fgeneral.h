/* -*- coding: utf-8 -*- */
/**
\ingroup eop general geom geopot matriz
@{
\file fgeneral.h
\brief Declaración de macros y funciones de utilidad general.
\author José Luis García Pallero, jgpallero@gmail.com
\note Este fichero contiene funciones paralelizadas con OpenMP.
\date 25 de septiembre de 2009
\version 1.0
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
#ifndef _FGENERAL_H_
#define _FGENERAL_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include<stdint.h>
#include<float.h>
#include<math.h>
#include"libgeoc/constantes.h"
#include"libgeoc/errores.h"
#include"libgeoc/geocomp.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_SIGNO
\brief Macro para determinar el signo de un escalar.
\param[in] a Un número.
\return Signo del dato de entrada. Dos posibilidades:
        - -1.0: El dato pasado es negativo.
        - 1.0: El dato pasado es positivo o 0.0.
\date 10 de junio de 2011: Creación de la macro.
*/
#define GEOC_SIGNO(a) ((a)>=0.0 ? 1.0 : -1.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_MAX
\brief Macro para seleccionar el valor máximo entre dos escalares.
\param[in] a Un número.
\param[in] b Otro número.
\return El mayor de los dos argumentos de entrada.
\date 25 de septiembre de 2009: Creación de la macro.
*/
#define GEOC_MAX(a,b) ((a)>(b) ? (a) : (b))
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_MIN
\brief Macro para seleccionar el valor mínimo entre dos escalares.
\param[in] a Un número.
\param[in] b Otro número.
\return El menor de los dos argumentos de entrada.
\date 25 de septiembre de 2009: Creación de la macro.
*/
#define GEOC_MIN(a,b) ((a)<(b) ? (a) : (b))
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_PARI
\brief Macro para comprobar si un número de tipo entero es par.
\param[in] a Un número.
\return Dos posibilidades:
        - 0: El número es impar.
        - 1: El número es par.
\note Esta macro usa el operador \b % de C para calcular el resto de la división
      del número pasado entre 2, por lo que el argumento de entrada ha de ser de
      tipo entero: \p char, \p short, \p int, \p long o \p long \p long (con los
      identificadores \p signed o \p undigned).
\date 15 de marzo de 2011: Creación de la macro.
*/
#define GEOC_PARI(a) ((a)%2 ? 0 : 1)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ES_CERO
\brief Macro para comprobar si un número puede considerarse cero con una cierta
       tolerancia.
\param[in] num Número a comprobar.
\param[in] tol Tolerancia. Ha de ser un número \b POSITIVO.
\return Dos posibilidades:
        - 0: \em num es distinto de 0, tal que \f$num<=-tol\f$ o \f$num>=tol\f$.
        - 1: \em num es 0, tal que \f$ -tol < num < tol\f$.
\note Para que esta macro funcione correctamente, \em tol ha de ser un número
      \b POSITIVO.
\date 13 de marzo de 2010: Creación de la macro.
\todo Esta macro todavía no está probada.
*/
#define GEOC_ES_CERO(num,tol) (((num)>(-(tol)))&&((num)<(tol)) ? 1 : 0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_DBL
\brief Macro para realizar una conversión explícita a tipo de dato \p double.
\param[in] a Un número.
\return Órdenes para la conversión explícita del dato pasado a \p double.
\date 19 de junio de 2011: Creación de la macro.
*/
#define GEOC_DBL(a) ((double)(a))
/******************************************************************************/
/******************************************************************************/
/**
\brief Indica si hay alguna función compilada en paralelo con OpenMP en el
       fichero \ref fgeneral.c.
\param[out] version Cadena identificadora de la versión de OpenMP utilizada.
            Este argumento sólo se utiliza si su valor de entrada es distinto de
            \p NULL y si hay alguna función compilada con OpenMP.
\return Dos posibles valores:
        - 0: No hay ninguna función compilada en paralelo con OpenMP.
        - Distinto de 0: Sí hay alguna función compilada en paralelo con OpenMP.
\note Esta función asume que el argumento \em version tiene suficiente memoria
      asignada (si es distinto de \p NULL).
\date 22 de agosto de 2011: Creación de la función.
\date 25 de agosto de 2011: Adición del argumento de entrada \em version.
*/
int GeocParOmpFgeneral(char version[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Mete un ángulo en el dominio \f$]-2*\pi,2*\pi[\f$.
\param[in] angulo Valor angular, en radianes.
\return Valor angular de entrada, en el dominio \f$]-2*\pi,2*\pi[\f$, en
        radianes.
\note Esta función elimina todas las vueltas completas a la circunferencia que
      hacen que el posible valor de entrada esté fuera de los límites del
      dominio de salida.
\date 10 de junio de 2011: Creación de la función.
*/
double PonAnguloDominio(const double angulo);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca en una lista de coordenadas de una polilínea en una dimensión las
       posiciones de inicio y fin del segmento que encierra a un punto dado.
\param[in] valor Coordenada del punto de trabajo, contenido en el segmento a
           buscar.
\param[in] lista Lista con las coordenadas de la polilínea.
\param[in] nDatos Número de elementos de la lista de coordenadas pasadas.
\param[in] incDatos Posiciones de separación entre cada elemento de \em lista.
           Ha de ser un número positivo.
\param[out] posInicio Posición en \em lista de la coordenada inicial del
            segmento buscado.
\param[out] posFin Posición en \em lista de la coordenada final del segmento
            buscado.
\note Para convertir las posiciones devueltas por la función en las posiciones
      reales del array en memoria, han de ser multiplicadas por el valor
      \em incDatos.
\note En las siguientes notas, cuando se habla de la longitud o el número de
      elementos de \em lista quiere decir el número de datos de trabajo, no
      todas las posiciones almacenadas en memoria.
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con el valor \em nDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 2.
\note Esta función supone que los elementos almacenados en \em lista están
      ordenados de menor a mayor.
\note Esta función supone que \em lista[0] <= \em valor >= \em lista[nDatos-1].
\note Si algún elemento de \em lista es igual a \em valor, su posición será el
      punto de inicio del segmento calculado, excepto si el elemento de
      \em lista es el último, en cuyo caso será el punto final.
\date 06 de diciembre de 2010: Creación de la función.
*/
void BuscaSegmento1DInc(const double valor,
                        const double* lista,
                        const size_t nDatos,
                        const size_t incDatos,
                        size_t* posInicio,
                        size_t* posFin);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca en una lista de coordenadas de una polilínea en una dimensión las
       posiciones de inicio y fin del segmento que encierra a un punto dado.
\param[in] valor Coordenada del punto de trabajo, contenido en el segmento a
           buscar.
\param[in] lista Lista con las coordenadas de la polilínea.
\param[in] nDatos Número de elementos de la lista de coordenadas pasadas.
\param[out] posInicio Posición en \em lista de la coordenada inicial del
            segmento buscado.
\param[out] posFin Posición en \em lista de la coordenada final del segmento
            buscado.
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con el valor \em nDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 2.
\note Esta función supone que los elementos almacenados en \em lista están
      ordenados de menor a mayor.
\note Esta función supone que \em lista[0] <= \em valor >= \em lista[nDatos-1].
\note Si algún elemento de \em lista es igual a \em valor, su posición será el
      punto de inicio del segmento calculado, excepto si el elemento de
      \em lista es el último, en cuyo caso será el punto final.
\date 11 de octubre de 2009: Creación de la función.
*/
void BuscaSegmento1D(const double valor,
                     const double* lista,
                     const size_t nDatos,
                     size_t* posInicio,
                     size_t* posFin);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca las posiciones fila y columna del elemento de una matriz
       correspondiente a la esquina NW del cuadrado que encierra a un punto
       dado.
\param[in] xPto Coordenada X del punto de trabajo.
\param[in] yPto Coordenada Y del punto de trabajo.
\param[in] xMin Coordenada X mínima (esquina W) de los puntos almacenados en la
           matriz.
\param[in] xMax Coordenada X máxima (esquina E) de los puntos almacenados en la
           matriz.
\param[in] yMin Coordenada Y mínima (esquina S) de los puntos almacenados en la
           matriz.
\param[in] yMax Coordenada Y máxima (esquina N) de los puntos almacenados en la
           matriz.
\param[in] pasoX Paso de malla (valor absoluto) en la dirección X.
\param[in] pasoY Paso de malla (valor absoluto) en la dirección Y.
\param[out] fil Fila del elemento NW del cuadrado que encierra al punto de
            trabajo.
\param[out] col Columna del elemento NW del cuadrado que encierra al punto de
            trabajo.
\note Esta función no comprueba internamente si las coordenadas del punto de
      trabajo son congruentes con los límites de la matriz.
\note Esta función asume que los pasos de malla son congruentes con los límites
      de la malla (supone que el cálculo del número de nodos es un número
      entero o del tipo X.9... o X.0...).
\note Esta función asume que \em xMin < \em xMax y que \em yMin < \em yMax.
\note Esta función asume que \em pasoX y \em pasoY han sido introducidos en
      valor absoluto.
\date 15 de mayo de 2010: Creación de la función.
\date 25 de septiembre de 2011: Corrección de error que hacía que se calculase
      una fila de más en determinados casos.
\todo Esta función no está probada.
*/
void BuscaPosNWEnMalla(const double xPto,
                       const double yPto,
                       const double xMin,
                       const double xMax,
                       const double yMin,
                       const double yMax,
                       const double pasoX,
                       const double pasoY,
                       size_t* fil,
                       size_t* col);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el elemento de mínimo valor en una lista de tipo \p double.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\return Elemento de mínimo valor.
\note Esta función se puede ejecutar en paralelo con OpenMP, versión 3.1 o
      superior (se detecta automáticamente en la compilación).
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\date 22 de agosto de 2011: Creación de la función.
\todo Esta función todavía no está probada con OpenMP.
*/
double Minimo(const double* lista,
              const size_t nDatos,
              const size_t incDatos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el elemento de máximo valor en una lista de tipo \p double.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\return Elemento de máximo valor.
\note Esta función se puede ejecutar en paralelo con OpenMP, versión 3.1 o
      superior (se detecta automáticamente en la compilación).
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\date 22 de agosto de 2011: Creación de la función.
\todo Esta función todavía no está probada con OpenMP.
*/
double Maximo(const double* lista,
              const size_t nDatos,
              const size_t incDatos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el elemento de mínimo valor absoluto en una lista de tipo
       \p double.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\return Elemento de mínimo valor absoluto.
\note Esta función se puede ejecutar en paralelo con OpenMP, versión 3.1 o
      superior (se detecta automáticamente en la compilación).
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\date 22 de agosto de 2011: Creación de la función.
\todo Esta función todavía no está probada con OpenMP.
*/
double MinimoAbs(const double* lista,
                 const size_t nDatos,
                 const size_t incDatos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el elemento de máximo valor absoluto en una lista de tipo
       \p double.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\return Elemento de máximo valor absoluto.
\note Esta función se puede ejecutar en paralelo con OpenMP, versión 3.1 o
      superior (se detecta automáticamente en la compilación).
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\date 22 de agosto de 2011: Creación de la función.
\todo Esta función todavía no está probada con OpenMP.
*/
double MaximoAbs(const double* lista,
                 const size_t nDatos,
                 const size_t incDatos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el elemento de mínimo valor en una lista de tipo \p size_t.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\return Elemento de mínimo valor.
\note Esta función se puede ejecutar en paralelo con OpenMP, versión 3.1 o
      superior (se detecta automáticamente en la compilación).
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\date 24 de agosto de 2011: Creación de la función.
\todo Esta función todavía no está probada con OpenMP.
*/
size_t MinimoSizeT(const size_t* lista,
                   const size_t nDatos,
                   const size_t incDatos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el elemento de máximo valor en una lista de tipo \p size_t.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\return Elemento de máximo valor.
\note Esta función se puede ejecutar en paralelo con OpenMP, versión 3.1 o
      superior (se detecta automáticamente en la compilación).
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\date 24 de agosto de 2011: Creación de la función.
\todo Esta función todavía no está probada con OpenMP.
*/
size_t MaximoSizeT(const size_t* lista,
                   const size_t nDatos,
                   const size_t incDatos);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca las posiciones que ocupan en una lista de tipo \p double los
       elementos de menor y mayor valor.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\param[out] posMin Posición en \em lista del elemento de menor valor.
\param[out] posMax Posición en \em lista del elemento de mayor valor.
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\note Si hay varios elementos en la lista que se corresponden con el valor menor
      o mayor, la posición devuelta es la correspondiente al primer elemento a
      partir del inicio.
\note Las posiciones devueltas lo son atendiendo al parámetro \em nDatos, por lo
      que para obtener las posiciones reales del elemento en memoria han de ser
      multiplicadas por el valor \em incDatos.
\date 27 de octubre de 2009: Creación de la función.
\date 29 de mayo de 2011: Adición del argumento de entrada \em incDatos.
*/
void MinMax(const double* lista,
            const size_t nDatos,
            const size_t incDatos,
            size_t* posMin,
            size_t* posMax);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca las posiciones que ocupan en una lista los elementos de menor y
       mayor valor absoluto.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\param[out] posMin Posición en \em lista del elemento de menor valor absoluto.
\param[out] posMax Posición en \em lista del elemento de mayor valor absoluto.
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\note Si hay varios elementos en la lista que se corresponden con el valor menor
      o mayor, la posición devuelta es la correspondiente al primer elemento a
      partir del inicio.
\note Las posiciones devueltas lo son atendiendo al parámetro \em nDatos, por lo
      que para obtener las posiciones reales del elemento en memoria han de ser
      multiplicadas por el valor \em incDatos.
\date 27 de octubre de 2009: Creación de la función.
\date 29 de mayo de 2011: Adición del argumento de entrada \em incDatos.
*/
void MinMaxAbs(const double* lista,
               const size_t nDatos,
               const size_t incDatos,
               size_t* posMin,
               size_t* posMax);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca las posiciones que ocupan en una lista de tipo \p size_t los
       elementos de menor y mayor valor.
\param[in] lista Lista de valores.
\param[in] nDatos Número de elementos de la lista de valores.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em lista. Este argumento siempre ha de ser un número positivo.
\param[out] posMin Posición en \em lista del elemento de menor valor.
\param[out] posMax Posición en \em lista del elemento de mayor valor.
\note Esta función no comprueba internamente si la longitud de \em lista es
      congruente con los valores de \em nDatos e \em incDatos.
\note Esta función supone que \em lista contiene un número de elementos >= 1.
\note Si hay varios elementos en la lista que se corresponden con el valor menor
      o mayor, la posición devuelta es la correspondiente al primer elemento a
      partir del inicio.
\note Las posiciones devueltas lo son atendiendo al parámetro \em nDatos, por lo
      que para obtener las posiciones reales del elemento en memoria han de ser
      multiplicadas por el valor \em incDatos.
\date 08 de enero de 2010: Creación de la función.
\date 29 de mayo de 2011: Adición del argumento de entrada \em incDatos.
*/
void MinMaxSizeT(const size_t* lista,
                 const size_t nDatos,
                 const size_t incDatos,
                 size_t* posMin,
                 size_t* posMax);
/******************************************************************************/
/******************************************************************************/
/**
\brief Asigna memoria para una matriz bidimensional en estilo C.
\param[in] fil Número de filas de la matriz.
\param[in] col Número de columnas de la matriz.
\return Puntero a la matriz creada. Si ocurre algún error de asignación de
        memoria, se devuelve NULL.
\note La memoria asignada no se inicializa a ningún valor.
\note Los datos se almacenan en ROW MAJOR ORDER de forma contigua en memoria.
\note Esta función no controla si alguna de las dimensiones pasadas es 0.
\date 14 de enero de 2010: Creación de la función.
\date 02 de diciembre de 2010: Reprogramación de la función para que los datos
      se almacenen en memoria de forma contigua.
*/
double** AsigMemMatrizC(const size_t fil,
                        const size_t col);
/******************************************************************************/
/******************************************************************************/
/**
\brief Libera memoria de una matriz bidimensional en estilo C.
\param[in] matriz Puntero al espacio de memoria a liberar.
\date 14 de enero de 2010: Creación de la función.
\date 27 de febrero de 2010: Corregido bug que hacía que la función diese error
      si se le pasaba un puntero a NULL.
*/
void LibMemMatrizC(double** matriz);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula las posiciones de comienzo de elementos repetidos en un vector.

       - Para un vector de datos [1,2,2,3,4,4] se devuelve el vector de
         posiciones [0,1,3,4].
       - Para un vector de datos [1,2,2,3,4] se devuelve el vector de posiciones
         [0,1,3,4].
       - Para un vector de datos [1,1,1,1,1] se devuelve el vector de posiciones
         [0].
       - Para un vector de datos [1] se devuelve el vector de posiciones [0].
\param[in] datos Vector de datos.
\param[in] nDatos Número de elementos de \em datos. No puede ser 0.
\param[in] incDatos Posiciones de separación entre los elementos del vector
           \em datos. Este argumento siempre ha de ser un número positivo.
\param[out] nRepe Número de elementos del vector de posiciones de comienzo de
            elementos repetidos devuelto por la función.
\return Vector, de \em nRepe elementos, que almacena las posiciones de comienzo
        de elementos repetidos en el vector \em datos. Las posiciones devueltas
        no tienen en cuenta el argumento \em incDatos, luego no son posiciones
        en el array realmente almacenado en memoria. Los índices comienzan en 0.
        Si ocurre un error de asignación de memoria se devuelve \p NULL.
\note Esta función no comprueba internamente el vector pasado contiene
      suficiente memoria.
\note Esta función no comprueba internamente si las dimensiones del vector
      pasado son congruentes con el espacio almacenado en memoria.
\note Esta función no comprueba internamente si el argumento \em nDatos es
      igual a 0.
\note Para calcular con los valores de salida las posiciones reales en el vector
      \em datos es necesario tener en cuenta el argumento \em incDatos.
\date 02 de febrero de 2011: Creación de la función.
*/
size_t* PosRepeEnVector(const double* datos,
                        const size_t nDatos,
                        const size_t incDatos,
                        size_t* nRepe);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula el número de elementos repetidos en un vector a partir de la
       salida de la función \ref PosRepeEnVector.

       - Para un vector de datos [1,2,2,3,4,4], donde la función
         \ref PosRepeEnVector devuelve el vector de posiciones [0,1,3,4], esta
         función devuelve el vector [1,2,1,2].
       - Para un vector de datos [1,2,2,3,4], donde la función
         \ref PosRepeEnVector devuelve el vector de posiciones [0,1,3,4], esta
         función devuelve el vector [1,2,1,1].
       - Para un vector de datos [1,1,1,1,1], donde la función
         \ref PosRepeEnVector devuelve el vector de posiciones [0], esta función
         devuelve el vector [5].
       - Para un vector de datos [1], donde la función
         \ref PosRepeEnVector devuelve el vector de posiciones [0], esta función
         devuelve el vector [1].
\param[in] pos Vector de posiciones devuelto por la función
           \ref PosRepeEnVector.
\param[in] nPos Número de elementos de \em pos. No puede ser 0.
\param[in] nElemVecOrig Número de elementos del vector de datos original.
\return Vector, de \em nPos elementos, que almacena el número de elementos
        repetidos a partir de cada posición (incluida ésta) almacenada en el
        vector \em pos. Si ocurre un error de asignación de memoria se devuelve
        \p NULL.
\note Esta función no comprueba internamente el vector pasado contiene
      suficiente memoria.
\note Esta función no comprueba internamente si las dimensiones del vector
      pasado son congruentes con el espacio almacenado en memoria.
\note Esta función no comprueba internamente si el argumento \em nPos es igual a
      0.
\date 02 de febrero de 2011: Creación de la función.
*/
size_t* NumElemRepeEnVector(const size_t* pos,
                            const size_t nPos,
                            const size_t nElemVecOrig);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica un factor de escala y una traslación (en este orden) a los
       elementos de un vector.
\param[in,out] vector Vector de datos. Al término de la ejecución de la función,
               se ha aplicado un factor de escala y una traslación (en este
               orden) a los elementos del vector.
\param[in] nElem Número de elementos de \em vector.
\param[in] inc Posiciones de separación entre los elementos del vector
           \em vector. Este argumento siempre ha de ser un número positivo.
\param[in] escala Factor de escala a aplicar.
\param[in] traslada Traslación a aplicar.
\note Primero se aplica el factor de escala y luego la traslación.
\note Esta función asume que el vector de entrada \em vector tiene memoria
      asignada.
\date 18 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void EscalaYTrasladaVector(double* vector,
                           const size_t nElem,
                           const size_t inc,
                           const double escala,
                           const double traslada);
/******************************************************************************/
/******************************************************************************/
/**
\brief Aplica una traslación y un factor de escala (en este orden) a los
       elementos de un vector.
\param[in,out] vector Vector de datos. Al término de la ejecución de la función,
               se ha aplicado una traslación y un factor de escala (en este
               orden) a los elementos del vector.
\param[in] nElem Número de elementos de \em vector.
\param[in] inc Posiciones de separación entre los elementos del vector
           \em vector. Este argumento siempre ha de ser un número positivo.
\param[in] escala Factor de escala a aplicar.
\param[in] traslada Traslación a aplicar.
\note Primero se aplica la traslación y luego el factor de escala.
\note Esta función asume que el vector de entrada \em vector tiene memoria
      asignada.
\date 18 de junio de 2011: Creación de la función.
\note Esta función todavía no está probada.
*/
void TrasladaYEscalaVector(double* vector,
                           const size_t nElem,
                           const size_t inc,
                           const double escala,
                           const double traslada);
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

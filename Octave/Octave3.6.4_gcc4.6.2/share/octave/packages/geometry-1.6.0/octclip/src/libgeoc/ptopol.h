/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file ptopol.h
\brief Declaración de funciones para la realización de chequeos de inclusión de
       puntos en polígonos.

En el momento de la compilación ha de seleccionarse el tipo de dato que se
utilizará en los cálculos intermedios de las funciones
\ref PtoEnPoligonoVerticeBorde y \ref PtoEnPoligonoVerticeBordeDouble. Si los
puntos de trabajo están muy alejados de los polígonos pueden darse casos de
resultados erróneos. Sería conveniente que los cálculos internedios se hiciesen
en variables de 64 bits, pero el tipo <tt>long int</tt> suele ser de 4 bytes en
procesadores de 32 bits. Para seleccionar este tipo como <tt>long long int</tt>,
lo que en procesadores de 32 bits equivale a una variable de 64 bits, es
necesario definir la variable para el preprocesador \em PTOPOL_BORDE_LONG_64. En
procesadores de 64 bits no es necesario (aunque puede utilizarse), ya que el
tipo <tt>long int</tt> tiene una longitud de 64 bits. Si no se define la
variable, se usará un tipo <tt>long int</tt> para los cálculos intermedios. En
\p gcc, las variables para el preprocesador se pasan como \em -DXXX, donde
\em XXX es la variable a introducir. El uso del tipo <tt>long long int</tt> en
procesadores de 32 bits puede hacer que las funciones se ejecuten hasta 10 veces
más lentamente que si se utiliza el tipo <tt>long int</tt>. Con cálculos
internos de 32 bits las coordenadas de los vértices del polígono no han de estar
más lejos de las de los puntos de trabajo de unas 40000 unidades. Con cálculos
de 64 bits, los polígonos pueden estar alejados de los puntos de trabajo unas
3000000000 unidades, lo que corresponde a coordenadas Y UTM ajustadas al
centímetro. Con esto podríamos chequear un punto en un polo con respecto a un
polígono en el ecuador en coordenadas UTM expresadas en centímetros.
\author José Luis García Pallero, jgpallero@gmail.com
\note Este fichero contiene funciones paralelizadas con OpenMP.
\date 05 de abril de 2010
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
#ifndef _PTOPOL_H_
#define _PTOPOL_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include<math.h>
#include"libgeoc/errores.h"
#include"libgeoc/geocnan.h"
#include"libgeoc/geocomp.h"
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_PTO_FUERA_POLIG
\brief Identificador de punto fuera de un polígono.
\date 12 de abril de 2011: Creación de la constante.
*/
#define GEOC_PTO_FUERA_POLIG 0
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_PTO_DENTRO_POLIG
\brief Identificador de punto dentro de un polígono.
\date 12 de abril de 2011: Creación de la constante.
*/
#define GEOC_PTO_DENTRO_POLIG 1
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_PTO_VERTICE_POLIG
\brief Identificador de punto que es un vértice de un polígono.
\date 12 de abril de 2011: Creación de la constante.
*/
#define GEOC_PTO_VERTICE_POLIG 2
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_PTO_BORDE_POLIG
\brief Identificador de punto que está en el borde de un polígono.
\date 12 de abril de 2011: Creación de la constante.
*/
#define GEOC_PTO_BORDE_POLIG 3
/******************************************************************************/
/******************************************************************************/
/**
\typedef ptopol_long
\brief Nombre del tipo <tt>long int</tt> o <tt>long long int</tt> para utilizar
       en los cálculos intermedios de las funciones
       \ref PtoEnPoligonoVerticeBorde y \ref PtoEnPoligonoVerticeBordeDouble. Si
       los puntos de trabajo están muy alejados de los polígonos pueden darse
       casos de resultados erróneos. Sería conveniente que los cálculos
       internedios se hiciesen en variables de 64 bits, pero el tipo
       <tt>long int</tt> suele ser de 4 bytes en procesadores de 32 bits.
       Mediante la variable del preprocesador PTOPOL_BORDE_LONG_64 indicamos que
       este tipo sea <tt>long long int</tt>, lo que en procesadores de 32 bits
       equivale a una variable de 64 bits.
\note Este tipo de dato sólo es para uso interno en el fichero \ref ptopol.c. No
      se recomienda su uso fuera de él, ya que habría que tener el cuenta la
      variable del preprocesador cada vez que se incluyera este fichero
      (\ref ptopol.h) en un programa u otro fichero.
\date 19 de abril de 2011: Creación del tipo.
*/
#if defined(PTOPOL_BORDE_LONG_64)
typedef long long int ptopol_long;
#else
typedef long int ptopol_long;
#endif
/******************************************************************************/
/******************************************************************************/
/**
\brief Indica si hay alguna función compilada en paralelo con OpenMP en el
       fichero \ref ptopol.c.
\return Dos posibles valores:
        - 0: No hay ninguna función compilada en paralelo con OpenMP.
        - Distinto de 0: Sí hay alguna función compilada en paralelo con OpenMP.
\note Esta función asume que el argumento \em version tiene suficiente memoria
      asignada (si es distinto de \p NULL).
\date 13 de abril de 2011: Creación de la función.
\date 25 de agosto de 2011: Adición del argumento de entrada \em version.
*/
int GeocParOmpPtopol(char version[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Indica si se está utilizando el tipo <tt>log long int</tt> para la
       realización de cálculos intermedios en las funciones de chequeo de puntos
       en polígonos que son capaces de detectar si un punto está en el borde.
\return Dos posibles valores:
        - 0: No se está utilizando <tt>log long int</tt>.
        - Distinto de 0: Sí se está utilizando <tt>log long int</tt>.
\date 19 de abril de 2011: Creación de la función.
*/
int GeocLongLongIntPtopol(void);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en un rectángulo.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] xMin Coordenada X mínima del rectángulo.
\param[in] xMax Coordenada X máxima del rectángulo.
\param[in] yMin Coordenada Y mínima del rectángulo.
\param[in] yMax Coordenada Y máxima del rectángulo.
\return Varias posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del rectángulo.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del rectángulo.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice del rectángulo.
        - #GEOC_PTO_BORDE_POLIG: El punto pertenece a la frontera del
          rectángulo, pero no es un vértice.
\note Esta función asume que \em xMin<xMax e \em yMin<yMax.
\date 05 de abril de 2010: Creación de la función.
\date 12 de abril de 2011: Las variables de salida son ahora constantes
      simbólicas.
\todo Esta función no está probada.
*/
int PtoEnRectangulo(const double x,
                    const double y,
                    const double xMin,
                    const double xMax,
                    const double yMin,
                    const double yMax);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un rectángulo 1 está contenido íntegramente en otro 2.
\param[in] borde Identificador para indicar si los bordes se tienen en cuenta o
           no. Dos posibilidades:
           - 0: Lo bordes \b *NO* se tienen en cuenta. Es decir, si algún borde
             de un rectángulo coincide con el de otro, el resultado es que el
             rectángulo 1 no está contenido en 2.
           - Distinto de 0: Lo bordes \b *SÍ* se tienen en cuenta. Es decir, el
             que un borde del rectángulo 1 coincida con otro del rectángulo 2 no
             impide que 1 esté contenido en 2.
\param[in] xMin1 Coordenada X mínima del rectángulo 1.
\param[in] xMax1 Coordenada X máxima del rectángulo 1.
\param[in] yMin1 Coordenada Y mínima del rectángulo 1.
\param[in] yMax1 Coordenada Y máxima del rectángulo 1.
\param[in] xMin2 Coordenada X mínima del rectángulo 2.
\param[in] xMax2 Coordenada X máxima del rectángulo 2.
\param[in] yMin2 Coordenada Y mínima del rectángulo 2.
\param[in] yMax2 Coordenada Y máxima del rectángulo 2.
\return Dos posibilidades:
        - 0: El rectángulo 1 no está contenido íntegramente en el rectángulo 2.
        - Distinto de 0: El rectángulo 1 está contenido íntegramente en el
          rectángulo 2.
\note Esta función asume que \em xMin1<xMax1, \em yMin1<yMax1, \em xMin2<xMax2 e
      \em yMin2<yMax2.
\date 20 de junio de 2010: Creación de la función.
\todo Esta función no está probada.
*/
int RectanguloEnRectangulo(const int borde,
                           const double xMin1,
                           const double xMax1,
                           const double yMin1,
                           const double yMax1,
                           const double xMin2,
                           const double xMax2,
                           const double yMin2,
                           const double yMax2);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si dos rectángulos son disjuntos.
\param[in] xMin1 Coordenada X mínima del rectángulo 1.
\param[in] xMax1 Coordenada X máxima del rectángulo 1.
\param[in] yMin1 Coordenada Y mínima del rectángulo 1.
\param[in] yMax1 Coordenada Y máxima del rectángulo 1.
\param[in] xMin2 Coordenada X mínima del rectángulo 2.
\param[in] xMax2 Coordenada X máxima del rectángulo 2.
\param[in] yMin2 Coordenada Y mínima del rectángulo 2.
\param[in] yMax2 Coordenada Y máxima del rectángulo 2.
\return Dos posibilidades:
        - 0: Los rectángulos no son disjuntos, es decir, tienen alguna parte
             común (se cortan o se tocan) o uno está completamente contenido en
             el otro.
        - Distinto de 0: Los rectángulos son disjuntos.
\note Esta función asume que \em xMin1<xMax1, \em yMin1<yMax1, \em xMin2<xMax2 e
      \em yMin2<yMax2.
\date 13 de junio de 2010: Creación de la función.
\todo Esta función no está probada.
*/
int RectDisjuntos(const double xMin1,
                  const double xMax1,
                  const double yMin1,
                  const double yMax1,
                  const double xMin2,
                  const double xMax2,
                  const double yMin2,
                  const double yMax2);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en un polígono de un número
       arbitrario de lados. Esta función puede no dar resultados correctos para
       puntos en los bordes y/o los vértices del polígono.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices del
           polígono. Puede contener varios polígonos.
\param[in] coorY Vector que contiene las coordenadas Y de los vértices del
           polígono. Puede contener varios polígonos.
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
\note El código de esta función ha sido tomado de
      http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html y
      se han hecho pequeñas modificaciones para permitir el trabajo con vectores
      que contengan elementos separados entre sí por varias posiciones.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note Esta función no detecta el caso de que el punto de trabajo esté en el
      borde o en un vértice del polígono. En este caso, el test puede dar el
      punto dentro o fuera, indistintamente (el chequeo del mismo punto con el
      mismo polígono siempre dará el mismo resultado).
\note La estructura de los vectores de coordenadas puede contener uno o varios
      polígonos, de la siguiente manera:
      -# Los vectores de vértices pasados puedes contener elementos aislados
         (varios polígonos) y/o agujeros en los elementos. En los vectores de
         entrada se han de separar los polígonos y los agujeros mediante un
         vértice de coordenadas NaN=(#GEOC_NAN, #GEOC_NAN), de la siguiente
         forma:
         -# Primero, se incluye un vértice NaN.
         -# A continuación, se incluyen las coordenadas de los vértices del
            primer elemento, repitiendo el primer vértice después del último.
         -# Se incluye otro vértice NaN.
         -# Se incluye otro elemento, repitiendo el primer vértice después del
            último.
         -# Se repiten los dos pasos anteriores por cada elemento o agujero.
         -# Se incluye un vértice NaN al final.
      -# Por ejemplo, dados tres elementos aislados de vértices A1, A2, A3, B1,
         B2, B3 y C1, C2, C3, y dos agujeros de vértices H1, H2, H3 e I1, I2,
         I3, los vértices serán listados en los vectores de coordenadas como:
         - NaN,A1,A2,A2,A1,NaN,B1,B2,B3,B1,NaN,C1,C2,C3,C1,NaN,H1,H2,H3,H1,NaN,
           I1,I2,I3,I1,NaN.
      -# Los vértices de cada elemento y/o agujero pueden ser listados en
         sentido dextrógiro o levógiro.
      -# Si el polígono es único y no tiene agujeros es opcional repetir el
         primer vértice después del último e iniciar y terminar el listado de
         coordenadas con el vértice NaN. Pero si se inicia y termina el listado
         con vértices NaN, ha de repetirse el primer vértice del polígono.
\date 05 de abril de 2010: Creación de la función.
\date 10 de abril de 2011: Adición de los argumentos de entrada \em incX e
      \em incY.
\date 12 de abril de 2011: Las variables de salida son ahora constantes
      simbólicas.
\todo Esta función no está probada.
*/
int PtoEnPoligono(const double x,
                  const double y,
                  const double* coorX,
                  const double* coorY,
                  const size_t N,
                  const size_t incX,
                  const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido o es un vértice de un polígono de un
       número arbitrario de lados. Esta función puede no dar resultados
       correctos para puntos en los bordes del polígono.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices del
           polígono. Sólo puede contener un polígono.
\param[in] coorY Vector que contiene las coordenadas Y de los vértices del
           polígono. Sólo puede contener un polígono.
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice del polígono.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note Esta función utiliza en uno de sus pasos la función \ref PtoEnPoligono y
      se comporta igual que ella en el caso de puntos en el borde.
\note La estructura de los vectores de coordenadas es idéntica a la de la
      función \ref PtoEnPoligono.
\date 09 de abril de 2010: Creación de la función.
\date 10 de abril de 2011: Adición de los argumentos de entrada \em incX e
      \em incY.
\date 12 de abril de 2011: Las variables de salida son ahora constantes
      simbólicas.
\todo Esta función no está probada.
*/
int PtoEnPoligonoVertice(const double x,
                         const double y,
                         const double* coorX,
                         const double* coorY,
                         const size_t N,
                         const size_t incX,
                         const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en un polígono de un número
       arbitrario de lados. Esta función trata correctamente los puntos situados
       en los bordes y/o los vértices del polígono, pero sólo trabaja con datos
       de tipo entero.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices del
           polígono. Sólo puede contener un polígono.
\param[in] coorY Vector que contiene las coordenadas Y de los vértices del
           polígono. Sólo puede contener un polígono.
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\return Varias posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice del polígono.
        - #GEOC_PTO_BORDE_POLIG: El punto pertenece a la frontera del polígono,
          pero no es un vértice.
\note El código de esta función ha sido tomado del texto Joseph O'Rourke (2001),
      Computational geometry in C, 2a edición, Cambridge University Press,
      página 244.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note El polígono ha de ser único, sin huecos. Es opcional repetir las
      coordenadas del primer punto al final del listado.
\note Los vértices del polígono pueden listarse en sentido dextrógiro o
      levógiro.
\note <b>Esta función puede dar resultados incorrectos para puntos muy alejados
      de los polígonos de trabajo. Para intentar mitigar este efecto, puede
      seleccionarse mediante una variable del preprocesador la precisión de
      algunas variables intermedias. Para más información se recomienda leer el
      encabezado de este fichero.</b>
\note Con cálculos internos de 32 bits las coordenadas de los vértices del
      polígono no han de estar más lejos de las de los puntos de trabajo de unas
      40000 unidades. Con cálculos de 64 bits, los polígonos pueden estar
      alejados de los puntos de trabajo unas 3000000000 unidades, lo que
      corresponde a coordenadas Y UTM ajustadas al centímetro. Con esto
      podríamos chequear un punto en un polo con respecto a un polígono en el
      ecuador en coordenadas UTM expresadas en centímetros.
\date 06 de abril de 2010: Creación de la función.
\date 10 de abril de 2011: Adición de los argumentos de entrada \em incX e
      \em incY.
\date 12 de abril de 2011: Las variables de salida son ahora constantes
      simbólicas.
\date 18 de abril de 2011: Reescritura de la función, siguiendo la página 244
      del libro de O'Rourke. La versión anterior la había adaptado del código de
      la web de O'Rourke, y lo había hecho mal.
\todo Esta función no está probada.
*/
int PtoEnPoligonoVerticeBorde(const long x,
                              const long y,
                              const long* coorX,
                              const long* coorY,
                              const size_t N,
                              const size_t incX,
                              const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en un polígono de un número
       arbitrario de lados. Esta función trata correctamente los puntos situados
       en los bordes y/o los vértices del polígono. Trabaja con datos de tipo
       real, que convierte a enteros (por redondeo o truncamiento) intermamente,
       mediante la aplicación de un factor de escala.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices del
           polígono. Sólo puede contener un polígono.
\param[in] coorY Vector que contiene las coordenadas Y de los vértices del
           polígono. Sólo puede contener un polígono.
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\param[in] factor Factor de multiplicación para aplicar a las coordenadas del
           punto de trabajo y de los vértices del polígono, con el fin de
           aumentar su resolución antes de convertirlas en valores de tipo
           entero (\p long \p int). El uso de factores muy grandes puede
           provocar resultados erróneos. Ver la nota al final de la
           documentación de esta función.
\param[in] redondeo Identificador de redondeo o truncamiento en la conversión
           interna de variables de tipo \p double en variables de tipo
           \p long \p int. Dos posibilidades:
           - 0: La conversión se hace por truncamiento.
           - Distinto de 0: La conversión se hace por redondeo.
\return Varias posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice del polígono.
        - #GEOC_PTO_BORDE_POLIG: El punto pertenece a la frontera del polígono,
          pero no es un vértice.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note El polígono ha de ser único, sin huecos. Es opcional repetir las
      coordenadas del primer punto al final del listado.
\note Los vértices del polígono pueden listarse en sentido dextrógiro o
      levógiro.
\note El código de esta función es el mismo que el de la función
      \ref PtoEnPoligonoVerticeBorde, salvo que convierte internamente varias
      variables intermedias de tipo \p double a tipo \p long \p int, que es el
      tipo de datos necesario para detectar correctamente si un punto pertenece
      al borde de un polígono.
\note Las variables se redondean internamente con la orden
      <tt>(long)(round(factor*variable))</tt>, y se truncan con la orden
      <tt>(long)(factor*variable)</tt>.
\note <b>Esta función puede dar resultados incorrectos para puntos muy alejados
      de los polígonos de trabajo. Para intentar mitigar este efecto, puede
      seleccionarse mediante una variable del preprocesador la precisión de
      algunas variables intermedias. Para más información se recomienda leer el
      encabezado de este fichero.</b>
\note Con cálculos internos de 32 bits las coordenadas de los vértices del
      polígono no han de estar más lejos de las de los puntos de trabajo de unas
      40000 unidades. Con cálculos de 64 bits, los polígonos pueden estar
      alejados de los puntos de trabajo unas 3000000000 unidades, lo que
      corresponde a coordenadas Y UTM ajustadas al centímetro. Con esto
      podríamos chequear un punto en un polo con respecto a un polígono en el
      ecuador en coordenadas UTM expresadas en centímetros. En este caso nos
      referimos a las coordenadas una vez aplicado el factor de escala
      \em factor.
\date 10 de abril de 2011: Creación de la función.
\date 11 de abril de 2011: Adición del argumento de entrada \em redondeo.
\date 12 de abril de 2011: Las variables de salida son ahora constantes
      simbólicas.
\date 18 de abril de 2011: Reescritura de la función, siguiendo la página 244
      del libro de O'Rourke. La versión anterior la había adaptado del código de
      la web de O'Rourke, y lo había hecho mal.
\todo Esta función no está probada.
*/
int PtoEnPoligonoVerticeBordeDouble(const double x,
                                    const double y,
                                    const double* coorX,
                                    const double* coorY,
                                    const size_t N,
                                    const size_t incX,
                                    const size_t incY,
                                    const double factor,
                                    const int redondeo);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca valores #GEOC_NAN es uno o dos vectores de datos. Esta función
       está pensada para el chequeo en paralelo de la inclusión de puntos en
       polígonos.
\param[in] x Vector que contiene las coordenadas X de los vértices de una serie
           de polígonos, tal y como entraría en la definición de múltiples
           elementos (pero sin huecos) para la función \ref PtoEnPoligono. La
           marca de separación entre polígonos ha de ser #GEOC_NAN.
\param[in] y Vector que contiene las coordenadas Y de los vértices de una serie
           de polígonos, tal y como entraría en la definición de múltiples
           elementos (pero sin huecos) para la función \ref PtoEnPoligono. La
           marca de separación entre polígonos ha de ser #GEOC_NAN. Este
           argumento puede valer NULL, en cuyo caso sólo se trabajará con el
           vector \em x.
\param[in] N Número de elementos que contienen los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\param[out] nNan Número de valores #GEOC_NAN encontrados, que es el número de
            elementos del vector de salida.
\return Varias posibilidades:
        - Si todo ha ido bien, vector que contiene las posiciones en el vector o
          vectores originales donde se almacena el valor #GEOC_NAN. Si se
          trabaja con los vectores \em x e \em y, la posición sólo se extrae si
          ambos vectores contienen #GEOC_NAN para una misma posición.
        - NULL: Pueden haber ocurrido dos cosas:
          - Si \em nNan vale 0, en los datos de entrada no hay ningún valor
            #GEOC_NAN.
          - Si \em nNan es mayor que 0, ha ocurrido un error interno de
            asignación de memoria.
\note Esta función no comprueba si el número de elementos de los vectores \em x
      e \em y es congruente con los valores pasados en \em N, \em incX e
      \em incY.
\note Las posiciones de los elementos #GEOC_NAN encontradas se refieren al
      número de elementos \em N de los vectores de trabajo. Para encontrar la
      posición real en memoria es necesario tener en cuenta las variables
      \em incX e \em incY.
\date 13 de abril de 2011: Creación de la función.
\todo Esta función no está probada.
*/
size_t* BuscaGeocNanEnVectores(const double* x,
                               const double* y,
                               const size_t N,
                               const size_t incX,
                               const size_t incY,
                               size_t* nNan);
/******************************************************************************/
/******************************************************************************/
/**
\brief Extrae los parámetros de inicio y número de elementos de un polígono en
       una lista de polígonos separados por un indicador. Esta función está
       pensada para el chequeo en paralelo de la inclusión de puntos en
       polígonos.
\param[in] posInd Vector que contiene las posiciones de los indicadores en el
           vector original. Este argumento es el vector que devuelve la función
           \ref BuscaGeocNanEnVectores.
\param[in] indPosInd Índice en el vector de posiciones de indicadores del
           indicador que da comienzo al polígono de trabajo.
\param[in] incX Posiciones de separación entre los elementos del vector original
           que almacena las coordenadas X del listado de polígonos. Este
           argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector original
           que almacena las coordenadas Y del listado de polígonos. Este
           argumento siempre ha de ser un número positivo.
\param[out] iniX Posición de inicio de la coordenada X del polígono de trabajo
            en el vector original que almacena las coordenadas X del listado de
            polígonos. Para encontrar la posición real en memoria es necesario
            tener en cuenta la variable \em incX.
\param[out] iniY Posición de inicio de la coordenada Y del polígono de trabajo
            en el vector original que almacena las coordenadas Y del listado de
            polígonos. Para encontrar la posición real en memoria es necesario
            tener en cuenta la variable \em incY.
\param[out] nElem Número de elementos que conforman el polígono de trabajo.
\note Esta función no comprueba si el vector \em posInd contiene datos.
\note Esta función asume que el vector \em posInd contiene un número \b *PAR* de
      datos.
\note Esta función asume que el argumento \em indPosInd no es la última posición
      del vector \em posInd.
\date 13 de abril de 2011: Creación de la función.
\todo Esta función no está probada.
*/
void DatosPoliIndividualEnVecInd(const size_t* posInd,
                                 const size_t indPosInd,
                                 const size_t incX,
                                 const size_t incY,
                                 size_t* iniX,
                                 size_t* iniY,
                                 size_t* nElem);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en una serie de polígonos
       individuales de un número arbitrario de lados. Esta función puede no dar
       resultados correctos para puntos en los bordes y/o los vértices del
       polígono.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] coorY Vector que contiene las coordenadas Y de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\param[in] posNan Vector que almacena las posiciones en los vectores \em coorX y
           \em coorY de los elementos #GEOC_NAN, que separan los polígonos
           individuales. Este vector es la salida de la función
           \ref BuscaGeocNanEnVectores.
\param[in] nNan Número de elementos del vector \em posNan.
\param[out] poli Número del polígono en que está incluido el punto de trabajo.
            Si hay varios polígonos que contienen al punto de trabajo no se
            puede asegurar cuál de ellos será el indicado en este argumento.
            Este argumento sólo tiene sentido si el valor retornado por la
            función es distinto de #GEOC_PTO_FUERA_POLIG.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera de todos los polígonos
          listados.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro de, al menos, un polígono
          de entre los listados.
\note Esta función se puede ejecutar en paralelo con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note Esta función no comprueba si el número de elementos del vector \em posNan
      es congruente con el valor pasado en \em nNan.
\note Esta función no detecta el caso de que el punto de trabajo esté en el
      borde o en un vértice del polígono. En este caso, el test puede dar el
      punto dentro o fuera, indistintamente (el chequeo del mismo punto con el
      mismo polígono siempre dará el mismo resultado).
\note La estructura de los vectores de coordenadas es la misma que la de la
      función \ref PtoEnPoligono. Las marcas de comienzo y final de los
      listados, así como las de separación entre polígonos han de ser valores
      #GEOC_NAN.
\note Aunque los vectores \em coorX y \em coorY sólo contengan un polígono, los
      elementos primero y último han de ser #GEOC_NAN.
\note Los huecos en los polígonos no serán tenidos en cuenta, serán tratados
      como polígonos individuales.
\date 14 de abril de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PtoEnPoligonoInd(const double x,
                     const double y,
                     const double* coorX,
                     const double* coorY,
                     const size_t N,
                     const size_t incX,
                     const size_t incY,
                     const size_t* posNan,
                     const size_t nNan,
                     size_t* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en una serie de polígonos
       individuales de un número arbitrario de lados. Esta función puede no dar
       resultados correctos para puntos en los bordes del polígono.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] coorY Vector que contiene las coordenadas Y de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\param[in] posNan Vector que almacena las posiciones en los vectores \em coorX y
           \em coorY de los elementos #GEOC_NAN, que separan los polígonos
           individuales. Este vector es la salida de la función
           \ref BuscaGeocNanEnVectores.
\param[in] nNan Número de elementos del vector \em posNan.
\param[out] poli Número del polígono en que está incluido el punto de trabajo.
            Si hay varios polígonos que contienen al punto de trabajo no se
            puede asegurar cuál de ellos será el indicado en este argumento.
            Este argumento sólo tiene sentido si el valor retornado por la
            función es distinto de #GEOC_PTO_FUERA_POLIG.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera de todos los polígonos
          listados.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro de, al menos, un polígono
          de entre los listados.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice de, al menos, un
          polígono de entre los listados.
\note Esta función se puede ejecutar en paralelo con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note Esta función no comprueba si el número de elementos del vector \em posNan
      es congruente con el valor pasado en \em nNan.
\note Esta función no detecta el caso de que el punto de trabajo esté en el
      borde del polígono. En este caso, el test puede dar el punto dentro o
      fuera, indistintamente (el chequeo del mismo punto con el mismo polígono
      siempre dará el mismo resultado).
\note La estructura de los vectores de coordenadas es la misma que la de la
      función \ref PtoEnPoligono. Las marcas de comienzo y final de los
      listados, así como las de separación entre polígonos han de ser valores
      #GEOC_NAN.
\note Aunque los vectores \em coorX y \em coorY sólo contengan un polígono, los
      elementos primero y último han de ser #GEOC_NAN.
\note Los huecos en los polígonos no serán tenidos en cuenta, serán tratados
      como polígonos individuales.
\date 14 de abril de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PtoEnPoligonoVerticeInd(const double x,
                            const double y,
                            const double* coorX,
                            const double* coorY,
                            const size_t N,
                            const size_t incX,
                            const size_t incY,
                            const size_t* posNan,
                            const size_t nNan,
                            size_t* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en una serie de polígonos
       individuales de un número arbitrario de lados. Esta función trata
       correctamente los puntos situados en los bordes y/o los vértices del
       polígono, pero sólo trabaja con datos de tipo entero.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] coorY Vector que contiene las coordenadas Y de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\param[in] posNan Vector que almacena las posiciones en los vectores \em coorX y
           \em coorY de los elementos #GEOC_NAN, que separan los polígonos
           individuales. Este vector es la salida de la función
           \ref BuscaGeocNanEnVectores.
\param[in] nNan Número de elementos del vector \em posNan.
\param[out] poli Número del polígono en que está incluido el punto de trabajo.
            Si hay varios polígonos que contienen al punto de trabajo no se
            puede asegurar cuál de ellos será el indicado en este argumento.
            Este argumento sólo tiene sentido si el valor retornado por la
            función es distinto de #GEOC_PTO_FUERA_POLIG.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera de todos los polígonos
          listados.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro de, al menos, un polígono
          de entre los listados.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice de, al menos, un
          polígono de entre los listados.
        - #GEOC_PTO_BORDE_POLIG: El punto pertenece a la frontera de, al menos,
          un polígono de entre los listados, pero no es un vértice.
\note Esta función se puede ejecutar en paralelo con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note Esta función no comprueba si el número de elementos del vector \em posNan
      es congruente con el valor pasado en \em nNan.
\note La estructura de los vectores de coordenadas es la misma que la de la
      función \ref PtoEnPoligono. Las marcas de comienzo y final de los
      listados, así como las de separación entre polígonos han de ser valores
      #GEOC_NAN.
\note Aunque los vectores \em coorX y \em coorY sólo contengan un polígono, los
      elementos primero y último han de ser #GEOC_NAN.
\note Los huecos en los polígonos no serán tenidos en cuenta, serán tratados
      como polígonos individuales.
\note <b>Esta función puede dar resultados incorrectos para puntos muy alejados
      de los polígonos de trabajo. Para intentar mitigar este efecto, puede
      seleccionarse mediante una variable del preprocesador la precisión de
      algunas variables intermedias. Para más información se recomienda leer el
      encabezado de este fichero.</b>
\note Con cálculos internos de 32 bits las coordenadas de los vértices del
      polígono no han de estar más lejos de las de los puntos de trabajo de unas
      40000 unidades. Con cálculos de 64 bits, los polígonos pueden estar
      alejados de los puntos de trabajo unas 3000000000 unidades, lo que
      corresponde a coordenadas Y UTM ajustadas al centímetro. Con esto
      podríamos chequear un punto en un polo con respecto a un polígono en el
      ecuador en coordenadas UTM expresadas en centímetros.
\date 14 de abril de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PtoEnPoligonoVerticeBordeInd(const long x,
                                 const long y,
                                 const long* coorX,
                                 const long* coorY,
                                 const size_t N,
                                 const size_t incX,
                                 const size_t incY,
                                 const size_t* posNan,
                                 const size_t nNan,
                                 size_t* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en una serie de polígonos
       individuales de un número arbitrario de lados. Esta función trata
       correctamente los puntos situados en los bordes y/o los vértices del
       polígono. Trabaja con datos de tipo real, que convierte a enteros (por
       redondeo o truncamiento) intermamente, mediante a aplicación de un factor
       de escala.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] coorX Vector que contiene las coordenadas X de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] coorY Vector que contiene las coordenadas Y de los vértices de los
           elementos. Puede contener varios polígonos, pero no huecos (si los
           hay, serán tratados como otros polígonos).
\param[in] N Número de elementos que contienen los vectores \em coorX y
           \em coorY.
\param[in] incX Posiciones de separación entre los elementos del vector
           \em coorX. Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector
           \em coorY. Este argumento siempre ha de ser un número positivo.
\param[in] factor Factor de multiplicación para aplicar a las coordenadas del
           punto de trabajo y de los vértices de los polígonos, con el fin de
           aumentar su resolución antes de convertirlas en valores de tipo
           entero (\p long \p int). El uso de factores muy grandes puede
           provocar resultados erróneos. Ver la nota al final de la
           documentación de esta función.
\param[in] redondeo Identificador de redondeo o truncamiento en la conversión
           interna de variables de tipo \p double en variables de tipo
           \p long \p int. Dos posibilidades:
           - 0: La conversión se hace por truncamiento.
           - Distinto de 0: La conversión se hace por redondeo.
\param[in] posNan Vector que almacena las posiciones en los vectores \em coorX y
           \em coorY de los elementos #GEOC_NAN, que separan los polígonos
           individuales. Este vector es la salida de la función
           \ref BuscaGeocNanEnVectores.
\param[in] nNan Número de elementos del vector \em posNan.
\param[out] poli Número del polígono en que está incluido el punto de trabajo.
            Si hay varios polígonos que contienen al punto de trabajo no se
            puede asegurar cuál de ellos será el indicado en este argumento.
            Este argumento sólo tiene sentido si el valor retornado por la
            función es distinto de #GEOC_PTO_FUERA_POLIG.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera de todos los polígonos
          listados.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro de, al menos, un polígono
          de entre los listados.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice de, al menos, un
          polígono de entre los listados.
        - #GEOC_PTO_BORDE_POLIG: El punto pertenece a la frontera de, al menos,
          un polígono de entre los listados, pero no es un vértice.
\note Esta función se puede ejecutar en paralelo con OpenMP.
\note Esta función no comprueba si el número de elementos de los vectores
      \em coorX y \em coorY es congruente con los valores pasados en \em N,
      \em incX e \em incY. Tampoco comprueba si \em N es un valor mayor o igual
      a 3, que es el número mínimo de vértices que ha de tener un polígono.
\note Esta función no comprueba si el número de elementos del vector \em posNan
      es congruente con el valor pasado en \em nNan.
\note Las variables se redondean internamente con la orden
      <tt>(long)(round(factor*variable))</tt>, y se truncan con la orden
      <tt>(long)(factor*variable)</tt>.
\note La estructura de los vectores de coordenadas es la misma que la de la
      función \ref PtoEnPoligono. Las marcas de comienzo y final de los
      listados, así como las de separación entre polígonos han de ser valores
      #GEOC_NAN.
\note Aunque los vectores \em coorX y \em coorY sólo contengan un polígono, los
      elementos primero y último han de ser #GEOC_NAN.
\note Los huecos en los polígonos no serán tenidos en cuenta, serán tratados
      como polígonos individuales.
\note <b>Esta función puede dar resultados incorrectos para puntos muy alejados
      de los polígonos de trabajo. Para intentar mitigar este efecto, puede
      seleccionarse mediante una variable del preprocesador la precisión de
      algunas variables intermedias. Para más información se recomienda leer el
      encabezado de este fichero.</b>
\note Con cálculos internos de 32 bits las coordenadas de los vértices del
      polígono no han de estar más lejos de las de los puntos de trabajo de unas
      40000 unidades. Con cálculos de 64 bits, los polígonos pueden estar
      alejados de los puntos de trabajo unas 3000000000 unidades, lo que
      corresponde a coordenadas Y UTM ajustadas al centímetro. Con esto
      podríamos chequear un punto en un polo con respecto a un polígono en el
      ecuador en coordenadas UTM expresadas en centímetros. En este caso nos
      referimos a las coordenadas una vez aplicado el factor de escala
      \em factor.
\date 14 de abril de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PtoEnPoligonoVerticeBordeDoubleInd(const double x,
                                       const double y,
                                       const double* coorX,
                                       const double* coorY,
                                       const size_t N,
                                       const size_t incX,
                                       const size_t incY,
                                       const double factor,
                                       const int redondeo,
                                       const size_t* posNan,
                                       const size_t nNan,
                                       size_t* poli);
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

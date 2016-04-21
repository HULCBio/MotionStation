/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file greiner.h
\brief Definición de estructuras y declaración de funciones para el recorte de
       polígonos mediante el algoritmo de Greiner-Hormann
       (http://davis.wpi.edu/~matt/courses/clipping/).
\author José Luis García Pallero, jgpallero@gmail.com
\date 14 de mayo de 2011
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
#ifndef _GREINER_H_
#define _GREINER_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include<math.h>
#include<float.h>
#include<time.h>
#include"libgeoc/errores.h"
#include"libgeoc/eucli.h"
#include"libgeoc/geocnan.h"
#include"libgeoc/polig.h"
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
\def GEOC_GREINER_FAC_EPS_PERTURB
\brief Factor de escala para el cálculo de la cantidad mínima de perturbación
       para un valor. Esta variable se usa en la función \ref CantPerturbMin.

       A base de hacer pruebas he visto que es desaconsejable un valor por
       debajo de 10.0.
\date 22 de mayo de 2011: Creación de la constante.
*/
#define GEOC_GREINER_FAC_EPS_PERTURB 10.0
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_GREINER_BUFFER_PTOS
\brief Número de puntos para ir asignando memoria en bloques para los polígonos
       de salida en la funcion \ref Paso3Greiner. Ha de ser un número mayor o
       igual a 2.
\date 23 de mayo de 2011: Creación de la constante.
*/
#define GEOC_GREINER_BUFFER_PTOS 100
/******************************************************************************/
/******************************************************************************/
/** \enum GEOC_OP_BOOL_POLIG
\brief Operación booleana entre polígonos.
\date 21 de mayo de 2011: Creación del tipo.
*/
enum GEOC_OP_BOOL_POLIG
{
    /** \brief Intersección entre polígonos. */
    GeocOpBoolInter=111,
    /** \brief Unión de polígonos. */
    GeocOpBoolUnion=112,
    /** \brief Unión exclusiva de polígonos. */
    GeocOpBoolXor=113,
    /** \brief Operación A-B. */
    GeocOpBoolAB=114,
    /** \brief Operación B-A. */
    GeocOpBoolBA=115
};
/******************************************************************************/
/******************************************************************************/
/** \struct _vertPoliClip
\brief Estructura de definición de un vértice de un polígono usado en
       operaciones de recorte. El polígono se almacena en memoria como una lista
       doblemente enlazada de vértices.
\date 14 de mayo de 2011: Creación de la estructura.
*/
typedef struct _vertPoliClip
{
    /** \brief Coordenada X del vértice. */
    double x;
    /** \brief Coordenada Y del vértice. */
    double y;
    /** \brief Coordenada X perturbada del vértice. */
    double xP;
    /** \brief Coordenada Y perturbada del vértice. */
    double yP;
    /** \brief Vértice anterior. */
    struct _vertPoliClip* anterior;
    /** \brief Vértice siguiente. */
    struct _vertPoliClip* siguiente;
    /**
    \brief Enlace al mismo nodo, perteneciente a otro polígono.

           Los puntos de intersección pertenecen tanto al polígono de recorte
           como al recortado.
    */
    struct _vertPoliClip* vecino;
    /**
    \brief Indicador de primer punto de polígono.

           Dos posibilidades:
           - 0: No es el primer punto del polígono.
           - Distinto de 0: Sí es el primer punto del polígono.
    */
    char ini;
    /**
    \brief Indicador de punto de intersección.

           Dos posibilidades:
           - 0: No es un punto de intersección.
           - Distinto de 0: Sí es un punto de intersección.
    */
    char interseccion;
    /**
    \brief Indicador de punto de entrada al interior del otro polígono.

           Dos posibilidades:
           - 0: No es un punto de entrada, es de salida.
           - Distinto de 0: Sí es un punto de entrada.
    */
    char entrada;
    /**
    \brief Indicador de punto visitado.

           Dos posibilidades:
           - 0: No ha sido visitado.
           - Distinto de 0: Sí ha sido visitado.
    */
    char visitado;
    /** \brief Distancia, en tanto por uno, de un nodo de intersección con
               respecto al primer vértice del segmento que lo contiene. */
    double alfa;
}vertPoliClip;
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea un vértice de tipo \ref _vertPoliClip y lo inserta entre otros dos.
\param[in] x Coordenada X del vértice.
\param[in] y Coordenada Y del vértice.
\param[in] anterior Vértice anterior (puede ser \p NULL).
\param[in] siguiente Vértice siguiente (puede ser \p NULL).
\param[in] vecino Campo _vertPoliClip::vecino (puede ser \p NULL).
\param[in] ini Campo _vertPoliClip::ini.
\param[in] interseccion Campo _vertPoliClip::interseccion.
\param[in] entrada Campo _vertPoliClip::entrada.
\param[in] visitado Campo _vertPoliClip::visitado.
\param[in] alfa Campo _vertPoliClip::alfa.
\return Puntero al nuevo vértice creado. Si se devuelve \p NULL, ha ocurrido un
        error de asignación de memoria.
\date 18 de mayo de 2011: Creación de la función.
\date 21 de mayo de 2011: Eliminación del algumento \em siguientePoli y adición
      del argumento \em ini.
\todo Esta función todavía no está probada.
*/
vertPoliClip* CreaVertPoliClip(const double x,
                               const double y,
                               vertPoliClip* anterior,
                               vertPoliClip* siguiente,
                               vertPoliClip* vecino,
                               const char ini,
                               const char interseccion,
                               const char entrada,
                               const char visitado,
                               const double alfa);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea un polígono, como una lista doblemente enlazada de elementos
       \ref _vertPoliClip.
\param[in] x Vector de coordenadas X de los nodos del polígono.
\param[in] y Vector de coordenadas Y de los nodos del polígono.
\param[in] nCoor Número de elementos de los vectores \em x e \em y.
\param[in] incX Posiciones de separación entre los elementos del vector \em x.
           Este argumento siempre ha de ser un número positivo.
\param[in] incY Posiciones de separación entre los elementos del vector \em y.
           Este argumento siempre ha de ser un número positivo.
\return Puntero al primer vértice de la lista. Si se devuelve \p NULL, ha
        ocurrido un error de asignación de memoria.
\note Esta función asume que el argumento \em nCoor es mayor que 0.
\note En la lista de salida que representa al polígono, el primer vértice
      siempre se repite al final. Si en los vectores \em x e \em y el último
      elemento no es igual que el primero, igualmente se crea en la lista de
      salida.
\note Si en los vectores de coordenadas \em x e \em y hay valores #GEOC_NAN,
      éstos no se tienen en cuenta a la hora de la creación de la estructura de
      salida.
\note Que los vectores de coordenadas \em x e \em y admitan vértices con
      coordenadas (#GEOC_NAN,#GEOC_NAN) no quiere decir que éstos sean
      separadores de múltiples polígonos. \em x e \em y \b *SÓLO* deben
      almacenar un único polígono.
\date 18 de mayo de 2011: Creación de la función.
\date 24 de mayo de 2011: Adición del soporte de coordenadas
      (#GEOC_NAN,#GEOC_NAN) en los vectores de entrada.
\todo Esta función todavía no está probada.
*/
vertPoliClip* CreaPoliClip(const double* x,
                           const double* y,
                           const size_t nCoor,
                           const size_t incX,
                           const size_t incY);
/******************************************************************************/
/******************************************************************************/
/**
\brief Libera la memoria asignada a un polígono almacenado como una lista
       doblemente enlazada de elementos \ref _vertPoliClip.
\param[in] poli Puntero al primer elemento del polígono.
\note Esta función no comprueba si hay vértices del polígono anteriores al
      vértice de entrada, por lo que si se quiere liberar toda la memoria
      asignada a un polígono, el vértice pasado ha de ser el primero de la
      lista.
\note Esta función \b *NO* trabaja con listas circulares.
\date 18 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void LibMemPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Elimina los vértices no originales de un polígono almacenado como una
       lista doblemente enlazada de elementos \ref _vertPoliClip.
\param[in] poli Puntero al primer elemento del polígono.
\return Puntero al primer elemento del polígono original. Si se devuelve
        \p NULL, ninguno de los vértices pertenecía al polígono original.
\note Esta función asume que el primero y el último vértices originales del
      polígono pasado tienen las mismas coordenadas.
\note Los vértices eliminados por esta función son todos aquéllos cuyo campo
      _vertPoliClip::interseccion sea distinto de 0.
\note Aunque se supone que el primer vértice de un polígono siempre es un
      vértice original, si no lo es, la variable de entrada queda modificada.
      Por tanto, siempre es recomendable capturar la variable de salida, que
      garantiza la posición del primer elemento.
\note Las coordenadas de todos los vértices originales vuelven a ser la de
      inicio, es decir, los campos _vertPoliClip::xP e _vertPoliClip::yP se
      sobreescriben con los valores almacenados en _vertPoliClip::x e
      _vertPoliClip::y.
\note Esta función \b *NO* trabaja con listas circulares.
\date 18 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPoliClip* ReiniciaPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Reinicia los vértices de un polígono almacenado como una lista doblemente
       enlazada de elementos \ref _vertPoliClip para poder volver a calcular
       otra operación booleana sin tener que recalcular las intersecciones.

       Esta función devuelve todos los campos _vertPoliClip::visitado a 0 y los
       campos _vertPoliClip::entrada a 0.
\param[in] poli Puntero al primer elemento del polígono.
\return Puntero al primer elemento del polígono original. Si se devuelve
        \p NULL, quiere decir qie el argumento de entrada valía \p NULL.
\note Esta función \b *NO* trabaja con listas circulares.
\date 30 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPoliClip* ReiniciaVerticesPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el siguiente vértice original en un polígono.
\param[in] vert Puntero al vértice a partir del cual se ha de buscar.
\return Puntero al siguiente vértice original en el polígono. Si se devuelve
        \p NULL, se ha llegado al final.
\note Esta función asume que el primero y el último vértices originales del
      polígono pasado tienen las mismas coordenadas.
\note Los vértices no originales son todos aquéllos cuyo campo
      _vertPoliClip::interseccion es distinto de 0.
\note Esta función \b *NO* trabaja con listas circulares.
\date 19 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPoliClip* SiguienteVertOrigPoliClip(vertPoliClip* vert);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el siguiente vértice que sea una intersección no visitada en un
       polígono.
\param[in] vert Puntero al vértice a partir del cual se ha de buscar.
\return Puntero al siguiente vértice que sea una intersección no visitada en el
        polígono. Si se devuelve \p NULL, se ha llegado al final.
\note Esta función asume que el primero y el último vértices originales del
      polígono pasado tienen las mismas coordenadas.
\note Los vértices intersección no visitados son todos aquéllos cuyo campo
      _vertPoliClip::visitado es 0.
\note Esta función asume que el vértice inicial del polígono, aquél cuyo campo
      _vertPoliClip::ini vale 1, es un vértice original.
\note Esta función puede trabajar con listas circulares y no circulares.
\date 21 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPoliClip* SiguienteIntersecNoVisitadaPoliClip(vertPoliClip* vert);
/******************************************************************************/
/******************************************************************************/
/**
\brief Busca el último vértice de un polígono almacenado como una lista
       doblemente enlazada de vértives \ref _vertPoliClip.
\param[in] poli Puntero al primer elemento del polígono.
\return Puntero al último vértice del polígono, que es aquél cuyo campo
        _vertPoliClip::siguiente apunta a \p NULL. Si se devuelve \p NULL,
        significa que el argumento pasado en \em poli vale \p NULL.
\note Esta función \b *NO* trabaja con listas circulares.
\date 21 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPoliClip* UltimoVertPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Inserta un vértice de tipo \ref _vertPoliClip entre otros dos, atendiendo
       al campo _vertPoliClip::alfa.
\param[in] ins Vértice a insertar.
\param[in] extremoIni Extremo inicial del segmento donde se insertará \em ins.
\param[in] extremoFin Extremo final del segmento donde se insertará \em ins.
\note Esta función asume que todos los elementos pasados tienen memoria
      asignada.
\note Si entre \em extremoIni y \em extremoFin hay más vértices, \em ins se
      insertará de tal modo que los campos _vertPoliClip::alfa queden ordenados
      de menor a mayor.
\note Si el campo _vertPoliClip::alfa de \em ins tiene el mismo valor que el
      de \em extremoIni, \em ins se insertará justo a continuación de
      \em extremoIni.
\note Si el campo _vertPoliClip::alfa de \em ins tiene el mismo valor que el
      de \em extremoFin, \em ins se insertará justo antes de \em extremoIni.
\note Esta función \b *NO* trabaja con listas circulares.
\date 19 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void InsertaVertPoliClip(vertPoliClip* ins,
                         vertPoliClip* extremoIni,
                         vertPoliClip* extremoFin);
/******************************************************************************/
/******************************************************************************/
/**
\brief Convierte una lista doblemente enlazada de elementos \ref _vertPoliClip
       en una lista doblemente enlazada circular.
\param[in,out] poli Vértice inicial del polígono, almacenado como lista
               doblemente enlazada, pero no cerrada. Al término de la ejecución
               de la función la lista se ha cerrado, por medio de un enlace del
               penúltimo elemento (el último es el primero repetido) con el
               primero.
\return Puntero al último elemento del polígono original que, al ser el primer
        elemento repetido, queda almacenado en memoria pero no neferenciado por
        el polígono. Si el valor devuelto es \p NULL quiere decir que el
        argumento de entrada era \p NULL.
\note Esta función \b *NO* trabaja con listas circulares.
\date 21 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
vertPoliClip* CierraPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Convierte una lista doblemente enlazada circular de elementos
       \ref _vertPoliClip en una lista doblemente enlazada simple.
\param[in,out] poli Vértice inicial del polígono, almacenado como lista
               doblemente enlazada circular. Al término de la ejecución de la
               función la lista ha recuperado su condición de doblemente
               enlazada sin cerrar.
\param[in] ultimo Puntero al último elemento de la lista doblemente enlazada
           original. Este argumento ha de ser el valor devuelto por la
           función \ref CierraPoliClip.
\note Esta función asume que los elementos pasados tienen memoria asignada.
\note Esta función sólo trabaja con listas circulares.
\date 21 de mayo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
void AbrePoliClip(vertPoliClip* poli,
                  vertPoliClip* ultimo);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en un polígono de un número
       arbitrario de lados. Esta función puede no dar resultados correctos para
       puntos en los bordes y/o los vértices del polígono.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] poli Polígono, almacenado como una lista doblemente enlazada de
           elementos \ref _vertPoliClip. Sólo se tienen en cuenta los vértices
           originales del polígono, que son todos aquéllos cuyo campo
           _vertPoliClip::interseccion es distinto de 0.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
\note El código de esta función ha sido adaptado de la función
      \ref PtoEnPoligono.
\note Esta función no comprueba si la variable \em poli es un polígono
      correctamente almacenado.
\note Esta función no detecta el caso de que el punto de trabajo esté en el
      borde o en un vértice del polígono. En este caso, el test puede dar el
      punto dentro o fuera, indistintamente (el chequeo del mismo punto con el
      mismo polígono siempre dará el mismo resultado).
\note Esta función \b *NO* trabaja con listas circulares.
\date 19 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PtoEnPoliClip(const double x,
                  const double y,
                  vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si un punto está contenido en un polígono de un número
       arbitrario de lados. Esta función puede no dar resultados correctos para
       puntos en los bordes del polígono.
\param[in] x Coordenada X del punto de trabajo.
\param[in] y Coordenada Y del punto de trabajo.
\param[in] poli Polígono, almacenado como una lista doblemente enlazada de
           elementos \ref _vertPoliClip. Sólo se tienen en cuenta los vértices
           originales del polígono, que son todos aquéllos cuyo campo
           _vertPoliClip::interseccion es distinto de 0.
\return Dos posibilidades:
        - #GEOC_PTO_FUERA_POLIG: El punto está fuera del polígono.
        - #GEOC_PTO_DENTRO_POLIG: El punto está dentro del polígono.
        - #GEOC_PTO_VERTICE_POLIG: El punto es un vértice del polígono.
\note El código de esta función ha sido adaptado de la función
      \ref PtoEnPoligonoVertice.
\note Esta función no comprueba si la variable \em poli es un polígono
      correctamente almacenado.
\note Esta función utiliza en uno de sus pasos la función \ref PtoEnPoliClip y
      se comporta igual que ella en el caso de puntos en el borde.
\note Esta función \b *NO* trabaja con listas circulares.
\date 19 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int PtoEnPoliClipVertice(const double x,
                         const double y,
                         vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Cuenta el número de vértices originales que hay en un polígono almacenado
       como una lista doblemente enlazada de elementos \ref _vertPoliClip.
\param[in] poli Polígono, almacenado como una lista doblemente enlazada de
           elementos \ref _vertPoliClip. Sólo se tienen en cuenta los vértices
           originales del polígono, que son todos aquéllos cuyo campo
           _vertPoliClip::interseccion es distinto de 0.
\return Número de vértices originales almacenados. El último vértice, que es
        igual al primero, también se cuenta.
\note Esta función no comprueba si la variable \em poli es un polígono
      correctamente almacenado.
\note Esta función \b *NO* trabaja con listas circulares.
\date 19 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
size_t NumeroVertOrigPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Cuenta el número total de vértices que hay en un polígono almacenado como
       una lista doblemente enlazada de elementos \ref _vertPoliClip.
\param[in] poli Polígono, almacenado como una lista doblemente enlazada de
           elementos \ref _vertPoliClip. Se tienen en cuenta todos los vértices.
\return Número total de vértices almacenados. El último vértice, que debe ser
        igual al primero, también se cuenta.
\note Esta función no comprueba si la variable \em poli es un polígono
      correctamente almacenado.
\note Esta función \b *NO* trabaja con listas circulares.
\date 19 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
size_t NumeroVertPoliClip(vertPoliClip* poli);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la cantidad mínima a añadir a un número para que el valor de la
       suma sea distinto del número original.
\param[in] x Número a perturbar.
\param[in] factor Factor para ir multiplicando el valor a añadir a \em x
           mientras no sea suficiente para producir una perturbación detectable.
           Un buen valor para este argumento es #GEOC_GREINER_FAC_EPS_PERTURB.
\return Cantidad mínima a añadir a \em x para que el valor de la suma sea
        distinto de \em x.
\note Esta función no comprueba internamente si \em factor es menor o igual que
      1, lo que daría lugar a que la función entrase en un bucle infinito.
\note Como valor inicial de la cantidad a añadir se toma el producto de
      \em factor por la constante \p DBL_EPSILON, perteneciente al fichero
      \p float.h de C estándar.
\date 22 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
double CantPerturbMin(const double x,
                      const double factor);
/******************************************************************************/
/******************************************************************************/
/**
\brief Modifica un número la cantidad mínima para que sea distinto del número
       original.
\param[in] x Número a perturbar.
\param[in] factor Factor para el cálculo de la cantidad perturbadora mínima. Ver
           la documentación de la función \ref CantPerturbMin para obtener más
           detalles. Un buen valor para este argumento es
           #GEOC_GREINER_FAC_EPS_PERTURB.
\return Número perturbado.
\note La perturbación de \em x se realiza de la siguiente manera:
      - Se calcula la cantidad mínima perturbadora \p perturb con la función
        \ref CantPerturbMin.
      - Se calcula un número seudoaleatorio con la función de C estándar
        <tt>rand()</tt> (el generador de números seudoaleatorios se inicializa
        con la orden <tt>srand((unsigned int)time(NULL));</tt>).
      - Se comprueba la paridad del número seudoaleatorio generado para obtener
        la variable \p signo, de tal forma que:
        - Si el número seudoaleatorio es par: \p signo vale 1.0.
        - Si el número seudoaleatorio es impar: \p signo vale -1.0.
      - Se perturba \em x como <tt>xPerturb=x+signo*perturb</tt>.
\date 22 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
double PerturbaPuntoMin(const double x,
                        const double factor);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza el paso número 1 del algoritmo de Greiner-Hormann, que consiste
       en el cálculo de los puntos de intersección entre los dos polígonos de
       trabajo.
\param[in,out] poliBas Polígono base, representado como una lista doblemente
               enlazada de elementos \ref _vertPoliClip. Al término de la
               ejecución de la función se le han añadido los puntos de
               intersección.
\param[in,out] poliRec Polígono de recorte, representado como una lista
               doblemente enlazada de elementos \ref _vertPoliClip. Al término
               de la ejecución de la función se le han añadido los puntos de
               intersección.
\param[in] facPer Factor para el posible cálculo de la perturbación de las
           coordenadas de algunos vértices. Este valor es usado internamente por
           la función \ref PerturbaPuntoMin (ver su documentación). Un buen
           valor para este argumento es #GEOC_GREINER_FAC_EPS_PERTURB.
\param[out] nIntersec Número de intersecciones calculadas.
\param[out] nPerturb Número de puntos perturbados en el proceso.
\return Variable de estado. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si las variables \em poliBas y \em poliRec son
      polígonos correctamente almacenados.
\note En el caso de tener que perturbar algún vértice, sólo se modifican los de
      \em poliRec, dejando las coordenadas del polígono base inalteradas.
\date 22 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int Paso1Greiner(vertPoliClip* poliBas,
                 vertPoliClip* poliRec,
                 const double facPer,
                 size_t* nIntersec,
                 size_t* nPerturb);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza el paso número 2 del algoritmo de Greiner-Hormann, que consiste
       en la asignación de los puntos de intersección como entrada o salida.
\param[in,out] poliBas Polígono base, representado como una lista doblemente
               enlazada de elementos \ref _vertPoliClip. Al término de la
               ejecución de la función los puntos de intersección han sido
               marcados como entrada o salida.
\param[in,out] poliRec Polígono de recorte, representado como una lista
               doblemente enlazada de elementos \ref _vertPoliClip. Al término
               de la ejecución de la función los puntos de intersección han sido
               marcados como entrada o salida.
\param[in] op Identificador de la operación a realizar. Ha de ser un elemento
           del tipo enumerado #GEOC_OP_BOOL_POLIG, excepto la unión exclusiva
           \p xor. En el caso de indicar la operación de unión exclusiva \p xor,
           se realiza una intersección y \b *NO* se avisa del argumento
           incorrecto.
\note Esta función no comprueba si las variables \em poliBas y \em poliRec son
      polígonos correctamente almacenados.
\date 22 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
void Paso2Greiner(vertPoliClip* poliBas,
                  vertPoliClip* poliRec,
                  const enum GEOC_OP_BOOL_POLIG op);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza el paso número 3 del algoritmo de Greiner-Hormann, que consiste
       en la generación de los polígonos resultado.
\param[in,out] poliBas Polígono base, representado como una lista doblemente
               enlazada de elementos \ref _vertPoliClip, tal y como sale de la
               función \ref Paso2Greiner. Al término de la ejecución de la
               función los puntos visitados han sido marcados en el campo
               _vertPoliClip::visitado.
\param[in,out] poliRec Polígono de recorte, representado como una lista
               doblemente enlazada de elementos \ref _vertPoliClip, tal y como
               sale de la función \ref Paso2Greiner. Al término de la ejecución
               de la función los puntos visitados han sido marcados en el campo
               _vertPoliClip::visitado.
\return Estructura \ref polig con los polígonos resultado de la operación. Si se
        devuelve \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si las variables \em poliBas y \em poliRec son
      polígonos correctamente almacenados.
\date 22 de mayo de 2011: Creación de la función.
\date 29 de mayo de 2011: Cambio de la variable de salida por la estructura
      \ref polig.
\todo Esta función no está probada.
*/
polig* Paso3Greiner(vertPoliClip* poliBas,
                    vertPoliClip* poliRec);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza una operación booleana entre dos polígonos mediante el algoritmo
       de Greiner-Hormann.
\param[in,out] poliBas Polígono base, representado como una lista doblemente
               enlazada de elementos \ref _vertPoliClip. Al término de la
               ejecución de la función se han añadido los puntos de intersección
               con \em poliRec.
\param[in,out] poliRec Polígono de recorte, representado como una lista
               doblemente enlazada de elementos \ref _vertPoliClip. Al término
               de la ejecución de la función se han añadido los puntos de
               intersección con \em poliRec.
\param[in] op Identificador de la operación a realizar. Ha de ser un elemento
           del tipo enumerado #GEOC_OP_BOOL_POLIG. Varias posibilidades:
           - #GeocOpBoolInter: Realiza la intersección entre \em poliBas y
             \em poliRec.
           - #GeocOpBoolUnion: Realiza la unión entre \em poliBas y \em poliRec.
           - #GeocOpBoolXor: Realiza la unión exclusiva entre \em poliBas y
             \em poliRec.
           - #GeocOpBoolAB: Realiza la sustracción \em poliBas-poliRec.
           - #GeocOpBoolBA: Realiza la sustracción \em poliRec-poliBas.
\param[in] facPer Factor para el posible cálculo de la perturbación de las
           coordenadas de algunos vértices. Este valor es usado internamente por
           la función \ref Paso1Greiner (ver su documentación). Un buen valor
           para este argumento es #GEOC_GREINER_FAC_EPS_PERTURB.
\param[out] nIntersec Número de intersecciones calculadas.
\param[out] nPerturb Número de puntos perturbados en el proceso.
\return Estructura \ref polig con los polígonos resultado de la operación. Si se
        devuelve \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si las variables \em poliBas y \em poliRec son
      polígonos correctamente almacenados.
\note Esta función no comprueba internamente si \em op pertenece al tipo
      enumerado #GEOC_OP_BOOL_POLIG. Si se introduce un valor no perteneciente
      al tipo, se realiza la operación #GeocOpBoolInter.
\note En el caso de tener que perturbar algún vértice, sólo se modifican los de
      \em poliRec, dejando las coordenadas de \em poliBase inalteradas.
\note Si \em facPer es menor o igual que 1, se sustituye internamente su valor
      por #GEOC_GREINER_FAC_EPS_PERTURB (ver documentación de la función
      \ref CantPerturbMin).
\note Esta función realiza la unión exclusiva #GeocOpBoolXor mediante la unión
      de las operaciones individuales #GeocOpBoolAB y #GeocOpBoolBA. Esta última
      unión simplemente es el almacenamiento en la estructura de salida de los
      resultados de #GeocOpBoolAB y #GeocOpBoolBA. En ningún momento se realiza
      la operación booleana #GeocOpBoolUnion entre los resultados de
      #GeocOpBoolAB y #GeocOpBoolBA.
\date 22 de mayo de 2011: Creación de la función.
\date 29 de mayo de 2011: Cambio de la variable de salida por la estructura
      \ref polig.
\date 30 de mayo de 2011: Adición de la capacidad de calcular la operación unión
      exclusiva \p xor.
\todo Esta función no está probada.
*/
polig* PoliBoolGreiner(vertPoliClip* poliBas,
                       vertPoliClip* poliRec,
                       const enum GEOC_OP_BOOL_POLIG op,
                       const double facPer,
                       size_t* nIntersec,
                       size_t* nPerturb);
/******************************************************************************/
/******************************************************************************/
/**
\brief Realiza una operación booleana entre múltiples polígonos mediante el
       algoritmo de Greiner-Hormann.
\param[in] poliBas Estructura \ref polig que almacena los polígonos base.
\param[in] poliRec Estructura \ref polig que almacena los polígonos de recorte.
\param[in] op Identificador de la operación a realizar. Ha de ser un elemento
           del tipo enumerado #GEOC_OP_BOOL_POLIG. Varias posibilidades:
           - #GeocOpBoolInter: Realiza la intersección entre los polígonos
             almacenados en \em poliBas y los almacenados en \em poliRec.
           - #GeocOpBoolUnion: Realiza la unión entre los polígonos almacenados
             en \em poliBas y los almacenados en \em poliRec.
           - #GeocOpBoolXor: Realiza la unión exclusiva entre los polígonoa
             almacenados en \em poliBas y los almacenados en \em poliRec.
           - #GeocOpBoolAB: Realiza la sustracción entre todos los polígonos
             \em poliBas-poliRec.
           - #GeocOpBoolBA: Realiza la sustracción entre todos los polígonos
             \em poliRec-poliBas.
\param[in] facPer Factor para el posible cálculo de la perturbación de las
           coordenadas de algunos vértices. Este valor es usado internamente por
           la función \ref Paso1Greiner (ver su documentación). Un buen valor
           para este argumento es #GEOC_GREINER_FAC_EPS_PERTURB.
\param[out] nIntersec Número total de intersecciones calculadas entre todas los
            polígonos.
\param[out] nPerturb Número total de puntos perturbados en el proceso.
\return Estructura \ref polig con los polígonos resultado de las operaciones. Si
        se devuelve \p NULL ha ocurrido un error de asignación de memoria.
\note Esta función realiza la operación \em op con todas las combinaciones
      posibles de polígonos. Es decir, se recorren todos los polígonos
      almacenados en \em poliBas y con cada uno de ellos se realiza la operación
      \em op con cada polígono almacenado en \em poliRec.
\note Esta función no comprueba si las variables \em poliBas y \em poliRec son
      polígonos correctamente almacenados.
\note Esta función no comprueba internamente si \em op pertenece al tipo
      enumerado #GEOC_OP_BOOL_POLIG. Si se introduce un valor no perteneciente
      al tipo, se realiza la operación #GeocOpBoolInter.
\note En el caso de tener que perturbar algún vértice, sólo se modifican los
      correspondientes a \em poliRec, dejando las coordenadas de los polígonos
      de \em poliBase inalteradas.
\note Si \em facPer es menor o igual que 1, se sustituye internamente su valor
      por #GEOC_GREINER_FAC_EPS_PERTURB (ver documentación de la función
      \ref CantPerturbMin).
\note Esta función realiza la unión exclusiva #GeocOpBoolXor mediante la unión
      de las operaciones individuales #GeocOpBoolAB y #GeocOpBoolBA. Esta última
      unión simplemente es el almacenamiento en la estructura de salida de los
      resultados de #GeocOpBoolAB y #GeocOpBoolBA. En ningún momento se realiza
      la operación booleana #GeocOpBoolUnion entre los resultados de
      #GeocOpBoolAB y #GeocOpBoolBA.
\date 07 de junio de 2011: Creación de la función.
\todo Esta función no está probada.
*/
polig* PoliBoolGreinerMult(const polig* poliBas,
                           const polig* poliRec,
                           const enum GEOC_OP_BOOL_POLIG op,
                           const double facPer,
                           size_t* nIntersec,
                           size_t* nPerturb);
/******************************************************************************/
/******************************************************************************/
/**
\brief Crea una estructura \ref polig a partir de todos los vértices de un
       polígono almacenado como una lista doblemente enlazada de elementos
       \ref _vertPoliClip.
\param[in] poli Polígono de trabajo, representado como una lista doblemente
                enlazada de elementos \ref _vertPoliClip. El puntero pasado ha
                de apuntar al primer elemento del polígono (no se controla
                internamente).
\param[in] coorOrig Identificador para copiar las coordenadas originales o
           perturbadas. Dos posibilidades:
           - 0: Se copiarán las coordenadas perturbadas _vertPoliClip::xP e
             _vertPoliClip::yP.
           - Distinto de 0: Se copiarán las coordenadas originales
             _vertPoliClip::x e _vertPoliClip::y.
\return Estructura \ref polig que representa el polígono. Si se devuelve \p NULL
        ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si la variable \em poli es un polígono
      correctamente almacenado.
\note Esta función \b *NO* trabaja con listas circulares.
\note Esta función realiza una copia en memoria de las coordenadas de los
      vértices de la estructura \em poli a la estructura de salida.
\date 29 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
polig* CreaPoligPoliClip(vertPoliClip* poli,
                         const int coorOrig);
/******************************************************************************/
/******************************************************************************/
/**
\brief Añade los vértices de un polígono almacenado como una lista doblemente
       enlazada de elementos \ref _vertPoliClip a una estructura \ref polig
       previamente creada.
\param[in,out] poli Estructura \ref polig, que almacena una serie de polígonos.
               Al término de la ejecución de la función, se han añadido los
               polígonos de la estructura \em anyade.
\param[in] anyade Polígono a añadir, representado como una lista doblemente
                  enlazada de elementos \ref _vertPoliClip. El puntero pasado ha
                  de apuntar al primer elemento del polígono (no se controla
                  internamente).
\param[in] coorOrig Identificador para copiar las coordenadas originales o
           perturbadas. Dos posibilidades:
           - 0: Se copiarán las coordenadas perturbadas _vertPoliClip::xP e
             _vertPoliClip::yP.
           - Distinto de 0: Se copiarán las coordenadas originales
             _vertPoliClip::x e _vertPoliClip::y.
\return Variable de error. Dos posibilidades:
        - #GEOC_ERR_NO_ERROR: Todo ha ido bien.
        - #GEOC_ERR_ASIG_MEMORIA: Ha ocurrido un error de asignación de memoria.
\note Esta función no comprueba si la variable \em poli es un polígono
      correctamente almacenado.
\note Esta función no comprueba si la variable \em anyade es un polígono
      correctamente almacenado.
\note Esta función \b *NO* trabaja con listas circulares.
\note Esta función realiza una copia en memoria de las coordenadas de los
      vértices de la estructura \em poli a la estructura de salida.
\note Esta función crea internamente una estructura \ref polig para luego
      añadirla a \em poli con la función \ref AnyadePoligPolig.
\date 29 de mayo de 2011: Creación de la función.
\todo Esta función no está probada.
*/
int AnyadePoligClipPolig(polig* poli,
                         vertPoliClip* anyade,
                         const int coorOrig);
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

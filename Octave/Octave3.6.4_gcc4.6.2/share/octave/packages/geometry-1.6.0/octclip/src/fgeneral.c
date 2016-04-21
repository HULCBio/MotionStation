/* -*- coding: utf-8 -*- */
/**
\ingroup eop general geom geopot matriz
@{
\file fgeneral.c
\brief Definición de funciones de utilidad general.
\author José Luis García Pallero, jgpallero@gmail.com
\note Este fichero contiene funciones paralelizadas con OpenMP.
\date 10 de octubre de 2009
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
#include"libgeoc/fgeneral.h"
/******************************************************************************/
/******************************************************************************/
int GeocParOmpFgeneral(char version[])
{
    //comprobamos si hay paralelización
#if defined(_OPENMP)
    //comprobamos si hay que extraer versión
    if(version!=NULL)
    {
        //calculamos la versión
        VersionOpenMP(_OPENMP,version);
    }
    //salimos de la función
    return 1;
#else
    if(version!=NULL)
    {
        //utilizamos la variable version para que no dé warming al compilar
        strcpy(version,"");
    }
    //salimos de la función
    return 0;
#endif
}
/******************************************************************************/
/******************************************************************************/
double PonAnguloDominio(const double angulo)
{
    //signo del ángulo de trabajo
    double signo=0.0;
    //2.0*pi
    double dosPi=2.0*GEOC_CONST_PI;
    //variable auxiliar
    double aux=angulo;
    //variable de salida
    double sal=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //sólo trabajamos si el valor de entrada está fuera de los límites
    if((angulo<=-dosPi)||(angulo>=dosPi))
    {
        //extraemos el signo del ángulo pasado
        signo = GEOC_SIGNO(angulo);
        //valor absoluto del ángulo pasado
        aux = fabs(angulo);
        //metemos el ángulo en dominio eliminando la cantidad que se pase de
        //2.0*pi
        sal = signo*(aux-floor(aux/dosPi)*dosPi);
    }
    else
    {
        //el valor de entrada no cambia
        sal = angulo;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
void BuscaSegmento1DInc(const double valor,
                        const double* lista,
                        const size_t nDatos,
                        const size_t incDatos,
                        size_t* posInicio,
                        size_t* posFin)
{
    //variable para recorrer bucles
    size_t i=0;
    //variable indicadora de búsqueda secuencial
    int busca=0;
    //variables para calcular posiciones
    size_t pos1=0,pos2=0;
    //posiciones en memoria
    size_t posm=0,pos1m=0,pos2m=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //CONSIDERAMOS QUE LA LISTA CONTIENE ENTEROS EQUIESPACIADOS UNA UNIDAD
    //posición del valor anterior al de trabajo
    pos1 = (size_t)(floor(valor)-lista[0]);
    //posición del valor posterior al de trabajo
    pos2 = (size_t)(ceil(valor)-lista[0]);
    //si pos1==pos2, valor puede ser un extremo de la lista
    if(pos1==pos2)
    {
        if(pos1!=(nDatos-1))
        {
            //calculamos el punto final del segmento
            pos2++;
        }
        else
        {
            //calculamos el punto inicial del segmento
            pos1--;
        }
    }
    //calculamos las posiciones en memoria
    pos1m = pos1*incDatos;
    pos2m = pos2*incDatos;
    //comprobamos si el segmento detectado es válido
    if((lista[pos1m]!=round(lista[pos1m]))||
       (lista[pos2m]!=round(lista[pos2m]))||
       ((lista[pos2m]-lista[pos1m])!=1.0)||
       (valor<lista[pos1m])||(valor>lista[pos2m]))
    {
        //indicamos que se ha de hacer una búsqueda secuencial
        busca = 1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //LA LISTA CONTIENE REALES NO EQUIESPACIADOS
    if(busca)
    {
        //recorremos todos los elementos de la lista
        for(i=0;i<nDatos;i++)
        {
            //posición en memoria
            posm = i*incDatos;
            //comprobamos si estamos ante un límite
            if(lista[posm]>=valor)
            {
                //comprobamos el tipo de límite
                if(lista[posm]>valor)
                {
                    //extraemos las posiciones
                    pos1 = i-1;
                    pos2 = i;
                }
                else
                {
                    //comprobamos si estamos trabajando con el último elemento
                    if(i==(nDatos-1))
                    {
                        //extraemos las posiciones
                        pos1 = i-1;
                        pos2 = i;
                    }
                    else
                    {
                        //extraemos las posiciones
                        pos1 = i;
                        pos2 = i+1;
                    }
                }
                //salimos del bucle
                break;
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos las variables de salida
    *posInicio = pos1;
    *posFin = pos2;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void BuscaSegmento1D(const double valor,
                     const double* lista,
                     const size_t nDatos,
                     size_t* posInicio,
                     size_t* posFin)
{
    //realizamos la búsqueda con incremento igual a 1
    BuscaSegmento1DInc(valor,lista,nDatos,1,posInicio,posFin);
}
/******************************************************************************/
/******************************************************************************/
void BuscaPosNWEnMalla(const double xPto,
                       const double yPto,
                       const double xMin,
                       const double xMax,
                       const double yMin,
                       const double yMax,
                       const double pasoX,
                       const double pasoY,
                       size_t* fil,
                       size_t* col)
{
    //dimensiones de la matriz
    size_t f=0,c=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos las dimensiones de la matriz de trabajo
    f = (size_t)(round((yMax-yMin)/pasoY)+1.0);
    c = (size_t)(round((xMax-xMin)/pasoX)+1.0);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos la fila y comprobamos si es el extremo S
    *fil = (size_t)(fabs(yPto-yMax)/pasoY);
    if(*fil==(f-1))
    {
        //retrasamos una fila
        (*fil)--;
    }
    //calculamos la columna y comprobamos si es el extremo E
    *col = (size_t)((xPto-xMin)/pasoX);
    if(*col==(c-1))
    {
        //retrasamos una columna
        (*col)--;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
double Minimo(const double* lista,
              const size_t nDatos,
              const size_t incDatos)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida, inicializada como el máximo valor para un double
    double salida=DBL_MAX;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP, sólo si la versión es superior a la 3.0
    //en versiones anteriores no existe la posibilidad de usar reduction(min:)
#if defined(_OPENMP)&&(_OPENMP>=GEOC_OMP_F_3_1)
#pragma omp parallel for default(none) \
 shared(lista) \
 private(i,pos) \
 reduction(min:salida)
#endif
    //recorremos el resto de elementos de la lista
    for(i=0;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es menor que el considerado menor
        if(lista[pos]<salida)
        {
            //asignamos el nuevo valor menor
            salida = lista[pos];
        }
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
double Maximo(const double* lista,
              const size_t nDatos,
              const size_t incDatos)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida, inicializada como el mínimo valor para un double
    double salida=DBL_MIN;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP, sólo si la versión es superior a la 3.0
    //en versiones anteriores no existe la posibilidad de usar reduction(max:)
#if defined(_OPENMP)&&(_OPENMP>=GEOC_OMP_F_3_1)
#pragma omp parallel for default(none) \
 shared(lista) \
 private(i,pos) \
 reduction(max:salida)
#endif
    //recorremos el resto de elementos de la lista
    for(i=0;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es mayor que el considerado mayor
        if(lista[pos]>salida)
        {
            //asignamos el nuevo valor menor
            salida = lista[pos];
        }
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
double MinimoAbs(const double* lista,
                 const size_t nDatos,
                 const size_t incDatos)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida, inicializada como el máximo valor para un double
    double salida=DBL_MAX;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP, sólo si la versión es superior a la 3.0
    //en versiones anteriores no existe la posibilidad de usar reduction(min:)
#if defined(_OPENMP)&&(_OPENMP>=GEOC_OMP_F_3_1)
#pragma omp parallel for default(none) \
 shared(lista) \
 private(i,pos) \
 reduction(min:salida)
#endif
    //recorremos el resto de elementos de la lista
    for(i=0;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es menor que el considerado menor
        if(fabs(lista[pos])<salida)
        {
            //asignamos el nuevo valor menor
            salida = fabs(lista[pos]);
        }
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
double MaximoAbs(const double* lista,
                 const size_t nDatos,
                 const size_t incDatos)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida, inicializada como 0.0 (trabajamos en valor absoluto)
    double salida=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP, sólo si la versión es superior a la 3.0
    //en versiones anteriores no existe la posibilidad de usar reduction(max:)
#if defined(_OPENMP)&&(_OPENMP>=GEOC_OMP_F_3_1)
#pragma omp parallel for default(none) \
 shared(lista) \
 private(i,pos) \
 reduction(max:salida)
#endif
    //recorremos el resto de elementos de la lista
    for(i=0;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es mayor que el considerado mayor
        if(fabs(lista[pos])>salida)
        {
            //asignamos el nuevo valor menor
            salida = fabs(lista[pos]);
        }
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
size_t MinimoSizeT(const size_t* lista,
                   const size_t nDatos,
                   const size_t incDatos)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida, inicializada como el máximo valor para un size_t
    size_t salida=SIZE_MAX;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP, sólo si la versión es superior a la 3.0
    //en versiones anteriores no existe la posibilidad de usar reduction(min:)
#if defined(_OPENMP)&&(_OPENMP>=GEOC_OMP_F_3_1)
#pragma omp parallel for default(none) \
 shared(lista) \
 private(i,pos) \
 reduction(min:salida)
#endif
    //recorremos el resto de elementos de la lista
    for(i=0;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es menor que el considerado menor
        if(lista[pos]<salida)
        {
            //asignamos el nuevo valor menor
            salida = lista[pos];
        }
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
size_t MaximoSizeT(const size_t* lista,
                   const size_t nDatos,
                   const size_t incDatos)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //variable de salida, inicializada como 0 (size_t es sólo positivo)
    size_t salida=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP, sólo si la versión es superior a la 3.0
    //en versiones anteriores no existe la posibilidad de usar reduction(max:)
#if defined(_OPENMP)&&(_OPENMP>=GEOC_OMP_F_3_1)
#pragma omp parallel for default(none) \
 shared(lista) \
 private(i,pos) \
 reduction(max:salida)
#endif
    //recorremos el resto de elementos de la lista
    for(i=0;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es mayor que el considerado mayor
        if(lista[pos]>salida)
        {
            //asignamos el nuevo valor menor
            salida = lista[pos];
        }
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
void MinMax(const double* lista,
            const size_t nDatos,
            const size_t incDatos,
            size_t* posMin,
            size_t* posMax)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //consideramos que el primer elemento es el mayor y el menor
    *posMin = 0;
    *posMax = 0;
    //recorremos el resto de elementos de la lista
    for(i=1;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es menor que el considerado menor
        if(lista[pos]<lista[(*posMin)*incDatos])
        {
            //asignamos la nueva posición
            *posMin = i;
        }
        //comprobamos si el elemento actual es mayor que el considerado mayor
        if(lista[pos]>lista[(*posMax)*incDatos])
        {
            //asignamos la nueva posición
            *posMax = i;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void MinMaxAbs(const double* lista,
               const size_t nDatos,
               const size_t incDatos,
               size_t* posMin,
               size_t* posMax)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //consideramos que el primer elemento es el mayor y el menor
    *posMin = 0;
    *posMax = 0;
    //recorremos el resto de elementos de la lista
    for(i=1;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es menor que el considerado menor
        if(fabs(lista[pos])<fabs(lista[(*posMin)*incDatos]))
        {
            //asignamos la nueva posición
            *posMin = i;
        }
        //comprobamos si el elemento actual es mayor que el considerado mayor
        if(fabs(lista[pos])>fabs(lista[(*posMax)*incDatos]))
        {
            //asignamos la nueva posición
            *posMax = i;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void MinMaxSizeT(const size_t* lista,
                 const size_t nDatos,
                 const size_t incDatos,
                 size_t* posMin,
                 size_t* posMax)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //consideramos que el primer elemento es el mayor y el menor
    *posMin = 0;
    *posMax = 0;
    //recorremos el resto de elementos de la lista
    for(i=1;i<nDatos;i++)
    {
        //posición del elemento a comprobar
        pos = i*incDatos;
        //comprobamos si el elemento actual es menor que el considerado menor
        if(lista[pos]<lista[(*posMin)*incDatos])
        {
            //asignamos la nueva posición
            *posMin = i;
        }
        //comprobamos si el elemento actual es mayor que el considerado mayor
        if(lista[pos]>lista[(*posMax)*incDatos])
        {
            //asignamos la nueva posición
            *posMax = i;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
double** AsigMemMatrizC(const size_t fil,
                        const size_t col)
{
    //índices para recorrer bucles
    size_t i=0;
    //matriz de salida
    double** matriz=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para el array principal
    matriz = (double**)malloc(fil*sizeof(double*));
    //comprobamos los errores
    if(matriz==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos toda la memoria al primer puntero
    matriz[0] = (double*)malloc(fil*col*sizeof(double));
    //comprobamos los errores
    if(matriz[0]==NULL)
    {
        //liberamos la memoria previamente asignada
        free(matriz);
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //recorremos el resto de filas
    for(i=1;i<fil;i++)
    {
        //vamos asignando las direcciones de inicio de cada fila
        matriz[i] = &matriz[0][i*col];
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return matriz;
}
/******************************************************************************/
/******************************************************************************/
void LibMemMatrizC(double** matriz)
{
    //sólo trabajamos si hay memoria asignada
    if(matriz!=NULL)
    {
        //sólo trabajamos si hay memoria asignada
        if(matriz[0]!=NULL)
        {
            //liberamos la memoria de los datos
            free(matriz[0]);
        }
        //liberamos la memoria del array principal
        free(matriz);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
size_t* PosRepeEnVector(const double* datos,
                        const size_t nDatos,
                        const size_t incDatos,
                        size_t* nRepe)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de repeticiones encontradas
    size_t numRep=0;
    //datos de las posiciones de trabajo
    double dato=0.0,datoTrab=0.0;
    //variable de salida
    size_t* pos=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para el vector de salida
    pos = (size_t*)malloc(nDatos*sizeof(double));
    //comprobamos los posibles errores
    if(pos==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la primera posición, extraemos el dato e inicializamos el
    //contador de repeticiones
    pos[0] = 0;
    dato = datos[0];
    numRep = 1;
    //recorremos el resto de elementos del vector
    for(i=1;i<nDatos;i++)
    {
        //extraemos el dato de trabajo
        datoTrab = datos[i*incDatos];
        //lo comparamos con el dato de referencia
        if(datoTrab!=dato)
        {
            //asignamos la nueva posición
            pos[numRep] = i;
            //aumentamos el contador de repeticiones
            numRep++;
            //convertimos el nuevo dato en dato de referencia
            dato = datoTrab;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ajustamos la memoria al número de posiciones repetidas encontradas
    pos = (size_t*)realloc(pos,numRep*sizeof(double));
    //comprobamos los posibles errores
    if(pos==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //indicamos el número de repeticiones
    *nRepe = numRep;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
}
/******************************************************************************/
/******************************************************************************/
size_t* NumElemRepeEnVector(const size_t* pos,
                            const size_t nPos,
                            const size_t nElemVecOrig)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de salida
    size_t* num=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para el vector de salida
    num = (size_t*)malloc(nPos*sizeof(double));
    //comprobamos los posibles errores
    if(num==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos el vector de posiciones desde el segundo elemento
    for(i=1;i<nPos;i++)
    {
        //vamos calculando los elementos repetidos
        num[i-1] = pos[i]-pos[i-1];
    }
    //comprobamos si la última posición corresponde al último elemento del
    //vector original
    if(pos[nPos-1]==(nElemVecOrig-1))
    {
        //el último número es 1
        num[nPos-1] = 1;
    }
    else
    {
        //tenemos en cuente que los elementos son el mismo hasta el final
        num[nPos-1] = nElemVecOrig-pos[nPos-1];
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return num;
}
/******************************************************************************/
/******************************************************************************/
void EscalaYTrasladaVector(double* vector,
                           const size_t nElem,
                           const size_t inc,
                           const double escala,
                           const double traslada)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //distinguimos entre incremento igual a 1 o mayor
    if(inc==1)
    {
        //recorremos los elementos del vector
        for(i=0;i<nElem;i++)
        {
            //primero factor de escala y luego traslación
            vector[i] = vector[i]*escala+traslada;
        }
    }
    else
    {
        //recorremos los elementos del vector
        for(i=0;i<nElem;i++)
        {
            //posición en el vector de trabajo
            pos = i*inc;
            //primero factor de escala y luego traslación
            vector[pos] = vector[pos]*escala+traslada;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void TrasladaYEscalaVector(double* vector,
                           const size_t nElem,
                           const size_t inc,
                           const double escala,
                           const double traslada)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //distinguimos entre incremento igual a 1 o mayor
    if(inc==1)
    {
        //recorremos los elementos del vector
        for(i=0;i<nElem;i++)
        {
            //primero traslación y luego factor de escala
            vector[i] = (vector[i]+traslada)*escala;
        }
    }
    else
    {
        //recorremos los elementos del vector
        for(i=0;i<nElem;i++)
        {
            //posición en el vector de trabajo
            pos = i*inc;
            //primero traslación y luego factor de escala
            vector[pos] = (vector[pos]+traslada)*escala;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
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

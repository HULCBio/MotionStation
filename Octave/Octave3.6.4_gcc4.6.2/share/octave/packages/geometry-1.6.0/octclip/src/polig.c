/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file polig.c
\brief Definición de funciones para el trabajo con polígonos.
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
#include"libgeoc/polig.h"
/******************************************************************************/
/******************************************************************************/
int GeocParOmpPolig(char version[])
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
polig* IniciaPoligVacio(void)
{
    //estructura de salida
    polig* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para la estructura
    sal = (polig*)malloc(sizeof(polig));
    //comprobamos los posibles errores
    if(sal==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //inicializamos los campos escalares a 0
    sal->nElem = 0;
    sal->nPolig = 0;
    sal->hayLim = 0;
    sal->hayArea = 0;
    //inicializamos los campos vectoriales a NULL
    sal->x = NULL;
    sal->y = NULL;
    sal->posIni = NULL;
    sal->nVert = NULL;
    sal->xMin = NULL;
    sal->xMax = NULL;
    sal->yMin = NULL;
    sal->yMax = NULL;
    sal->area = NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
int AuxCreaPolig1(const size_t nElem,
                  const size_t* posNanX,
                  const size_t* posNanY,
                  const size_t nNanX,
                  const size_t nNanY,
                  size_t* nElemMax,
                  size_t* nPolig)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de salida
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay el mismo número de NaN en los dos vectores
    if(nNanX!=nNanY)
    {
        //salimos de la función
        return GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG;
    }
    //comprobamos si hay NaN en las mismas posiciones de los vectores
    for(i=0;i<nNanX;i++)
    {
        //comprobamos si las posiciones no son las mismas
        if(posNanX[i]!=posNanY[i])
        {
            //salimos de la función
            return GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos un número máximo de elementos de los vectores de coordenadas
    //suponiendo que no hay NaN al principio ni al final y que no se repiten las
    //coordenadas iniciales de cada polígono
    *nElemMax = nElem+2+nNanX+1;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número de polígonos, dependiendo del número de NaN
    if((nNanX==0)||
       ((nNanX==1)&&(posNanX[0]==0))||
       ((nNanX==1)&&(posNanX[nNanX-1]==(nElem-1)))||
       ((nNanX==2)&&(posNanX[0]==0)&&(posNanX[nNanX-1]==(nElem-1))))
    {
        //sólo hay un polígono
        *nPolig = 1;
    }
    else if((posNanX[0]!=0)&&(posNanX[nNanX-1]!=(nElem-1)))
    {
        //si no hay NaN en los extremos, el número de polígonos es nNan+1
        *nPolig = nNanX+1;
    }
    else if((posNanX[0]==0)&&(posNanX[nNanX-1]==(nElem-1)))
    {
        //si hay NaN en los dos extremos, el número de polígonos es nNan-1
        *nPolig = nNanX-1;
    }
    else
    {
        //en otro caso, es el número de NaN
        *nPolig = nNanX;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
void AuxCreaPolig2(const double* x,
                   const double* y,
                   const size_t nElem,
                   const size_t incX,
                   const size_t incY,
                   double* xSal,
                   double* ySal,
                   size_t* nCopias)
{
    //índice para recorrer bucles
    size_t i=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //en principio, el número de puntos copiados es igual al indicado
    *nCopias = nElem;
    //contemplamos una posible salida rápida
    if(nElem==0)
    {
        //salimos de la función
        return;
    }
    //recorremos los puntos de trabajo
    for(i=0;i<nElem;i++)
    {
        //vamos copiando
        xSal[i] = x[i*incX];
        ySal[i] = y[i*incY];
    }
    //comprobamos si hay que copiar el primer punto al final
    if((x[0]!=x[(nElem-1)*incX])||(y[0]!=y[(nElem-1)*incY]))
    {
        //repetimos el primer punto
        xSal[nElem] = x[0];
        ySal[nElem] = y[0];
        //aumentamos el contador de puntos copiados
        (*nCopias)++;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
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
                   size_t* nPolig)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de vértices del polígono a copiar y posición inicial de un polígono
    size_t nV=0,pI=0;
    //número de vértices copiados
    size_t nCopias=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos las variables de número de puntos copiados y número de
    //polígonos
    *nPtos = 0;
    *nPolig = 0;
    //comprobamos si los vectores empiezan directamente con coordenadas
    if((nNan==0)||(posNan[0]!=0))
    {
        //el primer elemento de los vectores de salida es NaN
        xSal[0] = GeocNan();
        ySal[0] = GeocNan();
        //aumentamos la variable de número de puntos copiados
        (*nPtos)++;
        //calculamos el número de vértices del polígono
        if(nNan)
        {
            //si hay valores NaN, el número de vértices es igual a la posición
            //del siguiente NaN
            nV = posNan[0];
        }
        else
        {
            //si no hay NaN, el número de vértices es igual al número de
            //elementos de los vectores de coordenadas
            nV = nElem;
        }
        //copiamos el primer polígono
        AuxCreaPolig2(&x[0],&y[0],nV,incX,incY,&xSal[*nPtos],&ySal[*nPtos],
                      &nCopias);
        //indicamos la posición de inicio del polígono y el número de vértices
        posIni[*nPolig] = 1;
        nVert[*nPolig] = nCopias;
        //sumamos el número de puntos copiados a la variable
        (*nPtos) += nCopias;
        //aumentamos el contador de polígonos
        (*nPolig)++;
    }
    //recorremos el número de NaN
    for(i=0;i<nNan;i++)
    {
        //copiamos el NaN
        xSal[*nPtos] = GeocNan();
        ySal[*nPtos] = GeocNan();
        //aumentamos la variable de número de puntos copiados
        (*nPtos)++;
        //posición del primer punto del polígono
        pI = posNan[i]+1;
        //sólo continuamos si el NaN no es la última posición de los vectores
        if(pI!=nElem)
        {
            //calculo el número de puntos del polígono, dependiendo del NaN de
            //trabajo
            if(i!=(nNan-1))
            {
                //todavía hay más NaN por delante
                nV = posNan[i+1]-pI;
            }
            else
            {
                //este es el último NaN de la lista
                nV = nElem-pI;
            }
            //copiamos las coordenadas del polígono
            AuxCreaPolig2(&x[pI*incX],&y[pI*incY],nV,incX,incY,&xSal[*nPtos],
                          &ySal[*nPtos],&nCopias);
            //comprobamos el número de puntos copiados
            if(nCopias)
            {
                //indicamos la posición de inicio del polígono y el número de
                //vértices
                posIni[*nPolig] = *nPtos;
                nVert[*nPolig] = nCopias;
                //sumamos el número de puntos copiados a la variable
                (*nPtos) += nCopias;
                //aumentamos el contador de polígonos
                (*nPolig)++;
            }
            else
            {
                //si no se han copiado puntos, el polígono era falso (había dos
                //NaN seguidos, luego descuento el último NaN copiado
                (*nPtos)--;
            }
        }
    }
    //copiamos el último NaN, si no se ha copiado ya
    if(!EsGeocNan(xSal[(*nPtos)-1]))
    {
        //copiamos
        xSal[*nPtos] = GeocNan();
        ySal[*nPtos] = GeocNan();
        //aumentamos el contador de puntos
        (*nPtos)++;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
polig* CreaPolig(const double* x,
                 const double* y,
                 const size_t nElem,
                 const size_t incX,
                 const size_t incY,
                 int* idError)
{
    //número de puntos
    size_t ptos=0;
    //número máximo de elementos de los vectores de coordenadas
    size_t nElemMax=0;
    //número de polígonos
    size_t nPolig=0;
    //número de identificadores NaN
    size_t nNanX=0,nNanY=0;
    //posiciones de los identificadores NaN
    size_t* posNanX=NULL;
    size_t* posNanY=NULL;
    //estructura de salida
    polig* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la variable de error
    *idError = GEOC_ERR_NO_ERROR;
    //creamos la estructura vacía
    sal = IniciaPoligVacio();
    //comprobamos los posibles errores
    if(sal==NULL)
    {
        //asignamos la variable de error
        *idError = GEOC_ERR_ASIG_MEMORIA;
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //contemplamos una posible salida rápida
    if(nElem==0)
    {
        //devolvemos la estructura vacía
        return sal;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contamos el número de identificadores NaN en los vectores de entrada
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(posNanX,x,nNanX,posNanY,y,nNanY)
#endif
{
#if defined(_OPENMP)
#pragma omp section
#endif
    //contamos el número de indentificadores NaN en el vector X
    posNanX = PosGeocNanEnVector(x,nElem,incX,&nNanX);
#if defined(_OPENMP)
#pragma omp section
#endif
    //contamos el número de indentificadores NaN en el vector Y
    posNanY = PosGeocNanEnVector(y,nElem,incY,&nNanY);
} // --> fin del #pragma omp parallel sections
    //comprobamos los posibles errores de asignación de memoria
    if(((posNanX==NULL)&&(nNanX!=0))||((posNanY==NULL)&&(nNanY!=0)))
    {
        //liberamos la memoria asignada
        LibMemPolig(sal);
        free(posNanX);
        free(posNanY);
        //asignamos la variable de error
        *idError = GEOC_ERR_ASIG_MEMORIA;
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si los vectores tienen bien colocados los NaN y calculamos
    //el número máximo de elementos de los vectores de la estructura y el
    //número de polígonos
    *idError = AuxCreaPolig1(nElem,posNanX,posNanY,nNanX,nNanY,&nElemMax,
                             &nPolig);
    //comprobamos los posibles errores
    if(*idError!=GEOC_ERR_NO_ERROR)
    {
        //liberamos la memoria asignada
        LibMemPolig(sal);
        free(posNanX);
        free(posNanY);
        //escribimos el mensaje de error
        if(*idError==GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen el mismo "
                       "número de polígonos");
        }
        else if(*idError==GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen los mismos "
                       "polígonos");
        }
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos el número de polígonos
    sal->nPolig = nPolig;
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(sal,nElemMax,nPolig)
#endif
{
    //asignamos memoria para los vectores de la estructura
#if defined(_OPENMP)
#pragma omp section
#endif
    sal->x = (double*)malloc(nElemMax*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    sal->y = (double*)malloc(nElemMax*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    sal->posIni = (size_t*)malloc(nPolig*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    sal->nVert = (size_t*)malloc(nPolig*sizeof(double));
} // --> fin del #pragma omp parallel sections
    //comprobamos los posibles errores
    if((sal->x==NULL)||(sal->y==NULL)||(sal->posIni==NULL)||(sal->nVert==NULL))
    {
        //liberamos la memoria asignada
        LibMemPolig(sal);
        free(posNanX);
        free(posNanY);
        //asignamos la variable de error
        *idError = GEOC_ERR_ASIG_MEMORIA;
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //copiamos los polígonos a la estructura
    //como ya sabemos que el número de NaN y sus posiciones son los mismos para
    //los vectores x e y, trabajamos con los valores para el vector x
    AuxCreaPolig3(x,y,nElem,incX,incY,posNanX,nNanX,sal->x,sal->y,sal->posIni,
                  sal->nVert,&ptos,&nPolig);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay de verdad algún polígono
    if(nPolig==0)
    {
        //liberamos la memoria asignada
        LibMemPolig(sal);
        free(posNanX);
        free(posNanY);
        //creamos la estructura vacía
        sal = IniciaPoligVacio();
        //comprobamos los posibles errores
        if(sal==NULL)
        {
            //asignamos la variable de error
            *idError = GEOC_ERR_ASIG_MEMORIA;
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //salimos de la función
        return sal;
    }
    //asignamos el número de elementos a la estructura
    sal->nElem = ptos;
    //comprobamos si hay que reajustar el tamaño de los vectores de coordenadas
    if(ptos!=nElemMax)
    {
        //asignamos el nuevo tamaño de los vectores
        sal->nElem = ptos;
        //reajustamos los tamaños
        sal->x = (double*)realloc(sal->x,ptos*sizeof(double));
        sal->y = (double*)realloc(sal->y,ptos*sizeof(double));
    }
    //comprobamos si el número de polígonos es el estimado
    if(nPolig!=sal->nPolig)
    {
        //asignamos de nuevo la variable de número de polígonos
        sal->nPolig = nPolig;
        //reajustamos los tamaños
        sal->posIni = (size_t*)realloc(sal->posIni,nPolig*sizeof(size_t));
        sal->nVert = (size_t*)realloc(sal->nVert,nPolig*sizeof(size_t));
    }
    //comprobamos los posibles errores
    if((sal->x==NULL)||(sal->y==NULL)||(sal->posIni==NULL)||(sal->nVert==NULL))
    {
        //liberamos la memoria asignada
        LibMemPolig(sal);
        free(posNanX);
        free(posNanY);
        //asignamos la variable de error
        *idError = GEOC_ERR_ASIG_MEMORIA;
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //liberamos la memoria asignada
    free(posNanX);
    free(posNanY);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
void EnlazaCamposPolig(polig* poliEnt,
                       polig* poliSal)
{
    //LIBERAMOS LA POSIBLE MEMORIA ASIGNADA A LOS CAMPOS VECTORIALES DE LA
    //ESTRUCTURA DE SALIDA
    //comprobamos si hay algún elemento en los vectores de coordenadas
    if(poliSal->nElem)
    {
        free(poliSal->x);
        free(poliSal->y);
    }
    //comprobamos si hay algún polígono en los vectores de posiciones
    if(poliSal->nPolig)
    {
        free(poliSal->posIni);
        free(poliSal->nVert);
    }
    //comprobamos si hay límites calculados
    if(poliSal->hayLim)
    {
        free(poliSal->xMin);
        free(poliSal->xMax);
        free(poliSal->yMin);
        free(poliSal->yMax);
    }
    //comprobamos si hay superficies calculadas
    if(poliSal->hayArea)
    {
        free(poliSal->area);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //enlazamos todos los campos de la estructura de entrada en la de salida
    poliSal->nElem = poliEnt->nElem;
    poliSal->x = poliEnt->x;
    poliSal->y = poliEnt->y;
    poliSal->nPolig = poliEnt->nPolig;
    poliSal->posIni = poliEnt->posIni;
    poliSal->nVert = poliEnt->nVert;
    poliSal->hayLim = poliEnt->hayLim;
    poliSal->xMin = poliEnt->xMin;
    poliSal->xMax = poliEnt->xMax;
    poliSal->yMin = poliEnt->yMin;
    poliSal->yMax = poliEnt->yMax;
    poliSal->hayArea = poliEnt->hayArea;
    poliSal->area = poliEnt->area;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
polig* CopiaPolig(const polig* poli,
                  int* idError)
{
    //polígono de salida
    polig* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la variable de error
    *idError = GEOC_ERR_NO_ERROR;
    //inicializamos el polígono de salida
    sal = IniciaPoligVacio();
    //comprobamos los posibles errores
    if(sal==NULL)
    {
        //asignamos la variable de error
        *idError = GEOC_ERR_ASIG_MEMORIA;
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //sólo continuamos si el polígono de entrada contiene datos
    if(poli->nElem)
    {
        //copiamos las coordenadas de los vértices
        *idError = AnyadeDatosPolig(sal,poli->x,poli->y,poli->nElem,1,1);
        //comprobamos si ha ocurrido algún error
        if((*idError)!=GEOC_ERR_NO_ERROR)
        {
            //liberamos la memoria asignada
            LibMemPolig(sal);
            //escribimos el mensaje de error
            if((*idError)==GEOC_ERR_ASIG_MEMORIA)
            {
                GEOC_ERROR("Error de asignación de memoria");
            }
            else if((*idError)==GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG)
            {
                GEOC_ERROR("Error: Los vectores de coordenadas del polígono\n"
                           "de entrada no contienen el mismo número de "
                           "polígonos");
            }
            else if((*idError)==GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG)
            {
                GEOC_ERROR("Error: Los vectores de coordenadas del polígono\n"
                           "de entrada no contienen los mismos polígonos");
            }
            //salimos de la función
            return NULL;
        }
        //comprobamos si hay que calcular límites
        if(poli->hayLim)
        {
            //calculamos los límites
            *idError = CalcLimitesPolig(sal);
            //comprobamos los posibles errores
            if((*idError)!=GEOC_ERR_NO_ERROR)
            {
                //liberamos la memoria asignada
                LibMemPolig(sal);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
        }
        //comprobamos si hay que calcular superficies
        if(poli->hayArea)
        {
            //calculamos las áreas
            *idError = CalcAreaPolig(sal);
            //comprobamos los posibles errores
            if((*idError)!=GEOC_ERR_NO_ERROR)
            {
                //liberamos la memoria asignada
                LibMemPolig(sal);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
int AnyadePoligPolig(polig* poli,
                     const polig* anyade)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //número total de elementos
    size_t nElem=0,nPolig=0;
    //variable de estado (salida)
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //si el polígono a añadir está vacío, salimos de la función
    if((anyade!=NULL)&&(anyade->nPolig==0))
    {
        //salimos de la función sin hacer nada
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número total de elementos del polígono conjunto
    nElem = poli->nElem+anyade->nElem;
    //si el polígono original contenía datos, al número total de elementos hay
    //que restarle 1 por el NaN común que sobra al juntar las dos estructuras
    if(poli->nPolig)
    {
        nElem--;
    }
    //calculamos el número total de polígonos
    nPolig = poli->nPolig+anyade->nPolig;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //reasignamos memoria para cubrir los nuevos datos
    poli->x = (double*)realloc(poli->x,nElem*sizeof(double));
    poli->y = (double*)realloc(poli->y,nElem*sizeof(double));
    poli->posIni = (size_t*)realloc(poli->posIni,nPolig*sizeof(size_t));
    poli->nVert = (size_t*)realloc(poli->nVert,nPolig*sizeof(size_t));
    //reasignamos también para los posibles vectores de límites y superficies
    if(poli->hayLim)
    {
        poli->xMin = (double*)realloc(poli->xMin,nPolig*sizeof(double));
        poli->xMax = (double*)realloc(poli->xMax,nPolig*sizeof(double));
        poli->yMin = (double*)realloc(poli->yMin,nPolig*sizeof(double));
        poli->yMax = (double*)realloc(poli->yMax,nPolig*sizeof(double));
    }
    if(poli->hayArea)
    {
        poli->area = (double*)realloc(poli->area,nPolig*sizeof(double));
    }
    //comprobamos los posibles errores en las asignaciones obligatorias
    if((poli->x==NULL)||(poli->y==NULL)||(poli->posIni==NULL)||
       (poli->nVert==NULL))
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return GEOC_ERR_ASIG_MEMORIA;
    }
    //comprobamos los posibles errores en las asignaciones de límites
    if(poli->hayLim)
    {
        if((poli->xMin==NULL)||(poli->xMax==NULL)||(poli->yMin==NULL)||
           (poli->yMax==NULL))
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return GEOC_ERR_ASIG_MEMORIA;
        }
    }
    //comprobamos los posibles errores en las asignaciones de áreas
    if(poli->hayArea)
    {
        if(poli->area==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return GEOC_ERR_ASIG_MEMORIA;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos la posición de inicio para copiar en la estructura de salida
    //si la estructura de salida está vacía, se comienza en la primera posición
    //si tiene datos, se comienza a continuación en la última (dentro del bucle,
    //la suma de posIni hace que se comience a continuación de la última)
    pos = (poli->nPolig==0) ? 0 : poli->nElem-1;
    //recorremos el número de nuevos elementos
    for(i=0;i<anyade->nElem;i++)
    {
        //copiamos las coordenadas
        poli->x[pos+i] = anyade->x[i];
        poli->y[pos+i] = anyade->y[i];
    }
    //calculamos las posiciones a sumar para ajustar las posiciones de inicio de
    //los polígonos añadidos
    //si la estructura de salida está vacía, se copian las posiciones tal cual
    //si tiene datos, se suman las posiciones ya ocupadas
    pos = (poli->nPolig==0) ? 0 : poli->nElem-1;
    //recorremos el número de polígonos
    for(i=0;i<anyade->nPolig;i++)
    {
        //copiamos las posiciones de inicio actualizadas y el número de vértices
        poli->posIni[poli->nPolig+i] = anyade->posIni[i]+pos;
        poli->nVert[poli->nPolig+i] = anyade->nVert[i];
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay que calcular límites
    if(poli->hayLim)
    {
        //comprobamos si ya están calculados
        if(anyade->hayLim)
        {
            //recorremos el número de polígonos y copiamos los límites
            for(i=0;i<anyade->nPolig;i++)
            {
                //copiamos los límites
                poli->xMin[poli->nPolig+i] = anyade->xMin[i];
                poli->xMax[poli->nPolig+i] = anyade->xMax[i];
                poli->yMin[poli->nPolig+i] = anyade->yMin[i];
                poli->yMax[poli->nPolig+i] = anyade->yMax[i];
            }
        }
        else
        {
            //calculamos los límites y los copiamos
            LimitesPoligonosPolig(&(anyade->x[1]),&(anyade->y[1]),1,1,
                                  anyade->posIni,anyade->nVert,anyade->nPolig,
                                  anyade->posIni[0],&(poli->xMin[poli->nPolig]),
                                  &(poli->xMax[poli->nPolig]),
                                  &(poli->yMin[poli->nPolig]),
                                  &(poli->yMax[poli->nPolig]));
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay que calcular áreas
    if(poli->hayArea)
    {
        //comprobamos si ya están calculadas
        if(anyade->hayArea)
        {
            //recorremos el número de polígonos y copiamos las superficies
            for(i=0;i<anyade->nPolig;i++)
            {
                //copiamos los límites
                poli->area[poli->nPolig+i] = anyade->area[i];
            }
        }
        else
        {
            //calculamos las superficies y las copiamos
            AreaPoligonosSimplesPolig(&(anyade->x[1]),&(anyade->y[1]),1,1,
                                      anyade->posIni,anyade->nVert,
                                      anyade->nPolig,anyade->posIni[0],
                                      &(poli->area[poli->nPolig]));
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ajustamos los tamaños antes de salir
    poli->nElem = nElem;
    poli->nPolig = nPolig;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
int AnyadeDatosPolig(polig* poli,
                     const double* x,
                     const double* y,
                     const size_t nElem,
                     const size_t incX,
                     const size_t incY)
{
    //polígono auxiliar
    polig* aux=NULL;
    //variable de estado (salida)
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contemplamos una posible salida rápida
    if(nElem==0)
    {
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //creamos un nuevo polígono con los datos a añadir
    aux = CreaPolig(x,y,nElem,incX,incY,&estado);
    //comprobamos los posibles errores
    if(estado!=GEOC_ERR_NO_ERROR)
    {
        //liberamos la memoria asignada
        LibMemPolig(aux);
        //escribimos el mensaje de error
        if(estado==GEOC_ERR_ASIG_MEMORIA)
        {
            GEOC_ERROR("Error de asignación de memoria");
        }
        else if(estado==GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen el mismo "
                       "número de polígonos");
        }
        else if(estado==GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen los mismos "
                       "polígonos");
        }
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //añadimos la nueva estructura
    estado = AnyadePoligPolig(poli,aux);
    //comprobamos los posibles errores
    if(estado!=GEOC_ERR_NO_ERROR)
    {
        //liberamos la memoria asignada
        LibMemPolig(aux);
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //liberamos la memoria utilizada
    LibMemPolig(aux);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
void LibMemPolig(polig* datos)
{
    //comprobamos si hay memoria que liberar
    if(datos!=NULL)
    {
        //liberamos la memoria asignada al vector de coordenadas X
        if(datos->x!=NULL)
        {
            free(datos->x);
        }
        //liberamos la memoria asignada al vector de coordenadas Y
        if(datos->y!=NULL)
        {
            free(datos->y);
        }
        //liberamos la memoria asignada al vector de posiciones
        if(datos->posIni!=NULL)
        {
            free(datos->posIni);
        }
        //liberamos la memoria asignada al vector de número de vértices
        if(datos->nVert!=NULL)
        {
            free(datos->nVert);
        }
        //liberamos la memoria asignada a los vector de coordenadas X mínimas
        if(datos->xMin!=NULL)
        {
            free(datos->xMin);
        }
        //liberamos la memoria asignada a los vector de coordenadas X máximas
        if(datos->xMax!=NULL)
        {
            free(datos->xMax);
        }
        //liberamos la memoria asignada a los vector de coordenadas Y mínimas
        if(datos->yMin!=NULL)
        {
            free(datos->yMin);
        }
        //liberamos la memoria asignada a los vector de coordenadas Y máximas
        if(datos->yMax!=NULL)
        {
            free(datos->yMax);
        }
        //liberamos la memoria asignada al vector de áreas
        if(datos->area!=NULL)
        {
            free(datos->area);
        }
        //liberamos la memoria asignada a la estructura
        free(datos);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int CalcLimitesPolig(polig* poli)
{
    //variable de estado (salida)
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos salida rápida
    if((poli->nPolig==0)||(poli->hayLim))
    {
        //salimos de la función si la estructura no contiene polígonos o si
        //éstos ya tienen calculados sus límites
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(poli)
#endif
{
    //asignamos memoria para los vectores de límites
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->xMin = (double*)malloc((poli->nPolig)*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->xMax = (double*)malloc((poli->nPolig)*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->yMin = (double*)malloc((poli->nPolig)*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->yMax = (double*)malloc((poli->nPolig)*sizeof(double));
} // --> fin del #pragma omp parallel sections
    //comprobamos los posibles errores
    if((poli->xMin==NULL)||(poli->xMax==NULL)||(poli->yMin==NULL)||
       (poli->yMax==NULL))
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return GEOC_ERR_ASIG_MEMORIA;
    }
    //indicamos que sí hay límites
    poli->hayLim = 1;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos los límites de todos los polígonos
    LimitesPoligonosPolig(poli->x,poli->y,1,1,poli->posIni,poli->nVert,
                          poli->nPolig,0,poli->xMin,poli->xMax,poli->yMin,
                          poli->yMax);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
void LimitesPoligono(const double* x,
                     const double* y,
                     const size_t nElem,
                     const size_t incX,
                     const size_t incY,
                     double* xMin,
                     double* xMax,
                     double* yMin,
                     double* yMax)
{
    //posiciones de los elementos máximo y mínimo
    size_t posXMin=0,posXMax=0,posYMin=0,posYMax=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //buscamos las posiciones de los elementos máximo y mínimo
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(x,posXMin,posXMax,y,posYMin,posYMax)
#endif
{
    //posiciones en el vector X
#if defined(_OPENMP)
#pragma omp section
#endif
    MinMax(x,nElem,incX,&posXMin,&posXMax);
    //posiciones en el vector Y
#if defined(_OPENMP)
#pragma omp section
#endif
    MinMax(y,nElem,incY,&posYMin,&posYMax);
} // --> fin del #pragma omp parallel sections
    //extraemos los valores de las posiciones calculadas
    *xMin = x[posXMin*incX];
    *xMax = x[posXMax*incX];
    *yMin = y[posYMin*incY];
    *yMax = y[posYMax*incY];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
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
                           double* yMax)
{
    //índice para recorrer bucles
    size_t i=0;
    //posición inicial del polígono de trabajo
    size_t pI=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel for default(none) schedule(dynamic) \
 shared(posIni,x,y,nVert,xMin,xMax,yMin,yMax) \
 private(i,pI)
#endif
    //recorremos el número de polígonos
    for(i=0;i<nPolig;i++)
    {
        //calculamos la posición inicial del polígono
        pI = posIni[i]-restaPosIni;
        //calculamos los límites
        LimitesPoligono(&x[pI*incX],&y[pI*incY],nVert[i],incX,incY,&xMin[i],
                        &xMax[i],&yMin[i],&yMax[i]);
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int CalcAreaPolig(polig* poli)
{
    //variable de estado (salida)
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos salida rápida
    if((poli->nPolig==0)||(poli->hayArea))
    {
        //salimos de la función si la estructura no contiene polígonos o si
        //éstos ya tienen calculada su superficie
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para el vector de superficies
    poli->area = (double*)malloc((poli->nPolig)*sizeof(double));
    //comprobamos los posibles errores
    if(poli->area==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return GEOC_ERR_ASIG_MEMORIA;
    }
    //indicamos que sí hay superficies
    poli->hayArea = 1;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos las superficies de todos los polígonos
    AreaPoligonosSimplesPolig(poli->x,poli->y,1,1,poli->posIni,poli->nVert,
                              poli->nPolig,0,poli->area);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
double AreaPoligonoSimple(const double* x,
                          const double* y,
                          const size_t nElem,
                          const size_t incX,
                          const size_t incY)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de elementos de trabajo, que inicializamos con el valor pasado
    size_t nElemTrab=nElem;
    //variable de salida
    double area=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //si el primero punto es el mismo que el último, restamos una unidad al
    //número de elementos pasado, ya que el algoritmo está preparado para
    //trabajar con un vector en el que no se repite el primer punto
    if((x[0]==x[(nElem-1)*incX])&&(y[0]==y[(nElem-1)*incY]))
    {
        //el número de elementos de trabajo es uno menos que el pasado
        nElemTrab = nElem-1;
    }
    //el algoritmo utilizado es la segunda expresión de la ecuación 21.4.20 del
    //Numerical Recipes, tercera edición, página 1127
    //recorremos los puntos hasta el penúltimo
    for(i=0;i<(nElemTrab-1);i++)
    {
        //vamos sumando
        area += (x[(i+1)*incX]+x[i*incX])*(y[(i+1)*incY]-y[i*incY]);
    }
    //sumamos la contribución del último lado, es decir, el lado que contiene
    //como vértice final al primer punto
    area += (x[0]+x[(nElemTrab-1)*incX])*(y[0]-y[(nElemTrab-1)*incY]);
    //dividimos entre dos para calcular el área real
    area /= 2.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return area;
}
/******************************************************************************/
/******************************************************************************/
void AreaPoligonosSimplesPolig(const double* x,
                               const double* y,
                               const size_t incX,
                               const size_t incY,
                               const size_t* posIni,
                               const size_t* nVert,
                               const size_t nPolig,
                               const size_t restaPosIni,
                               double* area)
{
    //índice para recorrer bucles
    size_t i=0;
    //posición inicial del polígono de trabajo
    size_t pI=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel for default(none) schedule(dynamic) \
 shared(posIni,area,x,y,nVert) \
 private(i,pI)
#endif
    //recorremos el número de polígonos
    for(i=0;i<nPolig;i++)
    {
        //calculamos la posición inicial del polígono
        pI = posIni[i]-restaPosIni;
        //calculamos la superficie
        area[i] = AreaPoligonoSimple(&x[pI*incX],&y[pI*incY],nVert[i],incX,
                                     incY);
    } // --> fin del #pragma omp parallel for
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void EscalaYTrasladaPolig(polig* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim,
                          const int aplicaArea)
{
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(poli)
#endif
{
#if defined(_OPENMP)
#pragma omp section
#endif
    //aplicamos los factores de escala y las traslaciones a las coordenadas X
    EscalaYTrasladaVector(poli->x,poli->nElem,1,escalaX,trasladaX);
#if defined(_OPENMP)
#pragma omp section
#endif
    //aplicamos los factores de escala y las traslaciones a las coordenadas Y
    EscalaYTrasladaVector(poli->y,poli->nElem,1,escalaY,trasladaY);
} // --> fin del #pragma omp parallel sections
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ESTA PARTE NO LA PARALELIZAMOS, YA QUE SUPONEMOS QUE EL NÚMERO DE
    //POLÍGONOS EN UNA ESTRUCTURA SIEMPRE SERÁ MUCHÍSIMO MENOR QUE EL NÚMERO
    //TOTAL DE VÉRTICES
    //comprobamos si hay que aplicar el factor a los límites
    if(aplicaLim&&poli->hayLim)
    {
        //aplicamos los factores de escala y las traslaciones a los límites
        EscalaYTrasladaVector(poli->xMin,poli->nPolig,1,escalaX,trasladaX);
        EscalaYTrasladaVector(poli->xMax,poli->nPolig,1,escalaX,trasladaX);
        EscalaYTrasladaVector(poli->yMin,poli->nPolig,1,escalaY,trasladaY);
        EscalaYTrasladaVector(poli->yMax,poli->nPolig,1,escalaY,trasladaY);
    }
    //comprobamos si hay que aplicar el factor a las superficies
    if(aplicaArea&&poli->hayArea)
    {
        //aplicamos el factor de escala a las áreas
        EscalaYTrasladaVector(poli->area,poli->nPolig,1,fabs(escalaX*escalaY),
                              0.0);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void TrasladaYEscalaPolig(polig* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim,
                          const int aplicaArea)
{
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(poli)
#endif
{
#if defined(_OPENMP)
#pragma omp section
#endif
    //aplicamos las traslaciones y los factores de escala a las coordenadas X
    TrasladaYEscalaVector(poli->x,poli->nElem,1,escalaX,trasladaX);
#if defined(_OPENMP)
#pragma omp section
#endif
    //aplicamos las traslaciones y los factores de escala a las coordenadas Y
    TrasladaYEscalaVector(poli->y,poli->nElem,1,escalaY,trasladaY);
} // --> fin del #pragma omp parallel sections
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ESTA PARTE NO LA PARALELIZAMOS, YA QUE SUPONEMOS QUE EL NÚMERO DE
    //POLÍGONOS EN UNA ESTRUCTURA SIEMPRE SERÁ MUCHÍSIMO MENOR QUE EL NÚMERO
    //TOTAL DE VÉRTICES
    //comprobamos si hay que aplicar el factor a los límites
    if(aplicaLim&&poli->hayLim)
    {
        //aplicamos las traslaciones y los factores de escala a los límites
        TrasladaYEscalaVector(poli->xMin,poli->nPolig,1,escalaX,trasladaX);
        TrasladaYEscalaVector(poli->xMax,poli->nPolig,1,escalaX,trasladaX);
        TrasladaYEscalaVector(poli->yMin,poli->nPolig,1,escalaY,trasladaY);
        TrasladaYEscalaVector(poli->yMax,poli->nPolig,1,escalaY,trasladaY);
    }
    //comprobamos si hay que aplicar el factor a las superficies
    if(aplicaArea&&poli->hayArea)
    {
        //aplicamos el factor de escala a las áreas
        TrasladaYEscalaVector(poli->area,poli->nPolig,1,fabs(escalaX*escalaY),
                              0.0);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void MuevePolig(polig* poli,
                const double escalaX,
                const double escalaY,
                const double trasladaX,
                const double trasladaY,
                const int orden,
                const int aplicaLim,
                const int aplicaArea)
{
    //comprobamos el orden de aplicación de los factores
    if(orden==0)
    {
        //primero los factores de escala y luego las traslaciones
        EscalaYTrasladaPolig(poli,escalaX,escalaY,trasladaX,trasladaY,aplicaLim,
                             aplicaArea);
    }
    else
    {
        //primero las traslaciones y luego los factores de escala
        TrasladaYEscalaPolig(poli,escalaX,escalaY,trasladaX,trasladaY,aplicaLim,
                             aplicaArea);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int AligeraPolig(polig* poli,
                 const double tol,
                 const enum GEOC_DPEUCKER_ROBUSTO robusto,
                 const size_t nPtosRobusto,
                 const size_t nSegRobusto)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //posición inicial del polígono de trabajo y número de puntos del aligerado
    size_t posIni=0,nPtos=0;
    //puntos colineales
    int colin=0;
    //coordenadas de los polígonos aligerados
    double* x=NULL;
    double* y=NULL;
    //estructura auxiliar
    polig* aux=NULL;
    //vector de posiciones después del aligerado
    size_t* pos=NULL;
    //variable de salida
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos una posible salida rápida
    if(poli->nPolig==0)
    {
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar vacía
    aux = IniciaPoligVacio();
    //comprobamos los posibles errores
    if(aux==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return GEOC_ERR_ASIG_MEMORIA;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos el número de polígonos almacenados
    for(i=0;i<poli->nPolig;i++)
    {
        //extraemos la posición inicial del polígono de trabajo
        posIni = poli->posIni[i];
        //aligeramos el polígono de trabajo
        pos = AligeraPolilinea(&(poli->x[posIni]),&(poli->y[posIni]),
                               poli->nVert[i],1,1,tol,robusto,nPtosRobusto,
                               nSegRobusto,&nPtos);
        //comprobamos posibles errores
        if(pos==NULL)
        {
            //liberamos la memoria asignada
            LibMemPolig(aux);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return GEOC_ERR_ASIG_MEMORIA;
        }
        //comprobamos si el polígono se ha quedado en tres puntos
        if(nPtos==3)
        {
            //comprobamos si los tres puntos son colineales
            colin = TresPuntosColineales2D(poli->x[posIni+pos[0]],
                                           poli->y[posIni+pos[0]],
                                           poli->x[posIni+pos[1]],
                                           poli->y[posIni+pos[1]],
                                           poli->x[posIni+pos[2]],
                                           poli->y[posIni+pos[2]]);
        }
        //comprobamos si después del aligerado queda algún polígono
        if((nPtos>3)||((nPtos==3)&&(!colin)))
        {
            //asignamos memoria para los vectores de coordenadas del polígono
            //aligerado
            x = (double*)malloc(nPtos*sizeof(double));
            y = (double*)malloc(nPtos*sizeof(double));
            //comprobamos posibles errores
            if((x==NULL)||(y==NULL))
            {
                //liberamos la memoria asignada
                LibMemPolig(aux);
                free(pos);
                free(x);
                free(y);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return GEOC_ERR_ASIG_MEMORIA;
            }
            //recorremos el número de puntos del polígono aligerado
            for(j=0;j<nPtos;j++)
            {
                //copiamos las coordenadas
                x[j] = poli->x[posIni+pos[j]];
                y[j] = poli->y[posIni+pos[j]];
            }
            //añadimos las coordenadas al polígono aligerado
            estado = AnyadeDatosPolig(aux,x,y,nPtos,1,1);
            //sólo puede haber ocurrido un error de asignación de memoria, ya
            //que suponemos que el polígono de entrada es correcto
            if(estado!=GEOC_ERR_NO_ERROR)
            {
                //liberamos la memoria asignada
                LibMemPolig(aux);
                free(pos);
                free(x);
                free(y);
                //escribimos el mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return GEOC_ERR_ASIG_MEMORIA;
            }
            //liberamos la memoria asignada a los vectores de coordenadas
            free(x);
            free(y);
        }
        //liberamos la memoria asignada al vector de posiciones del aligerado
        free(pos);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay que calcular límites
    if(poli->hayLim)
    {
        //calculamos los límites
        estado = CalcLimitesPolig(aux);
        //comprobamos los posibles errores
        if(estado!=GEOC_ERR_NO_ERROR)
        {
            //liberamos la memoria asignada
            LibMemPolig(aux);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return GEOC_ERR_ASIG_MEMORIA;
        }
    }
    //comprobamos si hay que calcular superficies
    if(poli->hayArea)
    {
        //calculamos las áreas
        estado = CalcAreaPolig(aux);
        //comprobamos los posibles errores
        if(estado!=GEOC_ERR_NO_ERROR)
        {
            //liberamos la memoria asignada
            LibMemPolig(aux);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return GEOC_ERR_ASIG_MEMORIA;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //enlazamos los campos de la estructura auxiliar a los de la estructura de
    //salida
    EnlazaCamposPolig(aux,poli);
    //liberamos la memoria asignada a la estructura auxiliar (pero no a sus
    //campos)
    free(aux);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
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
                                 FILE* idFich)
{
    //número de vértices del polígono de trabajo
    size_t nVert=0;
    //superficie de los polígonos
    double area=0.0;
    //límites
    double xMin=0.0,xMax=0.0,yMin=0.0,yMax=0.0,limAux=0.0;
    //variables de posición
    size_t pos=0,posXMin=0,posXMax=0,posYMin=0,posYMax=0;
    //variable auxiliar
    size_t aux=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ajustamos la variable auxiliar como el posible número a restar si no hay
    //que repetir el primer vértice del polígono
    aux = (repitePrimerPunto) ? 0 : 1;
    //número de vértices a imprimir del polígono
    nVert = poli->nVert[indice]-aux;
    //posición de inicio del polígono
    pos = poli->posIni[indice];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //imprimimos la marca de inicio y el número de vértices
    fprintf(idFich,"%s %8zu",iniCab,nVert);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay que imprimir la superficie
    if(impArea)
    {
        //comprobamos si ya está calculada la superficie o no
        if(poli->hayArea)
        {
            //aplicamos los factores de escala y extraemos la superficie
            area = poli->area[indice]*fabs(factorX)*fabs(factorY);
        }
        else
        {
            //calculamos la superficie
            area = AreaPoligonoSimple(&(poli->x[pos]),&(poli->y[pos]),
                                      poli->nVert[indice],1,1);
            //aplicamos los factores de escala
            area *= fabs(factorX)*fabs(factorY);
        }
        //imprimimos el valor de la superficie
        fprintf(idFich," ");
        fprintf(idFich,formArea,area);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay que imprimir los límites
    if(impLim)
    {
        //comprobamos si ya están calculados los límites
        if(poli->hayLim)
        {
            //extraemos los límites
            xMin = poli->xMin[indice];
            xMax = poli->xMax[indice];
            yMin = poli->yMin[indice];
            yMax = poli->yMax[indice];
        }
        else
        {
            //buscamos las posiciones de los elementos máximo y mínimo
            //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
shared(poli,pos,nVert,posXMin,posXMax,posYMin,posYMax)
#endif
{
            //posiciones en el vector X
#if defined(_OPENMP)
#pragma omp section
#endif
            MinMax(&(poli->x[pos]),nVert,1,&posXMin,&posXMax);
            //posiciones en el vector Y
#if defined(_OPENMP)
#pragma omp section
#endif
            MinMax(&(poli->y[pos]),nVert,1,&posYMin,&posYMax);
} // --> fin del #pragma omp parallel sections
            //extraemos los valores extremos
            xMin = poli->x[pos+posXMin];
            xMax = poli->x[pos+posXMax];
            yMin = poli->y[pos+posYMin];
            yMax = poli->y[pos+posYMax];
        }
        //comprobamos si el factor de escala para X es negativo
        if(factorX<0.0)
        {
            //los límites cambian
            limAux = xMin;
            xMin = xMax;
            xMax = limAux;
            //aplicamos el factor de escala
            xMin *= factorX;
            xMax *= factorX;
        }
        //comprobamos si el factor de escala para Y es negativo
        if(factorY<0.0)
        {
            //los límites cambian
            limAux = yMin;
            yMin = yMax;
            yMax = limAux;
            //aplicamos el factor de escala
            yMin *= factorY;
            yMax *= factorY;
        }
        //imprimimos los límites
        fprintf(idFich," ");
        fprintf(idFich,formCoor,xMin);
        fprintf(idFich," ");
        fprintf(idFich,formCoor,xMax);
        fprintf(idFich," ");
        fprintf(idFich,formCoor,yMin);
        fprintf(idFich," ");
        fprintf(idFich,formCoor,yMax);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salto de línea final
    fprintf(idFich,"\n");
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
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
                         FILE* idFich)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //cadena de formato para imprimir los posibles valores NaN
    char formNan[GEOC_NAN_LON_FORM_NUM_SIMPLE+1];
    //variable de posición
    size_t pos=0;
    //variable auxiliar
    size_t aux=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si la estructura contiene algún polígono
    if(poli->nPolig==0)
    {
        //salimos sin imprimir nada
        return;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //creamos la cadena de formato para imprimir los polibles NaN
    FormatoNumFormatoTexto(formCoor,formNan);
    //ajustamos la variable auxiliar como el posible número a restar si no hay
    //que repetir el primer vértice de los polígonos
    aux = (repitePrimerPunto) ? 0 : 1;
    //comprobamos si hay que imprimir la marca separadora al principio
    if(iniNan)
    {
        //la imprimimos
        ImprimeGeocNanTexto(idFich,2,formNan,1);
    }
    //recorremos el número de polígonos
    for(i=0;i<poli->nPolig;i++)
    {
        //comprobamos si hay que imprimir la cabecera
        if(impCabecera)
        {
            //imprimos la cabecera
            ImprimeCabeceraPoligFichero(poli,i,iniCab,impLim,formCoor,impArea,
                                        formArea,factorX,factorY,
                                        repitePrimerPunto,idFich);
        }
        //posición del punto inicial del polígono
        pos = poli->posIni[i];
        //recorremos el número de vértices del polígono de trabajo
        for(j=0;j<(poli->nVert[i]-aux);j++)
        {
            //imprimimos las coordenadas, multiplicadas por los factores
            fprintf(idFich,formCoor,factorX*poli->x[pos+j]);
            fprintf(idFich,formCoor,factorY*poli->y[pos+j]);
            fprintf(idFich,"\n");
        }
        //imprimimos la marca separadora al final (menos para el último)
        if(i!=(poli->nPolig-1))
        {
            ImprimeGeocNanTexto(idFich,2,formNan,1);
        }
    }
    //comprobamos si hay que imprimir la marca separadora al final
    if(finNan)
    {
        //la imprimimos
        ImprimeGeocNanTexto(idFich,2,formNan,1);
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

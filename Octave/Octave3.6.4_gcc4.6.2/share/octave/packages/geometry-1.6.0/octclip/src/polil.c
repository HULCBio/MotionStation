/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file polil.c
\brief Definición de funciones para el trabajo con polilíneas.
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
#include"libgeoc/polil.h"
/******************************************************************************/
/******************************************************************************/
int GeocParOmpPolil(char version[])
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
polil* IniciaPolilVacia(void)
{
    //estructura de salida
    polil* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para la estructura
    sal = (polil*)malloc(sizeof(polil));
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
    sal->nPolil = 0;
    sal->hayLim = 0;
    //inicializamos los campos vectoriales a NULL
    sal->x = NULL;
    sal->y = NULL;
    sal->posIni = NULL;
    sal->nVert = NULL;
    sal->xMin = NULL;
    sal->xMax = NULL;
    sal->yMin = NULL;
    sal->yMax = NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
int AuxCreaPolil1(const size_t nElem,
                  const size_t* posNanX,
                  const size_t* posNanY,
                  const size_t nNanX,
                  const size_t nNanY,
                  size_t* nElemMax,
                  size_t* nPolil)
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
        return GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL;
    }
    //comprobamos si hay NaN en las mismas posiciones de los vectores
    for(i=0;i<nNanX;i++)
    {
        //comprobamos si las posiciones no son las mismas
        if(posNanX[i]!=posNanY[i])
        {
            //salimos de la función
            return GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos un número máximo de elementos de los vectores de coordenadas
    //inicializamos con el número de elementos pasados
    *nElemMax = nElem;
    //comprobamos si en la primera posición hay NaN o si no hay ninguno
    if((nNanX==0)||(nNanX&&(posNanX[0]!=0)))
    {
        //hace falta un elemento para el primer NaN
        (*nElemMax)++;
    }
    //comprobamos si en la última posición hay NaN o si no hay ninguno
    if((nNanX==0)||(nNanX&&(posNanX[nNanX-1]!=(nElem-1))))
    {
        //hace falta un elemento para el último NaN
        (*nElemMax)++;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número de polilíneas, dependiendo del número de NaN
    if((nNanX==0)||
       ((nNanX==1)&&(posNanX[0]==0))||
       ((nNanX==1)&&(posNanX[nNanX-1]==(nElem-1)))||
       ((nNanX==2)&&(posNanX[0]==0)&&(posNanX[nNanX-1]==(nElem-1))))
    {
        //sólo hay un polígono
        *nPolil = 1;
    }
    else if((posNanX[0]!=0)&&(posNanX[nNanX-1]!=(nElem-1)))
    {
        //si no hay NaN en los extremos, el número de polilíneas es nNan+1
        *nPolil = nNanX+1;
    }
    else if((posNanX[0]==0)&&(posNanX[nNanX-1]==(nElem-1)))
    {
        //si hay NaN en los dos extremos, el número de polilíneas es nNan-1
        *nPolil = nNanX-1;
    }
    else
    {
        //en otro caso, es el número de NaN
        *nPolil = nNanX;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
void AuxCreaPolil2(const double* x,
                   const double* y,
                   const size_t nElem,
                   const size_t incX,
                   const size_t incY,
                   double* xSal,
                   double* ySal)
{
    //índice para recorrer bucles
    size_t i=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
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
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
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
                   size_t* nPolil)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de vértices de la polilínea a copiar
    size_t nV=0;
    //posición inicial de una polilínea
    size_t pI=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos las variables de número de puntos copiados y número de
    //polilíneas
    *nPtos = 0;
    *nPolil = 0;
    //comprobamos si los vectores empiezan directamente con coordenadas
    if((nNan==0)||(posNan[0]!=0))
    {
        //el primer elemento de los vectores de salida es NaN
        xSal[0] = GeocNan();
        ySal[0] = GeocNan();
        //aumentamos la variable de número de puntos copiados
        (*nPtos)++;
        //calculamos el número de vértices de la polilínea
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
        //copiamos la primera polilínea
        AuxCreaPolil2(&x[0],&y[0],nV,incX,incY,&xSal[*nPtos],&ySal[*nPtos]);
        //indicamos la posición de inicio del polígono y el número de vértices
        posIni[*nPolil] = 1;
        nVert[*nPolil] = nV;
        //sumamos el número de puntos copiados a la variable
        (*nPtos) += nV;
        //aumentamos el contador de polilíneas
        (*nPolil)++;
    }
    //recorremos el número de NaN
    for(i=0;i<nNan;i++)
    {
        //copiamos el NaN
        xSal[*nPtos] = GeocNan();
        ySal[*nPtos] = GeocNan();
        //aumentamos la variable de número de puntos copiados
        (*nPtos)++;
        //posición del primer punto de la polilínea
        pI = posNan[i]+1;
        //sólo continuamos si el NaN no es la última posición de los vectores
        if(pI!=nElem)
        {
            //calculo el número de puntos de la polilínea, dependiendo del NaN
            //de trabajo
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
            //copiamos las coordenadas de la polilínea
            AuxCreaPolil2(&x[pI*incX],&y[pI*incY],nV,incX,incY,&xSal[*nPtos],
                          &ySal[*nPtos]);
            //comprobamos el número de puntos copiados
            if(nV)
            {
                //indicamos la posición de inicio de la polilínea y el número de
                //vértices
                posIni[*nPolil] = *nPtos;
                nVert[*nPolil] = nV;
                //sumamos el número de puntos copiados a la variable
                (*nPtos) += nV;
                //aumentamos el contador de polilíneas
                (*nPolil)++;
            }
            else
            {
                //si no se han copiado puntos, la polilínea era falsa (había dos
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
polil* CreaPolil(const double* x,
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
    //número de polilíneas
    size_t nPolil=0;
    //número de identificadores NaN
    size_t nNanX=0,nNanY=0;
    //posiciones de los identificadores NaN
    size_t* posNanX=NULL;
    size_t* posNanY=NULL;
    //estructura de salida
    polil* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la variable de error
    *idError = GEOC_ERR_NO_ERROR;
    //creamos la estructura vacía
    sal = IniciaPolilVacia();
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
        LibMemPolil(sal);
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
    //número de polilíneas
    *idError = AuxCreaPolil1(nElem,posNanX,posNanY,nNanX,nNanY,&nElemMax,
                             &nPolil);
    //comprobamos los posibles errores
    if(*idError!=GEOC_ERR_NO_ERROR)
    {
        //liberamos la memoria asignada
        LibMemPolil(sal);
        free(posNanX);
        free(posNanY);
        //escribimos el mensaje de error
        if(*idError==GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen el mismo "
                       "número de polilíneas");
        }
        else if(*idError==GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen las mismas "
                       "polilíneas");
        }
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos el número de polilíneas
    sal->nPolil = nPolil;
    //paralelización con OpenMP
#if defined(_OPENMP)
#pragma omp parallel sections default(none) \
 shared(sal,nElemMax,nPolil)
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
    sal->posIni = (size_t*)malloc(nPolil*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    sal->nVert = (size_t*)malloc(nPolil*sizeof(double));
} // --> fin del #pragma omp parallel sections
    //comprobamos los posibles errores
    if((sal->x==NULL)||(sal->y==NULL)||(sal->posIni==NULL)||(sal->nVert==NULL))
    {
        //liberamos la memoria asignada
        LibMemPolil(sal);
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
    //copiamos las polilíneas a la estructura
    //como ya sabemos que el número de NaN y sus posiciones son los mismos para
    //los vectores x e y, trabajamos con los valores para el vector x
    AuxCreaPolil3(x,y,nElem,incX,incY,posNanX,nNanX,sal->x,sal->y,sal->posIni,
                  sal->nVert,&ptos,&nPolil);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay de verdad alguna polilínea
    if(nPolil==0)
    {
        //liberamos la memoria asignada
        LibMemPolil(sal);
        free(posNanX);
        free(posNanY);
        //creamos la estructura vacía
        sal = IniciaPolilVacia();
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
    //comprobamos si el número de polilíneas es el estimado
    if(nPolil!=sal->nPolil)
    {
        //asignamos de nuevo la variable de número de polilíneas
        sal->nPolil = nPolil;
        //reajustamos los tamaños
        sal->posIni = (size_t*)realloc(sal->posIni,nPolil*sizeof(size_t));
        sal->nVert = (size_t*)realloc(sal->nVert,nPolil*sizeof(size_t));
    }
    //comprobamos los posibles errores
    if((sal->x==NULL)||(sal->y==NULL)||(sal->posIni==NULL)||(sal->nVert==NULL))
    {
        //liberamos la memoria asignada
        LibMemPolil(sal);
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
void EnlazaCamposPolil(polil* poliEnt,
                       polil* poliSal)
{
    //LIBERAMOS LA POSIBLE MEMORIA ASIGNADA A LOS CAMPOS VECTORIALES DE LA
    //ESTRUCTURA DE SALIDA
    //comprobamos si hay algún elemento en los vectores de coordenadas
    if(poliSal->nElem)
    {
        free(poliSal->x);
        free(poliSal->y);
    }
    //comprobamos si hay alguna polilínea en los vectores de posiciones
    if(poliSal->nPolil)
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
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //enlazamos todos los campos de la estructura de entrada en la de salida
    poliSal->nElem = poliEnt->nElem;
    poliSal->x = poliEnt->x;
    poliSal->y = poliEnt->y;
    poliSal->nPolil = poliEnt->nPolil;
    poliSal->posIni = poliEnt->posIni;
    poliSal->nVert = poliEnt->nVert;
    poliSal->hayLim = poliEnt->hayLim;
    poliSal->xMin = poliEnt->xMin;
    poliSal->xMax = poliEnt->xMax;
    poliSal->yMin = poliEnt->yMin;
    poliSal->yMax = poliEnt->yMax;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
polil* CopiaPolil(const polil* poli,
                  int* idError)
{
    //polilínea de salida
    polil* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la variable de error
    *idError = GEOC_ERR_NO_ERROR;
    //inicializamos la polilínea de salida
    sal = IniciaPolilVacia();
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
    //sólo continuamos si la polilínea de entrada contiene datos
    if(poli->nElem)
    {
        //copiamos las coordenadas de los vértices
        *idError = AnyadeDatosPolil(sal,poli->x,poli->y,poli->nElem,1,1);
        //comprobamos si ha ocurrido algún error
        if((*idError)!=GEOC_ERR_NO_ERROR)
        {
            //liberamos la memoria asignada
            LibMemPolil(sal);
            //escribimos el mensaje de error
            if((*idError)==GEOC_ERR_ASIG_MEMORIA)
            {
                GEOC_ERROR("Error de asignación de memoria");
            }
            else if((*idError)==GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL)
            {
                GEOC_ERROR("Error: Los vectores de coordenadas de la\n"
                           "polilínea de entrada no contienen el mismo número "
                           "de polilíneas");
            }
            else if((*idError)==GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL)
            {
                GEOC_ERROR("Error: Los vectores de coordenadas de la\n"
                           "polilínea de entrada no contienen las mismas "
                           "polilíneas");
            }
            //salimos de la función
            return NULL;
        }
        //comprobamos si hay que calcular límites
        if(poli->hayLim)
        {
            //calculamos los límites
            *idError = CalcLimitesPolil(sal);
            //comprobamos los posibles errores
            if((*idError)!=GEOC_ERR_NO_ERROR)
            {
                //liberamos la memoria asignada
                LibMemPolil(sal);
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
int AnyadePolilPolil(polil* poli,
                     const polil* anyade)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de posición
    size_t pos=0;
    //número total de elementos
    size_t nElem=0,nPolil=0;
    //variable de estado (salida)
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //si la polilínea a añadir está vacía, salimos de la función
    if((anyade!=NULL)&&(anyade->nPolil==0))
    {
        //salimos de la función sin hacer nada
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número total de elementos de la polilínea conjunta
    nElem = poli->nElem+anyade->nElem;
    //si la polilínea original contenía datos, al número total de elementos hay
    //que restarle 1 por el NaN común que sobra al juntar las dos estructuras
    if(poli->nPolil)
    {
        nElem--;
    }
    //calculamos el número total de polilíneas
    nPolil = poli->nPolil+anyade->nPolil;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //reasignamos memoria para cubrir los nuevos datos
    poli->x = (double*)realloc(poli->x,nElem*sizeof(double));
    poli->y = (double*)realloc(poli->y,nElem*sizeof(double));
    poli->posIni = (size_t*)realloc(poli->posIni,nPolil*sizeof(size_t));
    poli->nVert = (size_t*)realloc(poli->nVert,nPolil*sizeof(size_t));
    //reasignamos también para los posibles vectores de límites
    if(poli->hayLim)
    {
        poli->xMin = (double*)realloc(poli->xMin,nPolil*sizeof(double));
        poli->xMax = (double*)realloc(poli->xMax,nPolil*sizeof(double));
        poli->yMin = (double*)realloc(poli->yMin,nPolil*sizeof(double));
        poli->yMax = (double*)realloc(poli->yMax,nPolil*sizeof(double));
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
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos la posición de inicio para copiar en la estructura de salida
    //si la estructura de salida está vacía, se comienza en la primera posición
    //si tiene datos, se comienza a continuación en la última (dentro del bucle,
    //la suma de posIni hace que se comience a continuación de la última)
    pos = (poli->nPolil==0) ? 0 : poli->nElem-1;
    //recorremos el número de nuevos elementos
    for(i=0;i<anyade->nElem;i++)
    {
        //copiamos las coordenadas
        poli->x[pos+i] = anyade->x[i];
        poli->y[pos+i] = anyade->y[i];
    }
    //calculamos las posiciones a sumar para ajustar las posiciones de inicio de
    //las polilíneas añadidas
    //si la estructura de salida está vacía, se copian las posiciones tal cual
    //si tiene datos, se suman las posiciones ya ocupadas
    pos = (poli->nPolil==0) ? 0 : poli->nElem-1;
    //recorremos el número de polilíneas
    for(i=0;i<anyade->nPolil;i++)
    {
        //copiamos las posiciones de inicio actualizadas y el número de vértices
        poli->posIni[poli->nPolil+i] = anyade->posIni[i]+pos;
        poli->nVert[poli->nPolil+i] = anyade->nVert[i];
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si hay que calcular límites
    if(poli->hayLim)
    {
        //comprobamos si ya están calculados
        if(anyade->hayLim)
        {
            //recorremos el número de polilíneas y copiamos los límites
            for(i=0;i<anyade->nPolil;i++)
            {
                //copiamos los límites
                poli->xMin[poli->nPolil+i] = anyade->xMin[i];
                poli->xMax[poli->nPolil+i] = anyade->xMax[i];
                poli->yMin[poli->nPolil+i] = anyade->yMin[i];
                poli->yMax[poli->nPolil+i] = anyade->yMax[i];
            }
        }
        else
        {
            //calculamos los límites y los copiamos
            LimitesPoligonosPolig(&(anyade->x[1]),&(anyade->y[1]),1,1,
                                  anyade->posIni,anyade->nVert,anyade->nPolil,
                                  anyade->posIni[0],&(poli->xMin[poli->nPolil]),
                                  &(poli->xMax[poli->nPolil]),
                                  &(poli->yMin[poli->nPolil]),
                                  &(poli->yMax[poli->nPolil]));
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //ajustamos los tamaños antes de salir
    poli->nElem = nElem;
    poli->nPolil = nPolil;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
int AnyadeDatosPolil(polil* poli,
                     const double* x,
                     const double* y,
                     const size_t nElem,
                     const size_t incX,
                     const size_t incY)
{
    //polilínea auxiliar
    polil* aux=NULL;
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
    //creamos una nueva polilínea con los datos a añadir
    aux = CreaPolil(x,y,nElem,incX,incY,&estado);
    //comprobamos los posibles errores
    if(estado!=GEOC_ERR_NO_ERROR)
    {
        //liberamos la memoria asignada
        LibMemPolil(aux);
        //escribimos el mensaje de error
        if(estado==GEOC_ERR_ASIG_MEMORIA)
        {
            GEOC_ERROR("Error de asignación de memoria");
        }
        else if(estado==GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen el mismo "
                       "número de polilíneas");
        }
        else if(estado==GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL)
        {
            GEOC_ERROR("Error: Los vectores de trabajo no contienen las mismas "
                       "polilíneas");
        }
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //añadimos la nueva estructura
    estado = AnyadePolilPolil(poli,aux);
    //comprobamos los posibles errores
    if(estado!=GEOC_ERR_NO_ERROR)
    {
        //liberamos la memoria asignada
        LibMemPolil(aux);
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //liberamos la memoria utilizada
    LibMemPolil(aux);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
void LibMemPolil(polil* datos)
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
int CalcLimitesPolil(polil* poli)
{
    //variable de estado (salida)
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos salida rápida
    if((poli->nPolil==0)||(poli->hayLim))
    {
        //salimos de la función si la estructura no contiene polilíneas o si
        //éstas ya tienen calculados sus límites
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
    poli->xMin = (double*)malloc((poli->nPolil)*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->xMax = (double*)malloc((poli->nPolil)*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->yMin = (double*)malloc((poli->nPolil)*sizeof(double));
#if defined(_OPENMP)
#pragma omp section
#endif
    poli->yMax = (double*)malloc((poli->nPolil)*sizeof(double));
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
    //calculamos los límites de todas las polilíneas
    LimitesPoligonosPolig(poli->x,poli->y,1,1,poli->posIni,poli->nVert,
                          poli->nPolil,0,poli->xMin,poli->xMax,poli->yMin,
                          poli->yMax);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return estado;
}
/******************************************************************************/
/******************************************************************************/
void EscalaYTrasladaPolil(polil* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim)
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
        EscalaYTrasladaVector(poli->xMin,poli->nPolil,1,escalaX,trasladaX);
        EscalaYTrasladaVector(poli->xMax,poli->nPolil,1,escalaX,trasladaX);
        EscalaYTrasladaVector(poli->yMin,poli->nPolil,1,escalaY,trasladaY);
        EscalaYTrasladaVector(poli->yMax,poli->nPolil,1,escalaY,trasladaY);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void TrasladaYEscalaPolil(polil* poli,
                          const double escalaX,
                          const double escalaY,
                          const double trasladaX,
                          const double trasladaY,
                          const int aplicaLim)
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
        TrasladaYEscalaVector(poli->xMin,poli->nPolil,1,escalaX,trasladaX);
        TrasladaYEscalaVector(poli->xMax,poli->nPolil,1,escalaX,trasladaX);
        TrasladaYEscalaVector(poli->yMin,poli->nPolil,1,escalaY,trasladaY);
        TrasladaYEscalaVector(poli->yMax,poli->nPolil,1,escalaY,trasladaY);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void MuevePolil(polil* poli,
                const double escalaX,
                const double escalaY,
                const double trasladaX,
                const double trasladaY,
                const int orden,
                const int aplicaLim)
{
    //comprobamos el orden de aplicación de los factores
    if(orden==0)
    {
        //primero los factores de escala y luego las traslaciones
        EscalaYTrasladaPolil(poli,escalaX,escalaY,trasladaX,trasladaY,
                             aplicaLim);
    }
    else
    {
        //primero las traslaciones y luego los factores de escala
        TrasladaYEscalaPolil(poli,escalaX,escalaY,trasladaX,trasladaY,
                             aplicaLim);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int AligeraPolil(polil* poli,
                 const double tol,
                 const enum GEOC_DPEUCKER_ROBUSTO robusto,
                 const size_t nPtosRobusto,
                 const size_t nSegRobusto)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //posición inicial de la polilínea de trabajo y número de puntos aligerados
    size_t posIni=0,nPtos=0;
    //polilínea que es un mismo punto
    int pmp=0;
    //coordenadas de las polilíneas aligeradas
    double* x=NULL;
    double* y=NULL;
    //estructura auxiliar
    polil* aux=NULL;
    //vector de posiciones después del aligerado
    size_t* pos=NULL;
    //variable de salida
    int estado=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos una posible salida rápida
    if(poli->nPolil==0)
    {
        //salimos de la función
        return estado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar vacía
    aux = IniciaPolilVacia();
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
    //recorremos el número de polilíneas almacenadas
    for(i=0;i<poli->nPolil;i++)
    {
        //extraemos la posición inicial de la polilínea de trabajo
        posIni = poli->posIni[i];
        //aligeramos la polilínea de trabajo
        pos = AligeraPolilinea(&(poli->x[posIni]),&(poli->y[posIni]),
                               poli->nVert[i],1,1,tol,robusto,nPtosRobusto,
                               nSegRobusto,&nPtos);
        //comprobamos posibles errores
        if(pos==NULL)
        {
            //liberamos la memoria asignada
            LibMemPolil(aux);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return GEOC_ERR_ASIG_MEMORIA;
        }
        //comprobamos si la polilínea se ha quedado en dos puntos
        if(nPtos==2)
        {
            //comprobamos si los tres puntos son colineales
            pmp = ((poli->x[posIni+pos[0]])==(poli->x[posIni+pos[1]]))&&
                  ((poli->y[posIni+pos[0]])==(poli->y[posIni+pos[1]]));
        }
        //comprobamos si después del aligerado todavía queda una polilínea que
        //no sea un único punto
        if((nPtos>2)||((nPtos==2)&&(!pmp)))
        {
            //asignamos memoria para los vectores de coordenadas de la polilínea
            //aligerada
            x = (double*)malloc(nPtos*sizeof(double));
            y = (double*)malloc(nPtos*sizeof(double));
            //comprobamos posibles errores
            if((x==NULL)||(y==NULL))
            {
                //liberamos la memoria asignada
                LibMemPolil(aux);
                free(pos);
                free(x);
                free(y);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return GEOC_ERR_ASIG_MEMORIA;
            }
            //recorremos el número de puntos de la polilínea aligerada
            for(j=0;j<nPtos;j++)
            {
                //copiamos las coordenadas
                x[j] = poli->x[posIni+pos[j]];
                y[j] = poli->y[posIni+pos[j]];
            }
            //añadimos las coordenadas a la polilínea aligerada
            estado = AnyadeDatosPolil(aux,x,y,nPtos,1,1);
            //sólo puede haber ocurrido un error de asignación de memoria, ya
            //que suponemos que la polilínea de entrada es correcta
            if(estado!=GEOC_ERR_NO_ERROR)
            {
                //liberamos la memoria asignada
                LibMemPolil(aux);
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
        estado = CalcLimitesPolil(aux);
        //comprobamos los posibles errores
        if(estado!=GEOC_ERR_NO_ERROR)
        {
            //liberamos la memoria asignada
            LibMemPolil(aux);
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
    EnlazaCamposPolil(aux,poli);
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
void ImprimeCabeceraPolilFichero(const polil* poli,
                                 const size_t indice,
                                 const char iniCab[],
                                 const int impLim,
                                 const char formCoor[],
                                 const double factorX,
                                 const double factorY,
                                 FILE* idFich)
{
    //número de vértices de la polilínea de trabajo
    size_t nVert=0;
    //límites
    double xMin=0.0,xMax=0.0,yMin=0.0,yMax=0.0,limAux=0.0;
    //variables de posición
    size_t pos=0,posXMin=0,posXMax=0,posYMin=0,posYMax=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //número de vértices a imprimir de la polilínea
    nVert = poli->nVert[indice];
    //posición de inicio de la polilínea
    pos = poli->posIni[indice];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //imprimimos la marca de inicio y el número de vértices
    fprintf(idFich,"%s %8zu",iniCab,nVert);
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
void ImprimePolilFichero(const polil* poli,
                         const double factorX,
                         const double factorY,
                         const int iniNan,
                         const int finNan,
                         const char formCoor[],
                         const int impCabecera,
                         const char iniCab[],
                         const int impLim,
                         FILE* idFich)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //cadena de formato para imprimir los posibles valores NaN
    char formNan[GEOC_NAN_LON_FORM_NUM_SIMPLE+1];
    //variable de posición
    size_t pos=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si la estructura contiene alguna polilínea
    if(poli->nPolil==0)
    {
        //salimos sin imprimir nada
        return;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //creamos la cadena de formato para imprimir los polibles NaN
    FormatoNumFormatoTexto(formCoor,formNan);
    //comprobamos si hay que imprimir la marca separadora al principio
    if(iniNan)
    {
        //la imprimimos
        ImprimeGeocNanTexto(idFich,2,formNan,1);
    }
    //recorremos el número de polilíneas
    for(i=0;i<poli->nPolil;i++)
    {
        //comprobamos si hay que imprimir la cabecera
        if(impCabecera)
        {
            //imprimos la cabecera
            ImprimeCabeceraPolilFichero(poli,i,iniCab,impLim,formCoor,factorX,
                                        factorY,idFich);
        }
        //posición del punto inicial de la polilínea
        pos = poli->posIni[i];
        //recorremos el número de vértices de la polilínea de trabajo
        for(j=0;j<poli->nVert[i];j++)
        {
            //imprimimos las coordenadas, multiplicadas por factor
            fprintf(idFich,formCoor,factorX*poli->x[pos+j]);
            fprintf(idFich,formCoor,factorY*poli->y[pos+j]);
            fprintf(idFich,"\n");
        }
        //imprimimos la marca separadora al final (menos para el último)
        if(i!=(poli->nPolil-1))
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

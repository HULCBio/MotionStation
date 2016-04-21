/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file dpeucker.c
\brief Definición de funciones para el aligerado de polilíneas basadas en el
       algoritmo de Douglas-Peucker.
\author José Luis García Pallero, jgpallero@gmail.com
\date 04 de julio de 2011
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
#include"libgeoc/dpeucker.h"
/******************************************************************************/
/******************************************************************************/
size_t* AligeraPolilinea(const double* x,
                         const double* y,
                         const size_t nPtos,
                         const size_t incX,
                         const size_t incY,
                         const double tol,
                         const enum GEOC_DPEUCKER_ROBUSTO robusto,
                         const size_t nPtosRobusto,
                         const size_t nSegRobusto,
                         size_t* nPtosSal)
{
    //índice para recorrer bucles
    size_t p=0;
    //índice de los puntos de trabajo
    size_t i=0,j=0,k=0;
    //coordenadas de trabajo
    double xIni=0.0,yIni=0.0,xFin=0.0,yFin=0.0,xTrab=0.0,yTrab=0.0;
    //altura del triángulo de trabajo
    double h=0.0;
    //variable indicadora de punto a mantener
    int usado=0;
    //número de elementos de trabajo internos del vector de salida
    size_t nElem=0;
    //vector de salida
    size_t* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //iniciamos la variable de salida de número de puntos a 0
    *nPtosSal = 0;
    //comprobamos casos especiales de nPtos
    if(nPtos==0)
    {
        //salimos de la función con NULL
        return NULL;
    }
    else if(nPtos<=2)
    {
        //asignamos el número de puntos usados
        *nPtosSal = nPtos;
        //asignamos memoria para el vector de salida
        sal = (size_t*)malloc((*nPtosSal)*sizeof(size_t));
        //comprobamos los posibles errores
        if(sal==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //asignamos valores al vector de salida
        for(i=0;i<(*nPtosSal);i++)
        {
            //asignamos el índice de trabajo
            sal[i] = i;
        }
        //salimos de la función
        return sal;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el indicador interno de tamaño del vector
    nElem = GEOC_DPEUCKER_BUFFER_PTOS;
    //asignamos memoria para el vector de salida
    sal = (size_t*)malloc(nElem*sizeof(size_t));
    //comprobamos los posibles errores
    if(sal==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //indicamos que el primer punto siempre se usa
    *nPtosSal = 1;
    sal[0] = 0;
    //puntos de trabajo para iniciar los cálculos
    i = 0;
    j = 1;
    k = 2;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //entramos en un bucle infinito
    while(1)
    {
        //comprobamos si hay que salir del bucle
        if(k>(nPtos-1))
        {
            //salimos del bucle
            break;
        }
        //coordenadas de la base del triángulo
        xIni = x[i*incX];
        yIni = y[i*incY];
        xFin = x[k*incX];
        yFin = y[k*incY];
        //inicializamos a 0 la variable de punto usado
        usado = 0;
        //recorremos los puntos a testear
        for(p=j;p<k;p++)
        {
            //coordenadas del vértice del triángulo
            xTrab = x[p*incX];
            yTrab = y[p*incY];
            //calculamos la altura del triángulo
            h = AlturaTriangulo(xTrab,yTrab,xIni,yIni,xFin,yFin);
            //comprobamos si la altura supera a la tolerancia
            if(h>tol)
            {
                //indicamos que el punto ha sido usado
                usado = 1;
                //comprobamos si se utiliza el algoritmo robusto
                if(robusto!=GeocDPeuckerRobNo)
                {
                    //comprobamos si hay que aplicar el algoritmo de
                    //intersección con puntos originales
                    if((robusto==GeocDPeuckerRobSi)||
                       (robusto==GeocDPeuckerRobOrig))
                    {
                        //aplicamos el algoritmo
                        AligPolilRobIntersecOrig(x,y,nPtos,incX,incY,
                                                 nPtosRobusto,i,&p);
                    }
                    //comprobamos si hay que aplicar el algoritmo de auto
                    //intersección
                    if((robusto==GeocDPeuckerRobSi)||
                       (robusto==GeocDPeuckerRobAuto))
                    {
                        //indicamos un número de puntos para el vector de salida
                        //una unidad menor que el número realmente almacenado
                        //para evitar el segmento inmediatamente anterior al que
                        //vamos a crear
                        AligPolilRobAutoIntersec(x,y,incX,incY,sal,
                                                 (*nPtosSal)-1,nSegRobusto,i,
                                                 &p);
                    }
                }
                //añadimos al contador este nuevo punto
                (*nPtosSal)++;
                //comprobamos si hay que reasignar memoria
                if((*nPtosSal)>nElem)
                {
                    //añadimos otro grupo de puntos
                    nElem += GEOC_DPEUCKER_BUFFER_PTOS;
                    //asignamos memoria para el vector de salida
                    sal = (size_t*)realloc(sal,nElem*sizeof(size_t));
                    //comprobamos los posibles errores
                    if(sal==NULL)
                    {
                        //mensaje de error
                        GEOC_ERROR("Error de asignación de memoria");
                        //salimos de la función
                        return NULL;
                    }
                }
                //añadimos el nuevo punto usado
                sal[(*nPtosSal)-1] = p;
                //actualizamos los índices de los puntos de trabajo
                i = p;
                j = i+1;
                k = j+1;
                //salimos del bucle
                break;
            }
        }
        //comprobamos si no se ha utilizado ninguno de los vértices candidatos
        if(!usado)
        {
            //pasamos al siguiente punto como extremo del segmento
            k++;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el último punto se ha añadido
    if(sal[(*nPtosSal)-1]!=(nPtos-1))
    {
        //añadimos al contador el último punto
        (*nPtosSal)++;
        //comprobamos si hay que reasignar memoria
        if((*nPtosSal)>nElem)
        {
            //añadimos otro grupo de puntos
            nElem += GEOC_DPEUCKER_BUFFER_PTOS;
            //asignamos memoria para el vector de salida
            sal = (size_t*)realloc(sal,nElem*sizeof(size_t));
            //comprobamos los posibles errores
            if(sal==NULL)
            {
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
        }
        //asignamos el último punto
        sal[(*nPtosSal)-1] = nPtos-1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el vector de salida tiene demasiada memoria asignada
    if(nElem>(*nPtosSal))
    {
        //ajustamos el tamaño del vector de salida
        sal = (size_t*)realloc(sal,(*nPtosSal)*sizeof(size_t));
        //comprobamos los posibles errores
        if(sal==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
void AligPolilRobIntersecOrig(const double* x,
                              const double* y,
                              const size_t nPtos,
                              const size_t incX,
                              const size_t incY,
                              const size_t ptosAUsar,
                              const size_t posIni,
                              size_t* posFin)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //coordenadas de trabajo
    double xA=0.0,yA=0.0,xB=0.0,yB=0.0,xC=0.0,yC=0.0,xD=0.0,yD=0.0;
    //punto de parada para comprobar la intersección de segmentos
    size_t parada=0;
    //identificador de intersección
    int inter=0;
    //variables auxiliares
    size_t aux=0;
    double xAux=0.0,yAux=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contemplamos una posible salida rápida
    if((*posFin)<=(posIni+1))
    {
        //salimos de la función
        return;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número de puntos que quedan hasta el final de los vectores
    //de coordenadas desde la posición de fin de segmento (contándola)
    aux = nPtos-(*posFin);
    //calculamos el punto de parada para la intersección de segmentos
    if((aux>ptosAUsar)&&(ptosAUsar!=0))
    {
        //paramos en un pnto tal que usemos ptosAUsar puntos
        parada = *posFin+ptosAUsar-1;
    }
    else
    {
        //paramos en el penúltimo punto
        parada = nPtos-2;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //las coordenadas del punto inicial del segmento base no cambian nunca
    xA = x[posIni*incX];
    yA = y[posIni*incY];
    //recorremos los puntos candidatos hasta el anterior al punto base
    for(i=(*posFin);i>posIni;i--)
    {
        //comprobamos si estamos ante el punto posterior al inicial
        if(i==(posIni+1))
        {
            //terminamos, porque este punto es el siguiente al punto base en el
            //listado original
            *posFin = i;
            //salimos del bucle
            break;
        }
        else
        {
            //coordenadas de los puntos inicial y final del segmento base
            xB = x[i*incX];
            yB = y[i*incY];
            //recorremos los puntos posteriores hasta el de parada
            for(j=i;j<=parada;j++)
            {
                //coordenadas de los puntos inicial y final del siguiente
                //segmento
                xC = x[j*incX];
                yC = y[j*incY];
                xD = x[(j+1)*incX];
                yD = y[(j+1)*incY];
                //calculamos la intersección entre los segmentos
                inter = IntersecSegmentos2D(xA,yA,xB,yB,xC,yC,xD,yD,&xAux,
                                            &yAux);
                //comprobamos si hay intersección entre los segmentos
                if(inter!=GEOC_SEG_NO_INTERSEC)
                {
                    //salimos del bucle
                    break;
                }
            }
            //comprobamos si no ha habido ninguna intersección
            if(inter==GEOC_SEG_NO_INTERSEC)
            {
                //indicamos el índice del vértice final
                *posFin = i;
                //salimos del bucle
                break;
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void AligPolilRobAutoIntersec(const double* x,
                              const double* y,
                              const size_t incX,
                              const size_t incY,
                              const size_t* posAlig,
                              const size_t nPosAlig,
                              const size_t segAUsar,
                              const size_t posIni,
                              size_t* posFin)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //variables de posición
    size_t k=0,l=0,pos=0;
    //coordenadas de trabajo
    double xA=0.0,yA=0.0,xB=0.0,yB=0.0,xC=0.0,yC=0.0,xD=0.0,yD=0.0;
    //número de segmentos calculados hasta ahora, excepto el último
    size_t nSeg=0;
    //identificador de intersección
    int inter=0;
    //variables auxiliares
    double xAux=0.0,yAux=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contemplamos una posible salida rápida
    if(((*posFin)<=(posIni+1))||(nPosAlig<2))
    {
        //salimos de la función
        return;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número de segmentos calculados hasta ahora, excepto el
    //anterior al de trabajo
    nSeg = nPosAlig-1;
    //comprobamos si se usan todos los segmentos o sólo parte
    if(segAUsar!=0)
    {
        //asignamos el número de segmentos a utilizar
        nSeg = (nSeg>segAUsar) ? segAUsar : nSeg;
    }
    //las coordenadas del punto inicial del segmento base no cambian nunca
    xA = x[posIni*incX];
    yA = y[posIni*incY];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los puntos candidatos hasta el anterior al punto base
    for(i=(*posFin);i>posIni;i--)
    {
        //comprobamos si estamos ante el punto posterior al inicial
        if(i==(posIni+1))
        {
            //terminamos, porque este punto es el siguiente al punto inicial
            *posFin = i;
            //salimos del bucle
            break;
        }
        else
        {
            //coordenadas del punto final del segmento base
            xB = x[i*incX];
            yB = y[i*incY];
            //recorremos el número de segmentos de trabajo
            for(j=0;j<nSeg;j++)
            {
                //posición del punto inicial del siguiente segmento anterior
                pos = nPosAlig-1-j;
                //índices inicial y final del siguiente segmento anterior
                k = posAlig[pos];
                l = posAlig[pos-1];
                //puntos inicial y final del siguiente segmento
                xC = x[k*incX];
                yC = y[k*incY];
                xD = x[l*incX];
                yD = y[l*incY];
                //calculamos la intersección entre los segmentos
                inter = IntersecSegmentos2D(xA,yA,xB,yB,xC,yC,xD,yD,&xAux,
                                            &yAux);
                //comprobamos si hay intersección entre los segmentos
                if(inter!=GEOC_SEG_NO_INTERSEC)
                {
                    //salimos del bucle
                    break;
                }
            }
            //comprobamos si no ha habido ninguna intersección
            if(inter==GEOC_SEG_NO_INTERSEC)
            {
                //indicamos el índice del vértice final
                *posFin = i;
                //salimos del bucle
                break;
            }
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

/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file ptopol.c
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
#include"libgeoc/ptopol.h"
/******************************************************************************/
/******************************************************************************/
int GeocParOmpPtopol(char version[])
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
int GeocLongLongIntPtopol(void)
{
    //comprobamos si se ha pasado la variable del preprocesador
#if defined(PTOPOL_BORDE_LONG_64)
    return 1;
#else
    return 0;
#endif
}
/******************************************************************************/
/******************************************************************************/
int PtoEnRectangulo(const double x,
                    const double y,
                    const double xMin,
                    const double xMax,
                    const double yMin,
                    const double yMax)
{
    //posibles posiciones del punto
    if((x<xMin)||(x>xMax)||(y<yMin)||(y>yMax))
    {
        //punto fuera
        return GEOC_PTO_FUERA_POLIG;
    }
    else if((x>xMin)&&(x<xMax)&&(y>yMin)&&(y<yMax))
    {
        //punto dentro
        return GEOC_PTO_DENTRO_POLIG;
    }
    else if(((x==xMin)&&(y==yMax))||((x==xMax)&&(y==yMax))||
            ((x==xMax)&&(y==yMin))||((x==xMin)&&(y==yMin)))
    {
        //punto en un vértice
        return GEOC_PTO_VERTICE_POLIG;
    }
    else
    {
        //punto en el borde
        return GEOC_PTO_BORDE_POLIG;
    }
}
/******************************************************************************/
/******************************************************************************/
int RectanguloEnRectangulo(const int borde,
                           const double xMin1,
                           const double xMax1,
                           const double yMin1,
                           const double yMax1,
                           const double xMin2,
                           const double xMax2,
                           const double yMin2,
                           const double yMax2)
{
    //variable de salida, que inicializamos como polígonos no disjuntos
    int sal=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el borde se tiene en cuenta o no
    if(borde)
    {
        //el borde se tiene en cuenta
        if((xMin1>=xMin2)&&(xMax1<=xMax2)&&(yMin1>=yMin2)&&(yMax1<=yMax2))
        {
            //el rectángulo está contenido
            sal = 1;
        }
    }
    else
    {
        //el borde no se tiene en cuenta
        if((xMin1>xMin2)&&(xMax1<xMax2)&&(yMin1>yMin2)&&(yMax1<yMax2))
        {
            //el rectángulo está contenido
            sal = 1;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
int RectDisjuntos(const double xMin1,
                  const double xMax1,
                  const double yMin1,
                  const double yMax1,
                  const double xMin2,
                  const double xMax2,
                  const double yMin2,
                  const double yMax2)
{
    //variable de salida, que inicializamos como polígonos no disjuntos
    int sal=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si son disjuntos
    if((xMin1>xMax2)||(xMax1<xMin2)||(yMin1>yMax2)||(yMax1<yMin2))
    {
        //los restángulos son disjuntos
        sal = 1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligono(const double x,
                  const double y,
                  const double* coorX,
                  const double* coorY,
                  const size_t N,
                  const size_t incX,
                  const size_t incY)
{
    //índices para recorrer un bucle
    size_t i=0,j=0;
    //variables de posición
    size_t posIX=0,posJX=0,posIY=0,posJY=0;
    //variable de salida
    int c=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos todos los vértices del polígono
    for(i=0,j=N-1;i<N;j=i++)
    {
        //calculamos previamente las posiciones para multiplicar menos
        posIX = i*incX;
        posJX = j*incX;
        posIY = i*incY;
        posJY = j*incY;
        //calculamos
        if(((coorY[posIY]>y)!=(coorY[posJY]>y))&&
           (x<(coorX[posJX]-coorX[posIX])*(y-coorY[posIY])/
              (coorY[posJY]-coorY[posIY])+coorX[posIX]))
        {
            c = !c;
        }
    }
    //asignamos el elemento de salida
    if(c)
    {
        //el punto está dentro del polígono
        c = GEOC_PTO_DENTRO_POLIG;
    }
    else
    {
        //el punto está fuera del polígono
        c = GEOC_PTO_FUERA_POLIG;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return c;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligonoVertice(const double x,
                         const double y,
                         const double* coorX,
                         const double* coorY,
                         const size_t N,
                         const size_t incX,
                         const size_t incY)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable de salida, que inicializamos fuera del polígono
    int pos=GEOC_PTO_FUERA_POLIG;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el punto es un vértice
    for(i=0;i<N;i++)
    {
        //comprobamos las coordenadas
        if((x==coorX[i*incX])&&(y==coorY[i*incY]))
        {
            //indicamos que el punto es un vértice
            pos = GEOC_PTO_VERTICE_POLIG;
            //salimos del bucle
            break;
        }
    }
    //sólo continuamos si el punto no es un vértice
    if(pos!=GEOC_PTO_VERTICE_POLIG)
    {
        //calculamos la posición sin tener en cuenta el borde
        pos = PtoEnPoligono(x,y,coorX,coorY,N,incX,incY);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligonoVerticeBorde(const long x,
                              const long y,
                              const long* coorX,
                              const long* coorY,
                              const size_t N,
                              const size_t incX,
                              const size_t incY)
{
    //NOTA: SE MANTIENEN MUCHOS DE LOS COMENTARIOS ORIGINALES
    //índices de vértices
    size_t i=0,i1=0;
    //number of (right,left) edge/ray crossings
    int Rcross=0,Lcross=0;
    //flags indicating the edge strads the X axis
    int Rstrad=0,Lstrad=0;
    //coordenadas del polígono referidas al punto de trabajo
    ptopol_long cx=0,cy=0,cx1=0,cy1=0;
    //número de elementos de trabajo del polígono
    size_t n=N;
    //variable auxiliar
    double X=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el primer vértice se repite al final
    if((coorX[0]==coorX[(N-1)*incX])&&(coorY[0]==coorY[(N-1)*incY]))
    {
        //trabajamos con todos los vértices, menos el último
        n = N-1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //for each edge e=(i-1,i), see if crosses ray
    for(i=0;i<n;i++)
    {
        //referimos el vértice de trabajo al punto
        cx = coorX[i*incX]-x;
        cy = coorY[i*incY]-y;
        //comprobamos si el punto es un vértice del polígono
        if((cx==0)&&(cy==0))
        {
            //el punto es un vértice
            return GEOC_PTO_VERTICE_POLIG;
        }
        //calculamos el índice del punto anterior en el polígono
        i1 = (i) ? i-1 : n-1;
        //referimos el vértice de trabajo al punto según el nuevo índice
        cx1 = coorX[i1*incX]-x;
        cy1 = coorY[i1*incY]-y;
        //check if e straddles X axis, with bias above/below
        Rstrad = (cy>0)!=(cy1>0);
        Lstrad = (cy<0)!=(cy1<0);
        //straddle computation
        if(Rstrad||Lstrad)
        {
            //compute intersection of e with x axis
            X = ((double)(cx*cy1-cx1*cy))/((double)(cy1-cy));
            //crosses ray if strictly positive intersection
            if(Rstrad&&(X>0.0))
            {
                Rcross++;
            }
            //crosses ray if strictly negative intersection
            if(Lstrad&&(X<0.0))
            {
                Lcross++;
            }
        }
    }
    //q on the edge if left and right cross are not the same parity
    if((Rcross%2)!=(Lcross%2))
    {
        //el punto está en un borde
        return GEOC_PTO_BORDE_POLIG;
    }
    //q inside if an odd number of crossings
    if((Rcross%2)==1)
    {
        //el punto es interior
        return GEOC_PTO_DENTRO_POLIG;
    }
    else
    {
        //el punto es exterior
        return GEOC_PTO_FUERA_POLIG;
    }
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligonoVerticeBordeDouble(const double x,
                                    const double y,
                                    const double* coorX,
                                    const double* coorY,
                                    const size_t N,
                                    const size_t incX,
                                    const size_t incY,
                                    const double factor,
                                    const int redondeo)
{
    //NOTA: SE MANTIENEN LOS COMENTARIOS ORIGINALES DE LA FUNCIÓN PARA VARIABLES
    //DE TIPO ENTERO
    //índices de vértices
    size_t i=0,i1=0;
    //number of (right,left) edge/ray crossings
    int Rcross=0,Lcross=0;
    //flags indicating the edge strads the X axis
    int Rstrad=0,Lstrad=0;
    //punto a evaluar pasado a número entero
    ptopol_long fX=0,fY=0;
    //coordenadas del polígono referidas al punto de trabajo
    ptopol_long cx=0,cy=0,cx1=0,cy1=0;
    //número de elementos de trabajo del polígono
    size_t n=N;
    //variable auxiliar
    double X=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si el primer vértice se repite al final
    if((coorX[0]==coorX[(N-1)*incX])&&(coorY[0]==coorY[(N-1)*incY]))
    {
        //trabajamos con todos los vértices, menos el último
        n = N-1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //pasamos a número entero el punto a evaluar
    if(redondeo)
    {
        //redondeo
        fX = (ptopol_long)(round(factor*x));
        fY = (ptopol_long)(round(factor*y));
    }
    else
    {
        //truncamiento
        fX = (ptopol_long)(factor*x);
        fY = (ptopol_long)(factor*y);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //for each edge e=(i-1,i), see if crosses ray
    for(i=0;i<n;i++)
    {
        //calculamos el índice del punto anterior en el polígono
        i1 = (i) ? i-1 : n-1;
        //para referir los vértices de trabajo al punto, comprobamos si hay que
        //redondear o truncar
        if(redondeo)
        {
            //redondeo del vértice actual
            cx = (ptopol_long)(round(factor*coorX[i*incX]))-fX;
            cy = (ptopol_long)(round(factor*coorY[i*incY]))-fY;
            //redondeo del vértice anterior
            cx1 = (ptopol_long)(round(factor*coorX[i1*incX]))-fX;
            cy1 = (ptopol_long)(round(factor*coorY[i1*incY]))-fY;
        }
        else
        {
            //truncamiento del vértice actual
            cx = (ptopol_long)(factor*coorX[i*incX])-fX;
            cy = (ptopol_long)(factor*coorY[i*incY])-fY;
            //redondeo del vértice anterior
            cx1 = (ptopol_long)(factor*coorX[i1*incX])-fX;
            cy1 = (ptopol_long)(factor*coorY[i1*incY])-fY;
        }
        //comprobamos si el punto es un vértice del polígono
        if((cx==0)&&(cy==0))
        {
            //el punto es un vértice
            return GEOC_PTO_VERTICE_POLIG;
        }
        //check if e straddles X axis, with bias above/below
        Rstrad = (cy>0)!=(cy1>0);
        Lstrad = (cy<0)!=(cy1<0);
        //straddle computation
        if(Rstrad||Lstrad)
        {
            //compute intersection of e with x axis
            X = ((double)(cx*cy1-cx1*cy))/((double)(cy1-cy));
            //crosses ray if strictly positive intersection
            if(Rstrad&&(X>0.0))
            {
                Rcross++;
            }
            //crosses ray if strictly negative intersection
            if(Lstrad&&(X<0.0))
            {
                Lcross++;
            }
        }
    }
    //q on the edge if left and right cross are not the same parity
    if((Rcross%2)!=(Lcross%2))
    {
        //el punto está en un borde
        return GEOC_PTO_BORDE_POLIG;
    }
    //q inside if an odd number of crossings
    if((Rcross%2)==1)
    {
        //el punto es interior
        return GEOC_PTO_DENTRO_POLIG;
    }
    else
    {
        //el punto es exterior
        return GEOC_PTO_FUERA_POLIG;
    }
}
/******************************************************************************/
/******************************************************************************/
size_t* BuscaGeocNanEnVectores(const double* x,
                               const double* y,
                               const size_t N,
                               const size_t incX,
                               const size_t incY,
                               size_t* nNan)
{
    //índice para recorrer bucles
    size_t i=0;
    //identificadores de NaN
    int esNanX=0,esNanY=0;
    //vector de salida
    size_t* salida=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos a 0 el número de NaN encontrados
    *nNan = 0;
    //comprobamos una posible salida rápida
    if(N==0)
    {
        //salimos de la función
        return salida;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los elementos de los vectores
    for(i=0;i<N;i++)
    {
        //inicializamos los identificadores de NaN
        esNanX = 0;
        esNanY = 0;
        //comprobamos si el elemento del vector X es NaN
        if(EsGeocNan(x[i*incX]))
        {
            //la X es NaN
            esNanX = 1;
            //comprobamos si tenemos vector Y
            if(y!=NULL)
            {
                //comprobamos si el elemento del vector Y es NaN
                if(EsGeocNan(y[i*incY]))
                {
                    //la Y es NaN
                    esNanY = 1;
                }
            }
        }
        //comprobamos si hemos encontrado NaN
        if((esNanX&&(y==NULL))||(esNanX&&esNanY))
        {
            //aumentamos el contador de NaN encontrados
            (*nNan)++;
            //reasignamos memoria a la salida
            salida = (size_t*)realloc(salida,(*nNan)*sizeof(size_t));
            //comprobamos los posibles errores
            if(salida==NULL)
            {
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
            //indicamos la posición del valor NaN
            salida[(*nNan)-1] = i;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
void DatosPoliIndividualEnVecInd(const size_t* posInd,
                                 const size_t indPosInd,
                                 const size_t incX,
                                 const size_t incY,
                                 size_t* iniX,
                                 size_t* iniY,
                                 size_t* nElem)
{
    //posiciones de inicio y final en los vectores de vértices
    *iniX = (posInd[indPosInd]+1)*incX;
    *iniY = (posInd[indPosInd]+1)*incY;
    //número de vértices del polígono
    *nElem = posInd[indPosInd+1]-posInd[indPosInd]-1;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligonoInd(const double x,
                     const double y,
                     const double* coorX,
                     const double* coorY,
                     const size_t N,
                     const size_t incX,
                     const size_t incY,
                     const size_t* posNan,
                     const size_t nNan,
                     size_t* poli)
{
    //índice para recorrer bucles
    size_t i=0;
    //posiciones de inicio de los vértices X e Y
    size_t iniX=0,iniY=0;
    //número de elementos del polígono a chequear
    size_t nElem=0;
    //variable auxiliar de situación de punto
    int posAux=0;
    //variable indicadora de continuación de chequeos
    size_t continuar=1;
    //variable de salida
    int pos=GEOC_PTO_FUERA_POLIG;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el polígono que contiene al punto
    *poli = 0;
    //comprobamos si hay valores NaN
    if(nNan)
    {
        //paralelización con OpenMP
        //utilizo schedule(dynamic) para que los polígonos vayan siendo
        //chequeados uno a uno según los hilos de ejecución van quedándose
        //libres
        //hago esto porque es muy probable que los polígonos vengan listados de
        //mayor a menor número de vértices y así se podrá trabajar con varios
        //polígonos pequeños mientras se testea uno grande
#if defined(_OPENMP)
#pragma omp parallel for default(none) schedule(dynamic) \
 shared(continuar,posNan,coorX,coorY,pos,poli) \
 private(i,iniX,iniY,nElem,posAux)
#endif
        //recorremos desde el primer NaN hasta el penúltimo
        for(i=0;i<(nNan-1);i++)
        {
            //hacemos que todos los hilos vean la variable continuar actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
            //comprobamos si hay que continuar chequeando polígonos
            if(continuar)
            {
                //extraemos los datos de definición del polígono
                DatosPoliIndividualEnVecInd(posNan,i,incX,incY,&iniX,&iniY,
                                            &nElem);
                //comprobamos la inclusión para el polígono de trabajo
                posAux = PtoEnPoligono(x,y,&coorX[iniX],&coorY[iniY],nElem,incX,
                                       incY);
                //me aseguro de que las variables involucradas sean actualizadas
                //por un hilo cada vez, sin posibilidad de modificación por
                //varios al mismo tiempo
#if defined(_OPENMP)
#pragma omp critical
#endif
{
                //si el punto no está fuera, no se han de hacer más operaciones
                //el continuar==1 asegura que nos quedemos con el primer
                //polígono en que está incluido el punto, ya que una vez que el
                //hilo con punto encontrado actualice la variable continuar, el
                //resto con posibles resultados positivos no pasarán este if()
                if((continuar==1)&&(posAux!=GEOC_PTO_FUERA_POLIG))
                {
                    //asignamos la variable de salida
                    pos = posAux;
                    //asignamos el polígono que contiene al punto
                    *poli = i;
                    //indicamos que no hay que continuar haciendo pruebas
                    //esta variable se usa para el caso de ejecución en paralelo
                    continuar = 0;
                    //hacemos que todos los hilos vean la variable continuar
                    //actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
                }
}
            }
        } // --> fin del #pragma omp parallel for
    }
    else
    {
        //hacemos una comprobación normal
        pos = PtoEnPoligono(x,y,coorX,coorY,N,incX,incY);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligonoVerticeInd(const double x,
                            const double y,
                            const double* coorX,
                            const double* coorY,
                            const size_t N,
                            const size_t incX,
                            const size_t incY,
                            const size_t* posNan,
                            const size_t nNan,
                            size_t* poli)
{
    //índice para recorrer bucles
    size_t i=0;
    //posiciones de inicio de los vértices X e Y
    size_t iniX=0,iniY=0;
    //número de elementos del polígono a chequear
    size_t nElem=0;
    //variable auxiliar de situación de punto
    int posAux=0;
    //variable indicadora de continuación de chequeos
    size_t continuar=1;
    //variable de salida
    int pos=GEOC_PTO_FUERA_POLIG;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el polígono que contiene al punto
    *poli = 0;
    //comprobamos si hay valores NaN
    if(nNan)
    {
        //paralelización con OpenMP
        //utilizo schedule(dynamic) para que los polígonos vayan siendo
        //chequeados uno a uno según los hilos de ejecución van quedándose
        //libres
        //hago esto porque es muy probable que los polígonos vengan listados de
        //mayor a menor número de vértices y así se podrá trabajar con varios
        //polígonos pequeños mientras se testea uno grande
#if defined(_OPENMP)
#pragma omp parallel for default(none) schedule(dynamic) \
 shared(continuar,posNan,coorX,coorY,pos,poli) \
 private(i,iniX,iniY,nElem,posAux)
#endif
        //recorremos desde el primer NaN hasta el penúltimo
        for(i=0;i<(nNan-1);i++)
        {
            //hacemos que todos los hilos vean la variable continuar actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
            //comprobamos si hay que continuar chequeando polígonos
            if(continuar)
            {
                //extraemos los datos de definición del polígono
                DatosPoliIndividualEnVecInd(posNan,i,incX,incY,&iniX,&iniY,
                                            &nElem);
                //comprobamos la inclusión para el polígono de trabajo
                posAux = PtoEnPoligonoVertice(x,y,&coorX[iniX],&coorY[iniY],
                                              nElem,incX,incY);
                //me aseguro de que las variables involucradas sean actualizadas
                //por un hilo cada vez, sin posibilidad de modificación por
                //varios al mismo tiempo
#if defined(_OPENMP)
#pragma omp critical
#endif
{
                //si el punto no está fuera, no se han de hacer más operaciones
                //el continuar==1 asegura que nos quedemos con el primer
                //polígono en que está incluido el punto, ya que una vez que el
                //hilo con punto encontrado actualice la variable continuar, el
                //resto con posibles resultados positivos no pasarán este if()
                if((continuar==1)&&(posAux!=GEOC_PTO_FUERA_POLIG))
                {
                    //asignamos la variable de salida
                    pos = posAux;
                    //asignamos el polígono que contiene al punto
                    *poli = i;
                    //indicamos que no hay que continuar haciendo pruebas
                    //esta variable se usa para el caso de ejecución en paralelo
                    continuar = 0;
                    //hacemos que todos los hilos vean la variable continuar
                    //actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
                }
}
            }
        } // --> fin del #pragma omp parallel for
    }
    else
    {
        //hacemos una comprobación normal
        pos = PtoEnPoligonoVertice(x,y,coorX,coorY,N,incX,incY);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
}
/******************************************************************************/
/******************************************************************************/
int PtoEnPoligonoVerticeBordeInd(const long x,
                                 const long y,
                                 const long* coorX,
                                 const long* coorY,
                                 const size_t N,
                                 const size_t incX,
                                 const size_t incY,
                                 const size_t* posNan,
                                 const size_t nNan,
                                 size_t* poli)
{
    //índice para recorrer bucles
    size_t i=0;
    //posiciones de inicio de los vértices X e Y
    size_t iniX=0,iniY=0;
    //número de elementos del polígono a chequear
    size_t nElem=0;
    //variable auxiliar de situación de punto
    int posAux=0;
    //variable indicadora de continuación de chequeos
    size_t continuar=1;
    //variable de salida
    int pos=GEOC_PTO_FUERA_POLIG;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el polígono que contiene al punto
    *poli = 0;
    //comprobamos si hay valores NaN
    if(nNan)
    {
        //paralelización con OpenMP
        //utilizo schedule(dynamic) para que los polígonos vayan siendo
        //chequeados uno a uno según los hilos de ejecución van quedándose
        //libres
        //hago esto porque es muy probable que los polígonos vengan listados de
        //mayor a menor número de vértices y así se podrá trabajar con varios
        //polígonos pequeños mientras se testea uno grande
#if defined(_OPENMP)
#pragma omp parallel for default(none) schedule(dynamic) \
 shared(continuar,posNan,coorX,coorY,pos,poli) \
 private(i,iniX,iniY,nElem,posAux)
#endif
        //recorremos desde el primer NaN hasta el penúltimo
        for(i=0;i<(nNan-1);i++)
        {
            //hacemos que todos los hilos vean la variable continuar actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
            //comprobamos si hay que continuar chequeando polígonos
            if(continuar)
            {
                //extraemos los datos de definición del polígono
                DatosPoliIndividualEnVecInd(posNan,i,incX,incY,&iniX,&iniY,
                                            &nElem);
                //comprobamos la inclusión para el polígono de trabajo
                posAux = PtoEnPoligonoVerticeBorde(x,y,&coorX[iniX],
                                                   &coorY[iniY],nElem,incX,
                                                   incY);
                //me aseguro de que las variables involucradas sean actualizadas
                //por un hilo cada vez, sin posibilidad de modificación por
                //varios al mismo tiempo
#if defined(_OPENMP)
#pragma omp critical
#endif
{
                //si el punto no está fuera, no se han de hacer más operaciones
                //el continuar==1 asegura que nos quedemos con el primer
                //polígono en que está incluido el punto, ya que una vez que el
                //hilo con punto encontrado actualice la variable continuar, el
                //resto con posibles resultados positivos no pasarán este if()
                if((continuar==1)&&(posAux!=GEOC_PTO_FUERA_POLIG))
                {
                    //asignamos la variable de salida
                    pos = posAux;
                    //asignamos el polígono que contiene al punto
                    *poli = i;
                    //indicamos que no hay que continuar haciendo pruebas
                    //esta variable se usa para el caso de ejecución en paralelo
                    continuar = 0;
                    //hacemos que todos los hilos vean la variable continuar
                    //actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
                }
}
            }
        } // --> fin del #pragma omp parallel for
    }
    else
    {
        //hacemos una comprobación normal
        pos = PtoEnPoligonoVerticeBorde(x,y,coorX,coorY,N,incX,incY);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
}
/******************************************************************************/
/******************************************************************************/
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
                                       size_t* poli)
{
    //índice para recorrer bucles
    size_t i=0;
    //posiciones de inicio de los vértices X e Y
    size_t iniX=0,iniY=0;
    //número de elementos del polígono a chequear
    size_t nElem=0;
    //variable auxiliar de situación de punto
    int posAux=0;
    //variable indicadora de continuación de chequeos
    size_t continuar=1;
    //variable de salida
    int pos=GEOC_PTO_FUERA_POLIG;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el polígono que contiene al punto
    *poli = 0;
    //comprobamos si hay valores NaN
    if(nNan)
    {
        //paralelización con OpenMP
        //utilizo schedule(dynamic) para que los polígonos vayan siendo
        //chequeados uno a uno según los hilos de ejecución van quedándose
        //libres
        //hago esto porque es muy probable que los polígonos vengan listados de
        //mayor a menor número de vértices y así se podrá trabajar con varios
        //polígonos pequeños mientras se testea uno grande
#if defined(_OPENMP)
#pragma omp parallel for default(none) schedule(dynamic) \
 shared(continuar,posNan,coorX,coorY,pos,poli) \
 private(i,iniX,iniY,nElem,posAux)
#endif
        //recorremos desde el primer NaN hasta el penúltimo
        for(i=0;i<(nNan-1);i++)
        {
            //hacemos que todos los hilos vean la variable continuar actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
            //comprobamos si hay que continuar chequeando polígonos
            if(continuar)
            {
                //extraemos los datos de definición del polígono
                DatosPoliIndividualEnVecInd(posNan,i,incX,incY,&iniX,&iniY,
                                            &nElem);
                //comprobamos la inclusión para el polígono de trabajo
                posAux = PtoEnPoligonoVerticeBordeDouble(x,y,&coorX[iniX],
                                                         &coorY[iniY],nElem,
                                                         incX,incY,factor,
                                                         redondeo);
                //me aseguro de que las variables involucradas sean actualizadas
                //por un hilo cada vez, sin posibilidad de modificación por
                //varios al mismo tiempo
#if defined(_OPENMP)
#pragma omp critical
#endif
{
                //si el punto no está fuera, no se han de hacer más operaciones
                //el continuar==1 asegura que nos quedemos con el primer
                //polígono en que está incluido el punto, ya que una vez que el
                //hilo con punto encontrado actualice la variable continuar, el
                //resto con posibles resultados positivos no pasarán este if()
                if((continuar==1)&&(posAux!=GEOC_PTO_FUERA_POLIG))
                {
                    //asignamos la variable de salida
                    pos = posAux;
                    //asignamos el polígono que contiene al punto
                    *poli = i;
                    //indicamos que no hay que continuar haciendo pruebas
                    //esta variable se usa para el caso de ejecución en paralelo
                    continuar = 0;
                    //hacemos que todos los hilos vean la variable continuar
                    //actualizada
#if defined(_OPENMP)
#pragma omp flush(continuar)
#endif
                }
}
            }
        } // --> fin del #pragma omp parallel for
    }
    else
    {
        //hacemos una comprobación normal
        pos = PtoEnPoligonoVerticeBordeDouble(x,y,coorX,coorY,N,incX,incY,
                                              factor,redondeo);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return pos;
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

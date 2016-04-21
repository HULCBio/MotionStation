/* -*- coding: utf-8 -*- */
/**
\ingroup geom gshhs
@{
\file recpolil.c
\brief Definición funciones para el recorte de polilíneas por medio de
       polígonos.
\author José Luis García Pallero, jgpallero@gmail.com
\date 05 de junio de 2011
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
#include"libgeoc/recpolil.h"
/******************************************************************************/
/******************************************************************************/
vertPolilClip* CreaVertPolilClip(const double x,
                                 const double y,
                                 vertPolilClip* anterior,
                                 vertPolilClip* siguiente,
                                 const char orig,
                                 const char pos,
                                 const double alfa)
{
    //variable de salida (nuevo vértice)
    vertPolilClip* nuevoVert=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos memoria para el nuevo vértice
    nuevoVert = (vertPolilClip*)malloc(sizeof(vertPolilClip));
    //comprobamos los posibles errores
    if(nuevoVert==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos los vértices anterior y posterior
    nuevoVert->anterior = anterior;
    nuevoVert->siguiente = siguiente;
    //si anterior es un vértice bueno
    if(anterior!=NULL)
    {
        //lo apuntamos al vértice creado
        nuevoVert->anterior->siguiente = nuevoVert;
    }
    //si siguiente es un vértice bueno
    if(siguiente!=NULL)
    {
        //indicamos que el vértice creado es el anterior
        nuevoVert->siguiente->anterior = nuevoVert;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos el resto de campos
    nuevoVert->x = x;
    nuevoVert->y = y;
    nuevoVert->orig = orig;
    nuevoVert->pos = pos;
    nuevoVert->alfa = alfa;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return nuevoVert;
}
/******************************************************************************/
/******************************************************************************/
vertPolilClip* CreaPolilClip(const double* x,
                             const double* y,
                             const size_t nCoor,
                             const size_t incX,
                             const size_t incY)
{
    //índice para recorrer bucles
    size_t i=0;
    //variable auxiliar de posición
    size_t posIni=0;
    //otra variable auxiliar
    int hayVert=0;
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    //variable de salida
    vertPolilClip* poli=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //buscamos el primer punto que sea distinto de NaN
    for(i=0;i<nCoor;i++)
    {
        //comprobamos si el elemento es distinto de NaN
        if((!EsGeocNan(x[i*incX]))&&(!EsGeocNan(y[i*incY])))
        {
            //indicamos que sí hay vértices de trabajo
            hayVert = 1;
            //guardamos la posición de este elemento
            posIni = i;
            //salimos del bucle
            break;
        }
    }
    //si no hay ningún vértice distinto de NaN
    if(!hayVert)
    {
        //salimos de la función
        return poli;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el primer elemento (indicamos que está fuera del polígono
    //que recortará a la polilínea, ya que el valor verdadero de pos se indicará
    //en otra función)
    poli = CreaVertPolilClip(x[posIni*incX],y[posIni*incY],NULL,NULL,1,0,0.0);
    //comprobamos los posibles errores
    if(poli==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    //asignamos el elemento creado a la variable auxiliar
    aux = poli;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los puntos de trabajo
    for(i=(posIni+1);i<nCoor;i++)
    {
        //comprobamos si el elemento es distinto de NaN
        if((!EsGeocNan(x[i*incX]))&&(!EsGeocNan(y[i*incY])))
        {
            //vamos añadiendo vértices al final (seguimos indicando que están
            //fuera del polígono que recortará a la polilínea)
            aux = CreaVertPolilClip(x[i*incX],y[i*incY],aux,NULL,1,0,0.0);
            //comprobamos los posibles errores
            if(aux==NULL)
            {
                //liberamos la memoria asignada hasta ahora
                LibMemPolilClip(poli);
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
    return poli;
}
/******************************************************************************/
/******************************************************************************/
void LibMemPolilClip(vertPolilClip* poli)
{
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //trabajamos mientras quede memoria
    while(poli!=NULL)
    {
        //apuntamos con la estructura auxiliar hacia la memoria a liberar
        aux = poli;
        //apuntamos con la estructura principal al siguiente vértice
        poli = poli->siguiente;
        //liberamos la memoria
        free(aux);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
vertPolilClip* ReiniciaPolilClip(vertPolilClip* poli)
{
    //estructura que apunta al espacio en memoria a liberar
    vertPolilClip* borra=NULL;
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    //estructura de salida
    vertPolilClip* sal=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar
    aux = poli;
    //comprobamos una posible salida rápida
    if(aux==NULL)
    {
        //salimos de la función
        return NULL;
    }
    //buscamos para la estructura de salida el primer vértice original
    while(aux!=NULL)
    {
        //comprobamos si estamos ante un vértice bueno
        if(aux->orig)
        {
            //asignamos la variable de salida
            sal = aux;
            //salimos del bucle
            break;
        }
        //siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //volvemos a inicializar la variable auxiliar
    aux = poli;
    //mientras la variable de trabajo no apunte a NULL
    while(aux!=NULL)
    {
        //comprobamos si estamos ante un vértice a borrar
        if(aux->orig==0)
        {
            //lo almacenamos en la estructura de borrado
            borra = aux;
            //actualizamos el puntero de vértice siguiente
            if(aux->anterior!=NULL)
            {
                //cuando el vértice a borrar no es el primero de la lista
                aux->anterior->siguiente = aux->siguiente;
            }
            else if(aux->siguiente!=NULL)
            {
                //cuando el vértice a borrar es el primero de la lista
                aux->siguiente->anterior = NULL;
            }
            //actualizamos el puntero de vértice anterior
            if(aux->siguiente!=NULL)
            {
                //cuando el vértice a borrar no es el último de la lista
                aux->siguiente->anterior = aux->anterior;
            }
            else if(aux->anterior!=NULL)
            {
                //cuando el vértice a borrar es el último de la lista
                aux->anterior->siguiente = NULL;
            }
            //apuntamos al siguiente elemento
            aux = aux->siguiente;
            //liberamos la memoria
            free(borra);
        }
        else
        {
            //reinicializamos el resto de miembros, menos las coordenadas
            //originales y el identificador de vértice original
            aux->pos = GEOC_PTO_FUERA_POLIG;
            aux->alfa = 0.0;
            //siguiente elemento
            aux = aux->siguiente;
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
vertPolilClip* SiguienteVertOrigPolilClip(vertPolilClip* vert)
{
    //variable de salida, que inicializamos con la dirección de entrada
    vertPolilClip* sal=vert;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //si estamos ante un vértice original, pasamos al siguiente
    if((sal!=NULL)&&sal->orig)
    {
        //apuntamos al siguiente vértice
        sal = sal->siguiente;
    }
    //vamos rechazando vérties no originales (el bucle se para cuando llegamos
    //al final o a un vértice que no es original)
    while((sal!=NULL)&&(sal->orig==0))
    {
        //pasamos al siguiente vértice
        sal = sal->siguiente;
    }
    //si hemos llegado a un vértice que no es original, apuntamos a NULL
    if((sal!=NULL)&&(sal->orig==0))
    {
        //asignamos NULL
        sal = NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return sal;
}
/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
void InsertaVertPolilClip(vertPolilClip* ins,
                          vertPolilClip* extremoIni,
                          vertPolilClip* extremoFin)
{
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el vértice auxiliar como el extremo inicial pasado
    aux = extremoIni;
    //mientras no lleguemos al extremo final y el punto a insertar esté más
    //lejos del origen que el punto de trabajo
    while((aux!=extremoFin)&&((aux->alfa)<=(ins->alfa)))
    {
        //avanzamos al siguiente vértice
        aux = aux->siguiente;
    }
    //insertamos el punto y ordenamos los punteros de vértices anterior y
    //posterior
    ins->siguiente = aux;
    ins->anterior = aux->anterior;
    ins->anterior->siguiente = ins;
    ins->siguiente->anterior = ins;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
size_t NumeroVertOrigPolilClip(vertPolilClip* poli)
{
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    //variable de salida
    size_t num=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //comprobamos si estamos ante un vértice original
    if(aux->orig)
    {
        //si no es un vértice original, nos posicionamos en el siguiente que sí
        //lo sea
        aux = SiguienteVertOrigPolilClip(aux);
    }
    //mientras no lleguemos al final
    while(aux!=NULL)
    {
        //aumentamos el contador de vértices originales
        num++;
        //nos posicionamos en el siguiente vértice original
        aux = SiguienteVertOrigPolilClip(aux);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return num;
}
/******************************************************************************/
/******************************************************************************/
size_t NumeroVertPolilClip(vertPolilClip* poli)
{
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    //variable de salida
    size_t num=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //mientras no lleguemos al final
    while(aux!=NULL)
    {
        //aumentamos el contador de vértices
        num++;
        //nos posicionamos en el siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return num;
}
/******************************************************************************/
/******************************************************************************/
int Paso1Recpolil(vertPolilClip* poli,
                  vertPoliClip* poliRec,
                  size_t* nIntersec)
{
    //estructuras auxiliares que apuntan a los elementos pasados
    vertPolilClip* auxA=NULL;
    vertPoliClip* auxC=NULL;
    //estructuras auxiliares para trabajar con el siguiente vértice
    vertPolilClip* auxB=NULL;
    vertPoliClip* auxD=NULL;
    //vértices de intersección a insertar
    vertPolilClip* insPolil=NULL;
    //coordenadas de la intersección de dos segmentos
    double xI=0.0,yI=0.0;
    //longitud de segmento y parámetro alfa
    double lon=0.0,alfa=0.0;
    //código de intersección de segmentos
    int intersec=0;
    //variable auxiliar
    int nuevoPunto=0;
    //variable de salida
    int salida=GEOC_ERR_NO_ERROR;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el número de intersecciones a 0
    *nIntersec = 0;
    //EL PRIMER PASO DEL ALGORITMO DE RECORTE DE POLILÍNEAS ES EL CÁLCULO DE
    //TODOS LOS PUNTOS DE INTERSECCIÓN ENTRE LOS POLÍGONOS
    //recorremos los vértices de la polilínea
    for(auxA=poli;auxA->siguiente!=NULL;auxA=auxA->siguiente)
    {
        //sólo trabajamos si el vértice es original
        if(auxA->orig)
        {
            //recorremos los vértices del polígono de recorte
            for(auxC=poliRec;auxC->siguiente!=NULL;auxC=auxC->siguiente)
            {
                //sólo trabajamos si el vértice es original (esto hace que
                //podamos trabajar con un polígono proveniente de una operación
                //booleana previa entre polígonos
                if(auxC->interseccion==0)
                {
                    //siguiente vértice de los segmentos
                    auxB = SiguienteVertOrigPolilClip(auxA);
                    auxD = SiguienteVertOrigPoliClip(auxC);
                    //calculamos la intersección de los segmentos
                    intersec = IntersecSegmentos2D(auxA->x,auxA->y,auxB->x,
                                                   auxB->y,auxC->x,auxC->y,
                                                   auxD->x,auxD->y,&xI,&yI);
                    //comprobamos la posición relativa del primer punto del
                    //segmento de la polilínea con respecto al polígono
                    //esta función sólo marca dentro o fuera
                    auxA->pos = (char)PtoEnPoliClip(auxA->x,auxA->y,poliRec);
                    //comprobamos si el segmento de la polilínea contiene al
                    //último punto de ésta, por lo que el bucle se acabará aquí
                    if(auxB->siguiente==NULL)
                    {
                        //comprobamos la posición relativa del último punto
                        auxB->pos = (char)PtoEnPoliClip(auxB->x,auxB->y,
                                                        poliRec);
                    }
                    //comprobamos si hay que aumentar el contador de
                    //intersecciones
                    if(intersec!=GEOC_SEG_NO_INTERSEC)
                    {
                        //aumentamos el contador de intersecciones
                        (*nIntersec)++;
                    }
                    //comprobamos el tipo de intersección
                    if(intersec==GEOC_SEG_INTERSEC)
                    {
                        //INTERSECCIÓN LIMPIA
                        //calculamos la longitud del segmento de la polilínea
                        lon = Dist2D(auxA->x,auxA->y,auxB->x,auxB->y);
                        //calculamos los parámetros alfa
                        alfa = Dist2D(auxA->x,auxA->y,xI,yI)/lon;
                        //creamos el nuevo vértice a insertar
                        insPolil = CreaVertPolilClip(xI,yI,NULL,NULL,0,
                                                     (char)GEOC_PTO_BORDE_POLIG,
                                                     alfa);
                        //comprobamos los posibles errores
                        if(insPolil==NULL)
                        {
                            //mensaje de error
                            GEOC_ERROR("Error de asignación de memoria");
                            //salimos de la función
                            return GEOC_ERR_ASIG_MEMORIA;
                        }
                        //añadimos el punto de intersección
                        InsertaVertPolilClip(insPolil,auxA,auxB);
                    }
                    else if(intersec==GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN)
                    {
                        //EL EXTREMO DE UN SEGMENTO TOCA AL OTRO SEGMENTO, PERO
                        //LOS SEGMENTOS NO SON COLINEALES
                        //comprobamos si el extremo que toca es el inicial del
                        //segmento de la polilínea
                        if((xI==auxA->x)&&(yI==auxA->y))
                        {
                            //el primer punto del segmento está en el borde
                            auxA->pos = (char)GEOC_PTO_BORDE_POLIG;
                        }
                        else if((xI!=auxB->x)||(yI!=auxB->y))
                        {
                            //el extremo que toca es del segmento del polígono y
                            //no toca al punto final del segmento de la
                            //polilínea
                            //calculamos la longitud del segmento de la
                            //polilínea
                            lon = Dist2D(auxA->x,auxA->y,auxB->x,auxB->y);
                            //calculamos los parámetros alfa
                            alfa = Dist2D(auxA->x,auxA->y,xI,yI)/lon;
                            //creamos el nuevo vértice a insertar
                            insPolil = CreaVertPolilClip(xI,yI,NULL,NULL,0,
                                                     (char)GEOC_PTO_BORDE_POLIG,
                                                         alfa);
                            //comprobamos los posibles errores
                            if(insPolil==NULL)
                            {
                                //mensaje de error
                                GEOC_ERROR("Error de asignación de memoria");
                                //salimos de la función
                                return GEOC_ERR_ASIG_MEMORIA;
                            }
                            //añadimos el punto de intersección
                            InsertaVertPolilClip(insPolil,auxA,auxB);
                        }
                        else
                        {
                            //comprobamos si estamos ante el segmento que
                            //contiene al último punto de la polilínea
                            if(auxB->siguiente==NULL)
                            {
                                //el último punto del segmento está en el borde
                                auxB->pos = (char)GEOC_PTO_BORDE_POLIG;
                            }
                            else
                            {
                                //disminuimos el contador de intersecciones, ya
                                //que esta se detectará en la siguiente vuelta
                                //del bucle
                                (*nIntersec)--;
                            }
                        }
                    }
                    else if(intersec==GEOC_SEG_INTERSEC_EXTREMO_COLIN)
                    {
                        //LOS SEGMENTOS SON COLINEALES PERO SÓLO SE TOCAN EN EL
                        //EXTREMO
                        //comprobamos si el extremo que toca es el primero
                        if((xI==auxA->x)&&(yI==auxA->y))
                        {
                            //el primer punto del segmento está en el borde
                            auxA->pos = (char)GEOC_PTO_BORDE_POLIG;
                        }
                        else
                        {
                            //comprobamos si estamos ante el segmento que
                            //contiene al último punto de la polilínea
                            if(auxB->siguiente==NULL)
                            {
                                //el último punto del segmento está en el borde
                                auxB->pos = (char)GEOC_PTO_BORDE_POLIG;
                            }
                            else
                            {
                                //disminuimos el contador de intersecciones, ya
                                //que esta se detectará en la siguiente vuelta
                                //del bucle
                                (*nIntersec)--;
                            }
                        }
                    }
                    else if(intersec==GEOC_SEG_INTERSEC_MISMO_SEG)
                    {
                        //AMBOS SEGMENTOS SON EL MISMO
                        //el primer punto del segmento está en el borde
                        auxA->pos = (char)GEOC_PTO_BORDE_POLIG;
                        //comprobamos si estamos ante el segmento que contiene
                        //al último punto de la polilínea
                        if(auxB->siguiente==NULL)
                        {
                            //aumentamos el contador de intersecciones
                            (*nIntersec)++;
                            //el último punto del segmento está en el borde
                            auxB->pos = (char)GEOC_PTO_BORDE_POLIG;
                        }
                    }
                    else if(intersec==GEOC_SEG_INTERSEC_COLIN)
                    {
                        //LOS SEGMENTOS TIENEN MÁS DE UN PUNTO EN COMÚN, PERO NO
                        //SON EL MISMO
                        //comprobamos si el extremo inicial está tocando el
                        //polígono o no
                        if((xI==auxA->x)&&(yI==auxA->y))
                        {
                            //el primer punto del segmento está en el borde
                            auxA->pos = (char)GEOC_PTO_BORDE_POLIG;
                            //identificador de nuevo punto
                            nuevoPunto = 0;
                            //comprobamos si alguno de los extremos del segmento
                            //del polígono está dentro del segmento de la
                            //polilínea
                            if(PuntoEntreDosPuntos2DColin(auxC->x,auxC->y,
                                                          auxA->x,auxA->y,
                                                          auxB->x,auxB->y))
                            {
                                //nuevo punto
                                nuevoPunto = 1;
                                //coordenadas del punto intersección
                                xI = auxC->x;
                                yI = auxC->y;
                            }
                            else if(PuntoEntreDosPuntos2DColin(auxD->x,auxD->y,
                                                               auxA->x,auxA->y,
                                                               auxB->x,auxB->y))
                            {
                                //nuevo punto
                                nuevoPunto = 1;
                                //coordenadas del punto intersección
                                xI = auxD->x;
                                yI = auxD->y;
                            }
                            //comprobamos si hay que añadir el nuevo punto
                            if(nuevoPunto)
                            {
                                //aumentamos el contador de intersecciones
                                (*nIntersec)++;
                                //calculamos la longitud del segmento de la
                                //polilínea
                                lon = Dist2D(auxA->x,auxA->y,auxB->x,auxB->y);
                                //calculamos los parámetros alfa
                                alfa = Dist2D(auxA->x,auxA->y,xI,yI)/lon;
                                //creamos el nuevo vértice a insertar
                                insPolil = CreaVertPolilClip(xI,yI,NULL,NULL,0,
                                                     (char)GEOC_PTO_BORDE_POLIG,
                                                            alfa);
                                //comprobamos los posibles errores
                                if(insPolil==NULL)
                                {
                                    //mensaje de error
                                    GEOC_ERROR("Error de asignación de memoria");
                                    //salimos de la función
                                    return GEOC_ERR_ASIG_MEMORIA;
                                }
                                //añadimos el punto de intersección
                                InsertaVertPolilClip(insPolil,auxA,auxB);
                            }
                            //comprobamos si estamos ante el segmento que
                            //contiene al último punto de la polilínea
                            if(auxB->siguiente==NULL)
                            {
                                //comprobamos si el último punto del segmento
                                //de la polilínea está contenido en el segmento
                                //del polígono
                                if(PuntoEntreDosPuntos2DColin(auxB->x,auxB->y,
                                                              auxC->x,auxC->y,
                                                              auxD->x,auxD->y))
                                {
                                    //aumentamos el contador de intersecciones
                                    (*nIntersec)++;
                                    //indicamos que el último punto del segmento
                                    //de la polilínea está en el borde
                                    auxB->pos = (char)GEOC_PTO_BORDE_POLIG;
                                }
                            }
                        }
                        else
                        {
                            //comprobamos si el vértice a añadir es el extremo
                            //final del segmento del polígono (la función
                            //devuelve las coordenadas del extremo final del
                            //segmento de la polilínea
                            if((xI==auxB->x)&&(yI==auxB->y))
                            {
                                //asignamos las coordenadas de salida correctas
                                xI = auxD->x;
                                yI = auxD->y;
                            }
                            //calculamos la longitud del segmento de la
                            //polilínea
                            lon = Dist2D(auxA->x,auxA->y,auxB->x,auxB->y);
                            //calculamos los parámetros alfa
                            alfa = Dist2D(auxA->x,auxA->y,xI,yI)/lon;
                            //creamos el nuevo vértice a insertar
                            insPolil = CreaVertPolilClip(xI,yI,NULL,NULL,0,
                                                     (char)GEOC_PTO_BORDE_POLIG,
                                                         alfa);
                            //comprobamos los posibles errores
                            if(insPolil==NULL)
                            {
                                //mensaje de error
                                GEOC_ERROR("Error de asignación de memoria");
                                //salimos de la función
                                return GEOC_ERR_ASIG_MEMORIA;
                            }
                            //añadimos el punto de intersección
                            InsertaVertPolilClip(insPolil,auxA,auxB);
                            //comprobamos si estamos ante el segmento que
                            //contiene al último punto de la polilínea
                            if(auxB->siguiente==NULL)
                            {
                                //aumentamos el contador de intersecciones
                                (*nIntersec)++;
                                //indicamos que el último punto del segmento de
                                //la polilínea está en el borde
                                auxB->pos = (char)GEOC_PTO_BORDE_POLIG;
                            }
                        }
                    }
                }
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return salida;
}
/******************************************************************************/
/******************************************************************************/
polil* Paso2Recpolil(vertPolilClip* poli,
                     const enum GEOC_OP_BOOL_POLIL op)
{
    //estructura auxiliar
    vertPolilClip* aux=NULL;
    //vectores de coordenadas de los vértices del resultado
    double* x=NULL;
    double* y=NULL;
    //número de elementos de los vectores x e y
    size_t nPtos=0;
    //número de elementos para los que ha sido asignada memoria
    size_t nElem=0;
    //variable de estado
    int estado=GEOC_ERR_NO_ERROR;
    //polilínea de salida
    polil* resultado=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //chequeamos una posible salida rápida porque la polilínea sea NULL
    if(poli==NULL)
    {
        //creamos la estructura vacía
        resultado = IniciaPolilVacia();
        //comprobamos los posibles errores
        if(resultado==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //salimos de la función
        return resultado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la estructura auxiliar con la dirección de entrada
    aux = poli;
    //distinguimos entre las dos operaciones
    //por defecto, recorte
    if(op!=GeocOpBoolFuera)
    {
        //vamos recorriendo vértices de la polilínea
        do
        {
            //comprobamos si el vértice es del borde o de dentro del polígono
            if(aux->pos==GEOC_PTO_DENTRO_POLIG)
            {
                //un punto de dentro del polígono siempre pertenece a la
                //polilínea recortada
                //no hace falta asignar los elementos NaN de separación de
                //polilíneas, que ya se añaden cuando de trabaja con un punto de
                //borde
                //aumentamos el número de elementos almacenados en los vectores
                //de coordenadas
                nPtos++;
                //comprobamos si hay que reasignar memoria
                if(nPtos>nElem)
                {
                    //aumentamos el número de elementos
                    nElem += GEOC_RECPOLIL_BUFFER_PTOS;
                    //reasignamos memoria
                    x = (double*)realloc(x,nElem*sizeof(double));
                    y = (double*)realloc(y,nElem*sizeof(double));
                    //comprobamos los posibles errores
                    if((x==NULL)||(y==NULL))
                    {
                        //liberamos la posible memoria asignada
                        free(x);
                        free(y);
                        //mensaje de error
                        GEOC_ERROR("Error de asignación de memoria");
                        //salimos de la función
                        return NULL;
                    }
                }
                //asignamos las coordenadas del vértice
                x[nPtos-1] = aux->x;
                y[nPtos-1] = aux->y;
            }
            else if(aux->pos==GEOC_PTO_BORDE_POLIG)
            {
                //comprobamos la situación de los vértices anterior y siguiente
                //para la posible reasignación de memoria
                if((aux->anterior==NULL)||(aux->siguiente==NULL)||
                   (aux->anterior->pos==GEOC_PTO_FUERA_POLIG)||
                   (aux->siguiente->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //este es un vértice de comienzo o fin de una polilínea, por
                    //lo que necesitamos memoria para las coordenadas y el
                    //marcador NaN
                    nPtos += 2;
                }
                else
                {
                    //este vértice pertenece al interior del polígono
                    nPtos++;
                }
                //comprobamos si hay que reasignar memoria
                if(nPtos>nElem)
                {
                    //aumentamos el número de elementos
                    nElem += GEOC_RECPOLIL_BUFFER_PTOS;
                    //reasignamos memoria
                    x = (double*)realloc(x,nElem*sizeof(double));
                    y = (double*)realloc(y,nElem*sizeof(double));
                    //comprobamos los posibles errores
                    if((x==NULL)||(y==NULL))
                    {
                        //liberamos la posible memoria asignada
                        free(x);
                        free(y);
                        //mensaje de error
                        GEOC_ERROR("Error de asignación de memoria");
                        //salimos de la función
                        return NULL;
                    }
                }
                //comprobamos de nuevo la situación de los vértices anterior y
                //posterior
                if((aux->anterior==NULL)||
                   (aux->anterior->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //el vértice es inicio de polilínea
                    //asignamos los valores NaN de separación
                    x[nPtos-2] = GeocNan();
                    y[nPtos-2] = GeocNan();
                    //asignamos las coordenadas del vértice
                    x[nPtos-1] = aux->x;
                    y[nPtos-1] = aux->y;
                }
                else if((aux->siguiente==NULL)||
                        (aux->siguiente->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //el vértice es final de polilínea
                    //asignamos las coordenadas del vértice
                    x[nPtos-2] = aux->x;
                    y[nPtos-2] = aux->y;
                    //asignamos los valores NaN de separación
                    x[nPtos-1] = GeocNan();
                    y[nPtos-1] = GeocNan();
                }
                else
                {
                    //el vértice pertenece a la polilínea recortada
                    x[nPtos-1] = aux->x;
                    y[nPtos-1] = aux->y;
                }
            }
            //avanzamos al siguiente vértice
            aux = aux->siguiente;
        }while(aux!=NULL);
    }
    else
    {
        //vamos recorriendo vértices de la polilínea
        do
        {
            //comprobamos si el vértice es del borde o de fuera del polígono
            if(aux->pos==GEOC_PTO_FUERA_POLIG)
            {
                //un punto de fuera del polígono siempre pertenece a la
                //polilínea exterior
                //no hace falta asignar los elementos NaN de separación de
                //polilíneas, que ya se añaden cuando de trabaja con un punto de
                //borde
                //aumentamos el número de elementos almacenados en los vectores
                //de coordenadas
                nPtos++;
                //comprobamos si hay que reasignar memoria
                if(nPtos>nElem)
                {
                    //aumentamos el número de elementos
                    nElem += GEOC_RECPOLIL_BUFFER_PTOS;
                    //reasignamos memoria
                    x = (double*)realloc(x,nElem*sizeof(double));
                    y = (double*)realloc(y,nElem*sizeof(double));
                    //comprobamos los posibles errores
                    if((x==NULL)||(y==NULL))
                    {
                        //liberamos la posible memoria asignada
                        free(x);
                        free(y);
                        //mensaje de error
                        GEOC_ERROR("Error de asignación de memoria");
                        //salimos de la función
                        return NULL;
                    }
                }
                //asignamos las coordenadas del vértice
                x[nPtos-1] = aux->x;
                y[nPtos-1] = aux->y;
            }
            else if(aux->pos==GEOC_PTO_BORDE_POLIG)
            {
                //comprobamos la situación de los vértices anterior y siguiente
                //para la posible reasignación de memoria
                if((aux->anterior!=NULL)&&(aux->siguiente!=NULL)&&
                   (aux->anterior->pos==GEOC_PTO_FUERA_POLIG)&&
                   (aux->siguiente->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //este vértice pertenece al exterior del polígono
                    nPtos++;
                }
                else if(((aux->anterior==NULL)||
                         (aux->anterior->pos!=GEOC_PTO_FUERA_POLIG))&&
                        (aux->siguiente!=NULL)&&
                        (aux->siguiente->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //este es un vértice de comienzo de una polilínea, por lo
                    //que necesitamos memoria para las coordenadas y el marcador
                    //NaN
                    nPtos += 2;
                }
                else if(((aux->siguiente==NULL)||
                         (aux->siguiente->pos!=GEOC_PTO_FUERA_POLIG))&&
                        (aux->anterior!=NULL)&&
                        (aux->anterior->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //este es un vértice de fin de una polilínea, por lo que
                    //necesitamos memoria para las coordenadas y el marcador NaN
                    nPtos += 2;
                }
                //comprobamos si hay que reasignar memoria
                if(nPtos>nElem)
                {
                    //aumentamos el número de elementos
                    nElem += GEOC_RECPOLIL_BUFFER_PTOS;
                    //reasignamos memoria
                    x = (double*)realloc(x,nElem*sizeof(double));
                    y = (double*)realloc(y,nElem*sizeof(double));
                    //comprobamos los posibles errores
                    if((x==NULL)||(y==NULL))
                    {
                        //liberamos la posible memoria asignada
                        free(x);
                        free(y);
                        //mensaje de error
                        GEOC_ERROR("Error de asignación de memoria");
                        //salimos de la función
                        return NULL;
                    }
                }
                //comprobamos de nuevo la situación de los vértices anterior y
                //posterior
                if((aux->anterior!=NULL)&&(aux->siguiente!=NULL)&&
                   (aux->anterior->pos==GEOC_PTO_FUERA_POLIG)&&
                   (aux->siguiente->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //el vértice pertenece a la polilínea recortada
                    x[nPtos-1] = aux->x;
                    y[nPtos-1] = aux->y;
                }
                else if(((aux->anterior==NULL)||
                         (aux->anterior->pos!=GEOC_PTO_FUERA_POLIG))&&
                        (aux->siguiente!=NULL)&&
                        (aux->siguiente->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //el vértice es inicio de polilínea
                    //asignamos los valores NaN de separación
                    x[nPtos-2] = GeocNan();
                    y[nPtos-2] = GeocNan();
                    //asignamos las coordenadas del vértice
                    x[nPtos-1] = aux->x;
                    y[nPtos-1] = aux->y;
                }
                else if(((aux->siguiente==NULL)||
                         (aux->siguiente->pos!=GEOC_PTO_FUERA_POLIG))&&
                        (aux->anterior!=NULL)&&
                        (aux->anterior->pos==GEOC_PTO_FUERA_POLIG))
                {
                    //el vértice es final de polilínea
                    //asignamos las coordenadas del vértice
                    x[nPtos-2] = aux->x;
                    y[nPtos-2] = aux->y;
                    //asignamos los valores NaN de separación
                    x[nPtos-1] = GeocNan();
                    y[nPtos-1] = GeocNan();
                }
            }
            //avanzamos al siguiente vértice
            aux = aux->siguiente;
        }while(aux!=NULL);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //creamos la estructura de salida
    resultado = CreaPolil(x,y,nPtos,1,1,&estado);
    //comprobamos los posibles errores
    if(resultado==NULL)
    {
        //liberamos la memoria asignada
        free(x);
        free(y);
        //comprobamos el error
        if(estado==GEOC_ERR_ASIG_MEMORIA)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
        }
        else
        {
            //mensaje de error
            GEOC_ERROR("Error en la llamada a 'CreaPolil()'\nEste error no "
                       "puede producirse aquí porque los NaN deben estar "
                       "bien puestos");
        }
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //liberamos la memoria utilizada
    free(x);
    free(y);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return resultado;
}
/******************************************************************************/
/******************************************************************************/
polil* RecortaPolil(vertPolilClip* poli,
                    vertPoliClip* poliRec,
                    const enum GEOC_OP_BOOL_POLIL op,
                    size_t* nIntersec)
{
    //identificador de error
    int idError=GEOC_ERR_NO_ERROR;
    //polilínea de salida de salida
    polil* resultado=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //PRIMER PASO DEL ALGORITMO: CÁLCULO DE TODOS LOS PUNTOS DE INTERSECCIÓN
    //ENTRE LA POLILÍNEA Y EL POLÍGONO
    //calculamos los puntos de intersección
    idError = Paso1Recpolil(poli,poliRec,nIntersec);
    //comprobamos los posibles errores
    if(idError==GEOC_ERR_ASIG_MEMORIA)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria en la llamada a "
                   "'Paso1Recpolil'");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si no hay intersecciones
    if(!(*nIntersec))
    {
        //comprobamos las posibles situaciones relativas entre la polilínea y el
        //polígono que pueden producir cero intersecciones
        if(PtoEnPoliClip(poli->x,poli->y,poliRec)==GEOC_PTO_FUERA_POLIG)
        {
            //LA POLILÍNEA ESTÁ FUERA DEL POLÍGONO DE RECORTE
            //distinguimos las operaciones (por defecto, dentro)
            if(op!=GeocOpBoolFuera)
            {
                //el resultado es una polilínea vacía
                resultado = CreaPolilPolilClip(NULL);
            }
            else
            {
                //el resultado es la polilínea original
                resultado = CreaPolilPolilClip(poli);
            }
        }
        else
        {
            //LA POLILÍNEA ESTÁ DENTRO DEL POLÍGONO DE RECORTE
            //distinguimos las operaciones (por defecto, dentro)
            if(op!=GeocOpBoolFuera)
            {
                //el resultado es la polilínea original
                resultado = CreaPolilPolilClip(poli);
            }
            else
            {
                //el resultado es una polilínea vacía
                resultado = CreaPolilPolilClip(NULL);
            }
        }
        //comprobamos los posibles errores
        if(resultado==NULL)
        {
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //salimos de la función
        return resultado;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //realizamos la operación si hay alguna intersección
    resultado = Paso2Recpolil(poli,op);
    //comprobamos los posibles errores
    if(resultado==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria en la llamada a "
                    "'Paso2Recpolil'");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return resultado;
}
/******************************************************************************/
/******************************************************************************/
polil* RecortaPolilMult(const polil* poli,
                        const polig* poliRec,
                        const enum GEOC_OP_BOOL_POLIL op,
                        size_t* nIntersec)
{
    //índices para recorrer bucles
    size_t i=0,j=0;
    //variable de posición
    size_t pos=0;
    //posición de un rectángulo con respecto a otro
    int pr=0;
    //número de intersecciones auxiliar
    size_t nInt=0;
    //variable de error
    int estado=GEOC_ERR_NO_ERROR;
    //listas de trabajo
    vertPolilClip* polilClip=NULL;
    vertPoliClip* poligClip=NULL;
    //polilínea auxiliar
    polil* polilAux=NULL;
    //variable de salida
    polil* resultado=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos el número total de intersecciones
    *nIntersec = 0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos la variable de salida
    resultado = IniciaPolilVacia();
    //comprobamos los posibles errores
    if(resultado==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos las polilíneas a recortar
    for(i=0;i<poli->nPolil;i++)
    {
        //dirección de inicio de los vértices de la polilínea
        pos = poli->posIni[i];
        //creamos la polilínea a recortar de trabajo
        polilClip = CreaPolilClip(&(poli->x[pos]),&(poli->y[pos]),
                                  poli->nVert[i],1,1);
        //comprobamos los posibles errores
        if(polilClip==NULL)
        {
            //liberamos la memoria asignada hasta ahora
            LibMemPolil(resultado);
            //mensaje de error
            GEOC_ERROR("Error de asignación de memoria");
            //salimos de la función
            return NULL;
        }
        //recorremos los polígonos de recorte
        for(j=0;j<poliRec->nPolig;j++)
        {
            //comprobamos si la polilínea y el polígono tienen definidos sus
            //límites
            if((poli->hayLim)&&(poliRec->hayLim))
            {
                //comprobamos si los restángulos que encierran a la polilínea y
                //al polígono son disjuntos o no
                pr = RectDisjuntos(poli->xMin[i],poli->xMax[i],poli->yMin[i],
                                   poli->yMax[i],
                                   poliRec->xMin[j],poliRec->xMax[j],
                                   poliRec->yMin[j],poliRec->yMax[j]);
                //comprobamos los casos particulares si los rectángulos son
                //disjuntos
                if(pr&&(op==GeocOpBoolDentro))
                {
                    //si buscamos la parte de la polilínea que cae dentro del
                    //polígono, no se añade nada
                    //vamos a la siguiente vuelta del bucle
                    continue;
                }
                else if(pr&&(op==GeocOpBoolFuera))
                {
                    //si buscamos la parte de la polilínea que cae fuera del
                    //polígono, se añade la polilínea entera
                    estado = AnyadeDatosPolil(resultado,&(poli->x[pos]),
                                              &(poli->y[pos]),poli->nVert[i],1,
                                              1);
                    //comprobamos los posibles errores, que sólo pueden ser de
                    //asignación de memoria
                    if(estado!=GEOC_ERR_NO_ERROR)
                    {
                        //liberamos la posible memoria asignada hasta ahora
                        LibMemPolilClip(polilClip);
                        LibMemPolil(resultado);
                        //lanzamos el mensaje de error
                        GEOC_ERROR("Error de asignación de memoria");
                        //salimos de la función
                        return NULL;
                    }
                    //vamos a la siguiente vuelta del bucle
                    continue;
                }
            }
            //dirección de inicio de los vértices del polígono de recorte
            pos = poliRec->posIni[j];
            //creamos el polígono de recorte de trabajo
            poligClip = CreaPoliClip(&(poliRec->x[pos]),&(poliRec->y[pos]),
                                     poliRec->nVert[j],1,1);
            //comprobamos los posibles errores
            if(poligClip==NULL)
            {
                //liberamos la memoria asignada hasta ahora
                LibMemPolilClip(polilClip);
                LibMemPolil(resultado);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
            //recortamos
            polilAux = RecortaPolil(polilClip,poligClip,op,&nInt);
            //comprobamos los posibles errores
            if(polilAux==NULL)
            {
                //liberamos la posible memoria asignada hasta ahora
                LibMemPolilClip(polilClip);
                LibMemPoliClip(poligClip);
                LibMemPolil(resultado);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
            //sumamos el número de intersecciones
            (*nIntersec) += nInt;
            //añadimos la polilínea recortada a la variable de salida
            if(AnyadePolilPolil(resultado,polilAux)==GEOC_ERR_ASIG_MEMORIA)
            {
                //liberamos la posible memoria asignada hasta ahora
                LibMemPolilClip(polilClip);
                LibMemPoliClip(poligClip);
                LibMemPolil(polilAux);
                LibMemPolil(resultado);
                //mensaje de error
                GEOC_ERROR("Error de asignación de memoria");
                //salimos de la función
                return NULL;
            }
            //liberamos la memoria asignada al polígono de esta vuelta del bucle
            LibMemPoliClip(poligClip);
            //liberamos la memoria asignada a la polilínea auxiliar
            LibMemPolil(polilAux);
            //reinicializamos la polilínea a recortar
            polilClip = ReiniciaPolilClip(polilClip);
        }
        //liberamos la memoria asignada a la polilínea de esta vuelta del bucle
        LibMemPolilClip(polilClip);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return resultado;
}
/******************************************************************************/
/******************************************************************************/
polil* CreaPolilPolilClip(vertPolilClip* poli)
{
    //índice para recorrer bucles
    size_t i=0;
    //número de elementos
    size_t nVert=0,nElem=0;
    //estructura auxiliar
    vertPolilClip* aux=poli;
    //variable de salida
    polil* result=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //creamos la estructura vacía
    result = IniciaPolilVacia();
    //comprobamos los posibles errores
    if(result==NULL)
    {
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //contamos todos los vértices de la polilínea
    nVert = NumeroVertPolilClip(poli);
    //contemplamos una posible salida rápida
    if(nVert==0)
    {
        //devolvemos la estructura vacía
        return result;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //número de elementos de los vectores de coordenadas
    nElem = nVert+2;
    //asignamos memoria para los vectores de coordenadas de la estructura
    result->x = (double*)malloc(nElem*sizeof(double));
    result->y = (double*)malloc(nElem*sizeof(double));
    //asignamos memoria para los vectores de posición
    result->posIni = (size_t*)malloc(sizeof(size_t));
    result->nVert = (size_t*)malloc(sizeof(size_t));
    //comprobamos los posibles errores de asignación de memoria
    if((result->x==NULL)||(result->y==NULL)||(result->posIni==NULL)||
       (result->nVert==NULL))
    {
        //liberamos la posible memoria asignada
        LibMemPolil(result);
        //mensaje de error
        GEOC_ERROR("Error de asignación de memoria");
        //salimos de la función
        return NULL;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //asignamos el número de elementos de los vectores de coordenadas y de
    //polilíneas
    result->nElem = nElem;
    result->nPolil = 1;
    //asignamos la posición de inicio y el número de vértices
    result->posIni[0] = 1;
    result->nVert[0] = nVert;
    //asignamos los separadores de polilínea al principio y al final
    result->x[0] = GeocNan();
    result->y[0] = GeocNan();
    result->x[nElem-1] = GeocNan();
    result->y[nElem-1] = GeocNan();
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los vértices de la polilínea
    for(i=1;i<=nVert;i++)
    {
        //copio las coordenadas del vértice
        result->x[i] = aux->x;
        result->y[i] = aux->y;
        //siguiente vértice
        aux = aux->siguiente;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return result;
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

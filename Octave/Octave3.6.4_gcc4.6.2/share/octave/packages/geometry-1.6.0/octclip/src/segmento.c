/* -*- coding: utf-8 -*- */
/**
\ingroup geom
@{
\file segmento.c
\brief Definición de funciones para la realización de cálculos con segmentos.
\author José Luis García Pallero, jgpallero@gmail.com
\date 22 de abril de 2011
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
#include"libgeoc/segmento.h"
/******************************************************************************/
/******************************************************************************/
double PosPtoRecta2D(const double x,
                     const double y,
                     const double xIni,
                     const double yIni,
                     const double xFin,
                     const double yFin)
{
    //calculamos y salimos de la función
    return (xIni-x)*(yFin-y)-(xFin-x)*(yIni-y);
}
/******************************************************************************/
/******************************************************************************/
int TresPuntosColineales2D(const double xA,
                           const double yA,
                           const double xB,
                           const double yB,
                           const double xC,
                           const double yC)
{
    //variable de salida
    int colin=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //utilizamos la función de posición de punto con respecto a una recta,
    //aunque no es una función robusta
    //son colineales si el resultado es 0.0
    colin = (PosPtoRecta2D(xA,yA,xB,yB,xC,yC)==0.0) ? 1 : 0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return colin;
}
/******************************************************************************/
/******************************************************************************/
int PuntoEntreDosPuntos2DColin(const double x,
                               const double y,
                               const double xA,
                               const double yA,
                               const double xB,
                               const double yB)
{
    //código de salida
    int cod=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //distinguimos entre segmento vertical y no vertical
    if(xA!=xB)
    {
        //segmento no vertical, utilizamos las coordenadas X
        cod = ((xA<x)&&(x<xB))||((xA>x)&&(x>xB));
    }
    else
    {
        //segmento vertical, utilizamos las coordenadas Y
        cod = ((yA<y)&&(y<yB))||((yA>y)&&(y>yB));
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return cod;
}
/******************************************************************************/
/******************************************************************************/
int PtoComunSegmParalelos2D(const double xA,
                            const double yA,
                            const double xB,
                            const double yB,
                            const double xC,
                            const double yC,
                            const double xD,
                            const double yD,
                            double* x,
                            double* y)
{
    //variable de salida
    int cod=GEOC_SEG_NO_INTERSEC;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si los puntos son colineales
    if(!TresPuntosColineales2D(xA,yA,xB,yB,xC,yC))
    {
        //los segmentos son paralelos, pero no se cortan
        return GEOC_SEG_NO_INTERSEC;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si los segmentos son el mismo
    if(((xA==xC)&&(yA==yC)&&(xB==xD)&&(yB==yD))||
       ((xA==xD)&&(yA==yD)&&(xB==xC)&&(yB==yC)))
    {
        //coordenadas de salida
        *x = xA;
        *y = yA;
        //los segmentos son el mismo
        return GEOC_SEG_INTERSEC_MISMO_SEG;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si algún punto está entre medias del otro segmento
    if(PuntoEntreDosPuntos2DColin(xA,yA,xC,yC,xD,yD))
    {
        //el punto A está en el segmento CD
        *x = xA;
        *y = yA;
        //salimos
        return GEOC_SEG_INTERSEC_COLIN;
    }
    else if(PuntoEntreDosPuntos2DColin(xC,yC,xA,yA,xB,yB))
    {
        //el punto C está en el segmento AB
        *x = xC;
        *y = yC;
        //salimos
        return GEOC_SEG_INTERSEC_COLIN;
    }
    else if(PuntoEntreDosPuntos2DColin(xB,yB,xC,yC,xD,yD))
    {
        //el punto B está en el segmento CD
        *x = xB;
        *y = yB;
        //salimos
        return GEOC_SEG_INTERSEC_COLIN;
    }
    else if(PuntoEntreDosPuntos2DColin(xD,yD,xA,yA,xB,yB))
    {
        //el punto D está en el segmento AB
        *x = xD;
        *y = yD;
        //salimos
        return GEOC_SEG_INTERSEC_COLIN;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si sólo comparten el extremo A
    if(((xA==xC)&&(yA==yC))||((xA==xD)&&(yA==yD)))
    {
        //coordenadas de salida
        *x = xA;
        *y = yA;
        //los segmentos comparten un extremo
        return GEOC_SEG_INTERSEC_EXTREMO_COLIN;
    }
    //comprobamos si sólo comparten el extremo B
    if(((xB==xC)&&(yB==yC))||((xB==xD)&&(yB==yD)))
    {
        //coordenadas de salida
        *x = xB;
        *y = yB;
        //los segmentos comparten un extremo
        return GEOC_SEG_INTERSEC_EXTREMO_COLIN;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return cod;
}
/******************************************************************************/
/******************************************************************************/
int IntersecSegmentos2D(const double xA,
                        const double yA,
                        const double xB,
                        const double yB,
                        const double xC,
                        const double yC,
                        const double xD,
                        const double yD,
                        double* x,
                        double* y)
{
    //parámetros de las ecuaciones
    double s=0.0,t=0.0,num=0.0,den=0.0;
    //variable de salida
    int cod=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si los rectángulos que encierran a los segmentos son disjuntos
    if(RectDisjuntos(GEOC_MIN(xA,xB),GEOC_MAX(xA,xB),GEOC_MIN(yA,yB),
                     GEOC_MAX(yA,yB),GEOC_MIN(xC,xD),GEOC_MAX(xC,xD),
                     GEOC_MIN(yC,yD),GEOC_MAX(yC,yD)))
    {
        //si los rectángulos son disjuntos, los segmentos no se tocan
        cod = GEOC_SEG_NO_INTERSEC;
        //salimos de la función
        return cod;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el denominador
    den = xA*(yD-yC)+xB*(yC-yD)+xD*(yB-yA)+xC*(yA-yB);
    //si el denominador es 0.0, los segmentos son paralelos
    if(den==0.0)
    {
        //calculamos el punto común
        cod = PtoComunSegmParalelos2D(xA,yA,xB,yB,xC,yC,xD,yD,x,y);
        //salimos de la función
        return cod;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el numerador
    num = xA*(yD-yC)+xC*(yA-yD)+xD*(yC-yA);
    //un extremo de un segmento puede estar encima del otro segmento, pero los
    //segmentos no son colineales
    if((num==0.0)||(num==den))
    {
        //asignamos la variable de salida
        cod = GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN;
    }
    //calculamos el parámetro s
    s = num/den;
    //calculamos de nuevo el numerador
    num = -(xA*(yC-yB)+xB*(yA-yC)+xC*(yB-yA));
    //un extremo de un segmento puede estar encima del otro segmento, pero los
    //segmentos no son colineales
    if((num==0.0)||(num==den))
    {
        //asignamos la variable de salida
        cod = GEOC_SEG_INTERSEC_EXTREMO_NO_COLIN;
    }
    //calculamos el parámetro t
    t = num/den;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //comprobamos si estamos ante una intersección pura y dura o los segmentos
    //no se cortan
    if((s>0.0)&&(s<1.0)&&(t>0.0)&&(t<1.0))
    {
        //asignamos la variable de salida
        cod = GEOC_SEG_INTERSEC;
    }
    else if((s<0.0)||(s>1.0)||(t<0.0)||(t>1.0))
    {
        //asignamos la variable de salida
        cod = GEOC_SEG_NO_INTERSEC;
    }
    //calculamos las coordenadas del punto intersección
    *x = xA+s*(xB-xA);
    *y = yA+s*(yB-yA);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return cod;
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

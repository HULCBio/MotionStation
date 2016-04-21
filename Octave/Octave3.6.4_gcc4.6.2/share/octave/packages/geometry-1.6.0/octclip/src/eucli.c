/* -*- coding: utf-8 -*- */
/**
\ingroup geom interp
@{
\file eucli.c
\brief Definición de funciones para la realización de cálculos de geometría
       euclídea.
\author José Luis García Pallero, jgpallero@gmail.com
\date 27 de octubre de 2009
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
#include"libgeoc/eucli.h"
/******************************************************************************/
/******************************************************************************/
double Dist2D(const double x1,
              const double y1,
              const double x2,
              const double y2)
{
    //calculamos y salimos de la función
    return sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
}
/******************************************************************************/
/******************************************************************************/
void Dist2DVC(const double x1,
              const double y1,
              const double x2,
              const double y2,
              const double varx1,
              const double varx1y1,
              const double vary1,
              const double varx2,
              const double varx2y2,
              const double vary2,
              double* dist,
              double* varDist)
{
    //matrices auxiliares
    double j[4],jvc[4];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos la distancia
    *dist = Dist2D(x1,y1,x2,y2);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //rellenamos la matriz jacobiana
    j[0] = -(x2-x1)/(*dist);
    j[1] = -(y2-y1)/(*dist);
    j[2] = -j[0];
    j[3] = -j[1];
    //producto de la matriz jacobiana por la matriz de varianza-covarianza
    jvc[0] = j[0]*varx1+j[1]*varx1y1;
    jvc[1] = j[0]*varx1y1+j[1]*vary1;
    jvc[2] = j[2]*varx2+j[3]*varx2y2;
    jvc[3] = j[2]*varx2y2+j[3]*vary2;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //realizamos la propagación de errores
    *varDist = jvc[0]*j[0]+jvc[1]*j[1]+jvc[2]*j[2]+jvc[3]*j[3];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
double Dist3D(const double x1,
              const double y1,
              const double z1,
              const double x2,
              const double y2,
              const double z2)
{
    //calculamos y salimos de la función
    return sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1));
}
/******************************************************************************/
/******************************************************************************/
void Dist3DVC(const double x1,
              const double y1,
              const double z1,
              const double x2,
              const double y2,
              const double z2,
              const double varx1,
              const double varx1y1,
              const double varx1z1,
              const double vary1,
              const double vary1z1,
              const double varz1,
              const double varx2,
              const double varx2y2,
              const double varx2z2,
              const double vary2,
              const double vary2z2,
              const double varz2,
              double* dist,
              double* varDist)
{
    //matrices auxiliares
    double j[6],jvc[6];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos la distancia
    *dist = Dist3D(x1,y1,z1,x2,y2,z2);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //rellenamos la matriz jacobiana
    j[0] = -(x2-x1)/(*dist);
    j[1] = -(y2-y1)/(*dist);
    j[2] = -(z2-z1)/(*dist);
    j[3] = -j[0];
    j[4] = -j[1];
    j[5] = -j[2];
    //producto de la matriz jacobiana por la matriz de varianza-covarianza
    jvc[0] = j[0]*varx1+j[1]*varx1y1+j[2]*varx1z1;
    jvc[1] = j[0]*varx1y1+j[1]*vary1+j[2]*vary1z1;
    jvc[2] = j[0]*varx1z1+j[1]*vary1z1+j[2]*varz1;
    jvc[3] = j[3]*varx2+j[4]*varx2y2+j[5]*varx2z2;
    jvc[4] = j[3]*varx2y2+j[4]*vary2+j[5]*vary2z2;
    jvc[5] = j[3]*varx2z2+j[4]*vary2z2+j[5]*varz2;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //realizamos la propagación de errores
    *varDist = jvc[0]*j[0]+jvc[1]*j[1]+jvc[2]*j[2]+jvc[3]*j[3]+jvc[4]*j[4]+
               jvc[5]*j[5];
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
double AnguloVecPlano(const double x1,
                      const double y1,
                      const double x2,
                      const double y2)
{
    //variables auxiliares
    double num=0.0,den=0.0;
    //variable de salida
    double alfa=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el numerador de la fórmula que da el coseno del ángulo
    num = x1*x2+y1*y2;
    //calculamos el denominador de la fórmula que da el coseno del ángulo
    den = sqrt((x1*x1+y1*y1)*(x2*x2+y2*y2));
    //calculamos el coseno del ángulo, teniendo en cuenta casos singulares
    if(den==0.0)
    {
        //si el denominador es 0.0, el ángulo es 0.0 y su coseno 1.0
        alfa = 1.0;
    }
    else
    {
        //no hay singularidad
        alfa = num/den;
    }
    //calculamos el ángulo
    alfa = acos(alfa);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return alfa;
}
/******************************************************************************/
/******************************************************************************/
double AlturaTriangulo(const double xVert,
                       const double yVert,
                       const double xBase1,
                       const double yBase1,
                       const double xBase2,
                       const double yBase2)
{
    //ángulo entra la base en el punto 1 y el vértice
    double alfa=0.0;
    //longitud del punto 1 de la base al vértice
    double lon=0.0;
    //variables auxiliares
    double dxv=0.0,dyv=0.0,dxb=0.0,dyb=0.0;
    //variable de salida
    double h=0.0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos los incrementos de coordenadas auxiliares
    dxv = xVert-xBase1;
    dyv = yVert-yBase1;
    dxb = xBase2-xBase1;
    dyb = yBase2-yBase1;
    //calculamos el ángulo entre la base y el segmento que une el punto inicial
    //de ésta con el vértice
    alfa = AnguloVecPlano(dxv,dyv,dxb,dyb);
    //longitud del lado que une la base con el vértice 1 de la base
    lon = sqrt(dxv*dxv+dyv*dyv);
    //calculamos la altura
    h = fabs(lon*sin(alfa));
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return h;
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

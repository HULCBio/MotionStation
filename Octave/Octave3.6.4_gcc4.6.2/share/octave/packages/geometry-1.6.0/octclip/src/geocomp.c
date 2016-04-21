/* -*- coding: utf-8 -*- */
/**
\ingroup anespec general geocomp geodesia geom geopot gravim mmcc
@{
\file geocomp.c
\brief Definición de funciones para la obtención de información de la
       implementación de OpenMP usada.
\author José Luis García Pallero, jgpallero@gmail.com
\date 25 de agosto de 2011
\version 1.0
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
#include"libgeoc/geocomp.h"
/******************************************************************************/
/******************************************************************************/
void VersionOpenMP(const int macro_OPENMP,
                   char version[])
{
    //vamos comprobando los valores de la macro
    if(macro_OPENMP==GEOC_OMP_F_1_0)
    {
        //versión 1.0
        strcpy(version,GEOC_OMP_V_1_0);
    }
    else if(macro_OPENMP==GEOC_OMP_F_2_0)
    {
        //versión 2.0
        strcpy(version,GEOC_OMP_V_2_0);
    }
    else if(macro_OPENMP==GEOC_OMP_F_2_5)
    {
        //versión 2.5
        strcpy(version,GEOC_OMP_V_2_5);
    }
    else if(macro_OPENMP==GEOC_OMP_F_3_0)
    {
        //versión 3.0
        strcpy(version,GEOC_OMP_V_3_0);
    }
    else if(macro_OPENMP==GEOC_OMP_F_3_1)
    {
        //versión 3.1
        strcpy(version,GEOC_OMP_V_3_1);
    }
    else
    {
        //versión desconocida
        strcpy(version,GEOC_OMP_V_DESC);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
int FechaVersionOpenMP(const char version[])
{
    //variable de salida
    int fecha=GEOC_OMP_F_DESC;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //vamos comprobando los valores de la versión
    if(!strcmp(version,GEOC_OMP_V_1_0))
    {
        //versión 1.0
        fecha = GEOC_OMP_F_1_0;
    }
    else if(!strcmp(version,GEOC_OMP_V_2_0))
    {
        //versión 2.0
        fecha = GEOC_OMP_F_2_0;
    }
    else if(!strcmp(version,GEOC_OMP_V_2_5))
    {
        //versión 2.5
        fecha = GEOC_OMP_F_2_5;
    }
    else if(!strcmp(version,GEOC_OMP_V_3_0))
    {
        //versión 3.0
        fecha = GEOC_OMP_F_3_0;
    }
    else if(!strcmp(version,GEOC_OMP_V_3_1))
    {
        //versión 3.1
        fecha = GEOC_OMP_F_3_1;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return fecha;
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

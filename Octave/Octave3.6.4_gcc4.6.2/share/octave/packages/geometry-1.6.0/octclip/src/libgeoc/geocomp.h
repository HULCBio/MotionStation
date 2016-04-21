/* -*- coding: utf-8 -*- */
/**
\defgroup geocomp Módulo GEOC-OMP
\ingroup anespec general geodesia geom geopot gravim mmcc
\brief En este módulo se reúnen constantes y funciones para la obtención de
       información de la implementación de OpenMP usada.
@{
\file geocomp.h
\brief Declaración de macros y funciones para la obtención de información de la
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
#ifndef _GEOCOMP_H_
#define _GEOCOMP_H_
/******************************************************************************/
/******************************************************************************/
#include<string.h>
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_F_1_0
\brief Valor (fecha YYYYMM) de la macro \p _OPENMP para la versión 1.0 de
       OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_F_1_0 (199810)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_F_2_0
\brief Valor (fecha YYYYMM) de la macro \p _OPENMP para la versión 2.0 de
       OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_F_2_0 (200203)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_F_2_5
\brief Valor (fecha YYYYMM) de la macro \p _OPENMP para la versión 2.5 de
       OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_F_2_5 (200505)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_F_3_0
\brief Valor (fecha YYYYMM) de la macro \p _OPENMP para la versión 3.0 de
       OpenMP.
\date 22 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_F_3_0 (200805)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_F_3_1
\brief Valor (fecha YYYYMM) de la macro \p _OPENMP para la versión 3.1 de
       OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_F_3_1 (201107)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_V_1_0
\brief Cadena de texto identificadora de la versión 1.0 de OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_V_1_0 "1.0"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_V_2_0
\brief Cadena de texto identificadora de la versión 2.0 de OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_V_2_0 "2.0"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_V_2_5
\brief Cadena de texto identificadora de la versión 2.5 de OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_V_2_5 "2.5"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_V_3_0
\brief Cadena de texto identificadora de la versión 3.0 de OpenMP.
\date 22 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_V_3_0 "3.0"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_V_3_1
\brief Cadena de texto identificadora de la versión 3.1 de OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_V_3_1 "3.1"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_F_DESC
\brief Fecha de versión de OpenMP desconocida.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_F_DESC (0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_V_DESC
\brief Versión de OpenMP correspondiente a un valor desconocido de la macro
       \p _OPENMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_V_DESC "0.0"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_OMP_LON_CAD_VERS
\brief Longitud de la cadena de texto que almacena la versión de OpenMP.
\date 25 de agosto de 2011: Creación de la constante.
*/
#define GEOC_OMP_LON_CAD_VERS (10)
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la versión de OpenMP a partir del valor de la macro \p _OPENMP.
\param[in] macro_OPENMP Valor de la macro \p _OPENMP.
\param[out] version Versión de OpenMP correspondiente al valor de la macro. Si
            el argumento \em macro_OPENMP almacena un valor desconocido, se
            devuelve #GEOC_OMP_V_DESC.
\note Esta función asume que \em version tiene asignada suficiente memoria: como
      mínimo, espacio para una cadena de #GEOC_OMP_LON_CAD_VERS carácteres.
\date 25 de agosto de 2011: Creación de la función.
*/
void VersionOpenMP(const int macro_OPENMP,
                   char version[]);
/******************************************************************************/
/******************************************************************************/
/**
\brief Calcula la fecha (el valor de la macro \p _OPENMP) de una versión de
       OpenMP dada.
\param[in] version Cadena de versión de OpenMP, tal como es calculada por la
           función \ref VersionOpenMP.
\return Fecha, en el formato YYYYMM, correspondiente a la versión. Este valor
        debería coincidir con la macro \p _OPENMP de la implementación de OpenMP
        usada.
\note En caso de pasar una cadena de versión errónea o desconocida, la función
      devuelve #GEOC_OMP_F_DESC.
\date 25 de agosto de 2011: Creación de la función.
*/
int FechaVersionOpenMP(const char version[]);
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

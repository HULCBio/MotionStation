/* -*- coding: utf-8 -*- */
/**
\ingroup anespec astro eop general geodesia geom gravim marea
@{
\file constantes.h
\brief Definición de constantes generales.
\author José Luis García Pallero, jgpallero@gmail.com
\date 02 de marzo de 2009
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
#ifndef _CONSTANTES_H_
#define _CONSTANTES_H_
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\typedef geoc_char
\brief Nombre del tipo \p char para almacenar números en \p libgeoc.

       Se declara este tipo para dotar de portabilidad a la biblioteca, debido a
       que en algunas implementaciones de C la declaración \p char a secas
       corresponde a un tipo \p unsigned \p char en lugar de a un \p signed
       \p char, que es el que necesita \p libgeoc cuando almacena un número en
       un \p char. En la implementación de \p gcc para PowerPC, por ejemplo, el
       tipo por defecto de un \p char es \p unsigned \p char, lo que hace que se
       produzcan errores al intentar almacenar números negativos.
\date 02 de marzo de 2009: Creación del tipo.
*/
typedef signed char geoc_char;
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_PI
\brief Constante \em PI. Tomada del fichero \p gsl_math.h, de la biblioteca GSL.
\date 02 de marzo de 2009: Creación de la constante.
*/
#define GEOC_CONST_PI (3.14159265358979323846264338328)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_E
\brief Constante \em e (base de los logaritmos naturales). Tomada del fichero
       \p gsl_math.h, de la biblioteca GSL.
\date 03 de octubre de 2010: Creación de la constante.
*/
#define GEOC_CONST_E (2.71828182845904523536028747135)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_GR
\brief Paso de grados centesimales a radianes.
*/
#define GEOC_CONST_GR ((GEOC_CONST_PI)/200.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_RG
\brief Paso de radianes a grados centesimales.
\date 02 de marzo de 2009: Creación de la constante.
*/
#define GEOC_CONST_RG (1.0/(GEOC_CONST_GR))
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_DR
\brief Paso de grados sexagesimales en formato decimal a radianes.
\date 02 de marzo de 2009: Creación de la constante.
*/
#define GEOC_CONST_DR ((GEOC_CONST_PI)/180.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_RD
\brief Paso de radianes a grados sexagesimales en formato decimal.
\date 02 de marzo de 2009: Creación de la constante.
*/
#define GEOC_CONST_RD (1.0/(GEOC_CONST_DR))
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_SIMUGAL
\brief Paso de atracción gravitatoria en el SI (m/s^2) a microgales.
\date 05 de noviembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_SIMUGAL (1.0e8)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_MJD
\brief Constante a sustraer a una fecha juliana (en días) para convertirla en
       fecha juliana modificada (MJD).
\date 04 de octubre de 2009: Creación de la constante.
*/
#define GEOC_CONST_MJD (2400000.5)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_J2000
\brief Constante a sustraer a una fecha juliana (en días) para convertirla en
       fecha juliana referida a J2000.
\date 01 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_J2000 (2451545.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_JISGPS
\brief Fecha juliana del día de inicio de las semanas GPS: 6 de enero de 1980,
       00:00:00 horas.
\date 02 de marzo de 2010: Creación de la constante.
*/
#define GEOC_CONST_JISGPS (2444244.5)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_MIN_HORA
\brief Número de minutos que contiene una hora.
\date 19 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_MIN_HORA (60.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_SEG_HORA
\brief Número de segundos que contiene una hora.
\date 01 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_SEG_HORA (3600.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_SEG_MIN
\brief Número de segundos que contiene un minuto
\date 19 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_SEG_MIN (60.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_SEG_DIA
\brief Número de segundos que contiene un día.
\date 24 de octubre de 2009: Creación de la constante.
*/
#define GEOC_CONST_SEG_DIA (86400.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_HORAS_DIA
\brief Número de horas que contiene un día.
\date 01 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_HORAS_DIA (24.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_DIAS_SIGLO_JUL
\brief Número de días que contiene un siglo juliano.
\date 01 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_DIAS_SIGLO_JUL (36525.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_DIAS_SEMANA
\brief Número de días que contiene una semana.
\date 02 de marzo de 2010: Creación de la constante.
*/
#define GEOC_CONST_DIAS_SEMANA (7.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_DIAS_ANYO_NORM
\brief Número de días que contiene un año normal.
\date 02 de marzo de 2010: Creación de la constante.
*/
#define GEOC_CONST_DIAS_ANYO_NORM (365.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_DIAS_ANYO_BIS
\brief Número de días que contiene un año bisiesto.
\date 02 de marzo de 2010: Creación de la constante.
*/
#define GEOC_CONST_DIAS_ANYO_BIS ((GEOC_CONST_DIAS_ANYO_NORM)+1.0)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_CPD_RH
\brief Paso de ciclos por día a radianes por hora.
\date 20 de diciembre de 2009: Creación de la constante.
 */
#define GEOC_CONST_CPD_RH (2.0*(GEOC_CONST_PI)/(GEOC_CONST_HORAS_DIA))
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_RH_CPD
\brief Paso de radianes por hora a ciclos por día.
\date 20 de diciembre de 2009: Creación de la constante.
 */
#define GEOC_CONST_RH_CPD (1.0/(GEOC_CONST_CPD_RH))
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_G
\brief Constante de gravitación universal, en m^3/(kg*s^2).
\date 04 de noviembre de 2009: Creación de la constante.
*/
#define GEOC_CONST_G (6.67428e-11)
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_CONST_VRT
\brief Velocidad de rotación de la Tierra, en radianes/s.
\date 21 de enero de 2011: Creación de la constante.
*/
#define GEOC_CONST_VRT (7.292115e-5)
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

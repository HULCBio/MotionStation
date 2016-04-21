/* -*- coding: utf-8 -*- */
/**
\defgroup errores Módulo ERRORES
\ingroup anespec eop fichero geodesia geom general geopot gshhs marea matriz
\ingroup mmcc orden snx texto
\brief En este módulo se reúnen los ficheros necesarios para realizar el
       tratamiento de errores que puedan ocurrir en la biblioteca.
@{
\file errores.h
\brief Declaración de funciones y constantes para el tratamiento de errores.

En el momento de la compilación ha de seleccionarse el comportamiento de la
función \ref GeocError. Para realizar la selección es necesario definir las
variables para el preprocesador \em ESCRIBE_MENSAJE_ERROR si se quiere que la
función imprima un mensaje de error y/o \em FIN_PROGRAMA_ERROR si se quiere que
la función termine la ejecución del programa en curso. Si no se define ninguna
variable, la función no ejecuta ninguna acción. En \p gcc, las variables para el
preprocesador se pasan como \em -DXXX, donde \em XXX es la variable a
introducir.
\author José Luis García Pallero, jgpallero@gmail.com
\date 06 de marzo de 2009
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
#include<stdio.h>
#include<stdlib.h>
/******************************************************************************/
/******************************************************************************/
#ifndef _ERRORES_H_
#define _ERRORES_H_
/******************************************************************************/
/******************************************************************************/
//GENERAL
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_PLINEA
\brief Palabra \em Línea para ser utilizada en el mensaje que imprime la macro
       #GEOC_ERROR. Esta constante se define porque el preprocesador del
       compilador \p pgcc no soporta letras con tilde escritas directamente en
       las órdenes a ejecutar por las macros.
\date 10 de enero de 2011: Creación de la constante.
*/
#define GEOC_PLINEA "Línea"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_TIPO_ERR_NADA
\brief Indicador de que la función \ref GeocError no hace nada.
\date 09 de enero de 2011: Creación de la constante.
*/
#define GEOC_TIPO_ERR_NADA 0
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_TIPO_ERR_MENS_Y_EXIT
\brief Indicador de que la función \ref GeocError imprime un mensaje descriptivo
       en la salida de error \em stderr y termina la ejecución del programa en
       curso.
\date 09 de enero de 2011: Creación de la constante.
*/
#define GEOC_TIPO_ERR_MENS_Y_EXIT 1
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_TIPO_ERR_MENS
\brief Indicador de que la función \ref GeocError imprime un mensaje descriptivo
       en la salida de error \em stderr y no termina la ejecución del programa
       en curso.
\date 09 de enero de 2011: Creación de la constante.
*/
#define GEOC_TIPO_ERR_MENS 2
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_TIPO_ERR_EXIT
\brief Indicador de que la función \ref GeocError termina la ejecución del
       programa en curso.
\date 09 de enero de 2011: Creación de la constante.
*/
#define GEOC_TIPO_ERR_EXIT 3
/******************************************************************************/
/******************************************************************************/
/**
\brief Indica el tipo de acción que realiza la función \ref GeocError.
\return Cuatro posibles valores:
        - #GEOC_TIPO_ERR_NADA: La función \ref GeocError no hace nada.
        - #GEOC_TIPO_ERR_MENS_Y_EXIT: La función \ref GeocError imprime un
          mensaje descriptivo en la salida de error \em stderr y termina la
          ejecución del programa en curso.
        - #GEOC_TIPO_ERR_MENS: La función \ref GeocError imprime un mensaje
          descriptivo en la salida de error \em stderr y no detiene la ejecución
          del programa en curso.
        - #GEOC_TIPO_ERR_EXIT: La función \ref GeocError detiene la ejecución
          del programa en curso.
\date 09 de enero de 2011: Creación de la función.
*/
int GeocTipoError(void);
/******************************************************************************/
/******************************************************************************/
/**
\brief Imprime un mensaje en la salida de error \em stderr y/o sale del programa
       en ejecución.
\param[in] mensaje Cadena de texto a imprimir.
\param[in] funcion Nombre de la función desde donde se ha invocado a esta
           función.
\note Si este fichero se compila con las variables para el preprocesador
      \em ESCRIBE_MENSAJE_ERROR y \em FIN_PROGRAMA_ERROR, esta función imprime
      el mensaje de error y termina la ejecución del programa en curso mediante
      la llamada a la función \em exit(EXIT_FAILURE), de la biblioteca estándar
      de C.
\note Si este fichero se compila con la variable para el preprocesador
      \em ESCRIBE_MENSAJE_ERROR, esta función imprime el mensaje de error.
\note Si este fichero se compila con la variable para el preprocesador
      \em FIN_PROGRAMA_ERROR, esta función termina la ejecución del programa en
      curso mediante la llamada a la función \em exit(EXIT_FAILURE), de la
      biblioteca estándar de C.
\note Si este fichero se compila sin variables para el preprocesador, esta
      función no hace nada.
\date 10 de enero de 2011: Creación de la función.
*/
void GeocError(const char mensaje[],
               const char funcion[]);
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERROR
\brief Macro para imprimir un mensaje en la salida de error \em stderr y/o sale
       del programa en ejecución.
\param[in] mensaje Cadena de texto a imprimir.
\note Esta macro llama internamente a la función \ref GeocError.
\note Esta macro pasa como argumento \em funcion a \ref GeocError la variable
      del preprocesador \em __func__, de C99.
\date 10 de enero de 2011: Creación de la macro.
*/
#define GEOC_ERROR(mensaje) \
{ \
    if(GeocTipoError()!=GEOC_TIPO_ERR_NADA) \
    { \
        fprintf(stderr,"\n\n"); \
        fprintf(stderr,"********************\n********************\n"); \
        fprintf(stderr,GEOC_PLINEA" %d del fichero '%s'\n",__LINE__,__FILE__); \
        GeocError(mensaje,(const char*)__func__); \
        fprintf(stderr,"********************\n********************\n\n"); \
    } \
    else \
    { \
        GeocError(mensaje,(const char*)__func__); \
    } \
}
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//GENERAL
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_NO_ERROR
\brief Indicador de que no ha ocurrido ningun error.
\date 06 de marzo de 2009: Creación de la constante.
*/
#define GEOC_ERR_NO_ERROR 0
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_LECTURA_FICHERO
\brief Indicador de que ha ocurrido un error en la lectura de un fichero.
\date 06 de marzo de 2009: Creación de la constante.
*/
#define GEOC_ERR_LECTURA_FICHERO 1001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_ESCRITURA_FICHERO
\brief Indicador de que ha ocurrido un error en escritura de un fichero.
\date 20 de agosto de 2009: Creación de la constante.
*/
#define GEOC_ERR_ESCRITURA_FICHERO 1002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_QUEDAN_DATOS_EN_FICHERO
\brief Indicador de que quedan datos por leer en un fichero.
\date 06 de marzo de 2009: Creación de la constante.
*/
#define GEOC_ERR_QUEDAN_DATOS_EN_FICHERO 1003
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_NO_QUEDAN_DATOS_EN_FICHERO
\brief Indicador de que no quedan datos por leer en un fichero.
\date 25 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_NO_QUEDAN_DATOS_EN_FICHERO 1004
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_NO_HAY_DATOS_EN_FICHERO
\brief Indicador de que no hay datos a leer en un fichero.
\date 02 de diciembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_NO_HAY_DATOS_EN_FICHERO 1005
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_LINEA_LARGA_EN_FICHERO
\brief Indicador de que una línea de un fichero es demasiado larga.
\date 23 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_LINEA_LARGA_EN_FICHERO 1006
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_LINEA_CORTA_EN_FICHERO
\brief Indicador de que una línea de un fichero es demasiado corta.
\date 23 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_LINEA_CORTA_EN_FICHERO 1007
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_ARG_ENTRADA_INCORRECTO
\brief Indicador de que un argumento de entrada de una función es incorrecto.
\date 06 de marzo de 2009: Creación de la constante.
*/
#define GEOC_ERR_ARG_ENTRADA_INCORRECTO 1008
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_ASIG_MEMORIA
\brief Indicador de que ha ocurrido un error en la asignación de memoria.
\date 06 de marzo de 2009: Creación de la constante.
*/
#define GEOC_ERR_ASIG_MEMORIA 1009
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_FUERA_DOMINIO
\brief Indicador de que ha ocurrido un error porque un dato está fuera de
       dominio.
\date 04 de octubre de 2009: Creación de la constante.
*/
#define GEOC_ERR_FUERA_DOMINIO 1010
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_FUERA_DOMINIO_MAYOR
\brief Indicador de que ha ocurrido un error porque un dato está fuera de
       dominio. En este caso, el dato se sale del dominio por arriba (porque es
       demasiado grande).
\date 26 de octubre de 2009: Creación de la constante.
*/
#define GEOC_ERR_FUERA_DOMINIO_MAYOR 1011
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_FUERA_DOMINIO_MENOR
\brief Indicador de que ha ocurrido un error porque un dato está fuera de
       dominio. En este caso, el dato se sale del dominio por abajo (porque es
       demasiado pequeño).
\date 26 de octubre de 2009: Creación de la constante.
*/
#define GEOC_ERR_FUERA_DOMINIO_MENOR 1012
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_INTERP
\brief Indicador de que ha ocurrido un error en una interpolación.
\date 15 de mayo de 2010: Creación de la constante.
*/
#define GEOC_ERR_INTERP 1013
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_INTERP_NO_DATO
\brief Indicador de que no hay datos para realizar una interpolación.
\date 30 de mayo de 2010: Creación de la constante.
*/
#define GEOC_ERR_INTERP_NO_DATO 1014
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_DIV_ENTRE_CERO
\brief Indicador de que se ha realizado una división entre cero.
\date 26 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_DIV_ENTRE_CERO 1015
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_DIM_MATRIZ
\brief Indicador de dimensiones de una matriz erróneas.
\date 02 de diciembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_DIM_MATRIZ 1016
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_MATRIZ_SINGULAR
\brief Indicador de matriz singular.
\date 12 de marzo de 2011: Creación de la constante.
*/
#define GEOC_ERR_MATRIZ_SINGULAR 1017
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//EOP
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_EOP_ERRORES
\brief Indicador de que ha ocurrido un error porque una estructura eop no
       contiene información de errores.
\date 04 de octubre de 2009: Creación de la constante.
*/
#define GEOC_ERR_EOP_ERRORES 2001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_EOP_DOS_PUNTOS
\brief Indicador de que ha ocurrido un error porque en una interpolación
       cuadrática sólo hay dos puntos disponibles.
\date 12 de octubre de 2009: Creación de la constante.
*/
#define GEOC_ERR_EOP_DOS_PUNTOS 2002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_EOP_NO_DATOS
\brief Indicador de que una estructura eop no contiene datos.
\date 19 de junio de 2010: Creación de la constante.
*/
#define GEOC_ERR_EOP_NO_DATOS 2003
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//SINEX
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_LINEA_ILEGAL
\brief Indicador de que una línea de un fichero SINEX no comienza por una de las
       cadenas permitidas (#GEOC_SNX_CAD_COMENTARIO, #GEOC_SNX_CAD_INI_CABECERA,
       #GEOC_SNX_CAD_INI_BLOQUE, #GEOC_SNX_CAD_FIN_BLOQUE o
       #GEOC_SNX_CAD_INI_DATOS).
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_LINEA_ILEGAL 3001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_LINEA_LARGA
\brief Indicador de que una línea de un fichero SINEX es demasiado larga (más de
       #GEOC_SNX_LON_MAX_LIN_FICH carácteres).
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_LINEA_LARGA 3002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_LINEA_CORTA
\brief Indicador de que una línea de un fichero SINEX es demasiado corta.
\date 29 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_LINEA_CORTA 3003
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_NO_BLOQUES
\brief Indicador de que en un fichero SINEX no hay bloques válidos.
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_NO_BLOQUES 3004
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_ID_BLOQUE_DISTINTO
\brief Indicador de que en un fichero SINEX los identificadores de bloque tras
       las marcas de inicio y fin son distintos.
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_ID_BLOQUE_DISTINTO 3005
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BLOQUE_NO_INICIO
\brief Indicador de que en un fichero SINEX un bloque no tiene identificador de
       inicio.
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_BLOQUE_NO_INICIO 3006
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BLOQUE_NO_FIN
\brief Indicador de que en un fichero SINEX un bloque no tiene identificador de
       fin.
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_BLOQUE_NO_FIN 3007
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_NO_FIN_FICH
\brief Indicador de que un fichero SINEX no tiene indicador de fin de fichero.
\date 28 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_NO_FIN_FICH 3008
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_NO_ID_CABECERA
\brief Indicador de que un fichero SINEX no tiene indicador cabecera.
\date 29 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_NO_ID_CABECERA 3009
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_FORMATO_CABECERA
\brief Indicador de que un fichero SINEX tiene una cabecera que no respeta el
       formato.
\date 29 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_FORMATO_CABECERA 3010
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_CODFICH_INC
\brief Indicador de que un fichero SINEX tiene un indicador de código de tipo de
       fichero incorrecto.
\date 05 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_CODFICH_INC 3011
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_TIPODOC_INC
\brief Indicador de que un fichero SINEX tiene un indicador de tipo de documento
       incorrecto.
\date 05 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_TIPODOC_INC 3012
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_VERS_INC
\brief Indicador de que un fichero SINEX tiene un indicador de versión
       incorrecto.
\date 30 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_VERS_INC 3013
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_FECHA_INC
\brief Indicador de que una fecha es incorrecta en un fichero SINEX.
\date 30 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_FECHA_INC 3014
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_CODOBS_INC
\brief Indicador de que el código de observación es incorrecto en un fichero
       SINEX.
\date 30 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_CODOBS_INC 3015
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_CODCONSTR_INC
\brief Indicador de que el código de constreñimiento es incorrecto en un fichero
       SINEX.
\date 30 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_CODCONSTR_INC 3016
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_SOLCONT_INC
\brief Indicador de que un código de solución contenida en un fichero SINEX es
       incorrecto.
\date 31 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_SOLCONT_INC 3017
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_NSOLCONT_INC
\brief Indicador de que un código de solución contenida en un fichero SINEX es
       incorrecto.
\date 31 de diciembre de 2009: Creación de la constante.
*/
#define GEOC_ERR_SNX_NSOLCONT_INC 3018
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_FORM_LINEA_INC
\brief Indicador de que una línea de un fichero SINEX tiene un formato
       incorrecto.
\date 01 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_FORM_LINEA_INC 3019
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BFR_TIPOINF_INC
\brief Indicador de que el código de tipo de información de un bloque
       FILE/REFERENCE de un fichero SINEX es incorrecto.
\date 01 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BFR_TIPOINF_INC 3020
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BND_CODNUT_INC
\brief Indicador de que el código de modelo de nutación de un bloque
       NUTATION/DATA de un fichero SINEX es incorrecto.
\date 03 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BND_CODNUT_INC 3021
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BPD_CODPREC_INC
\brief Indicador de que el código de modelo de precesión de un bloque
       PRECESSION/DATA de un fichero SINEX es incorrecto.
\date 03 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BPD_CODPREC_INC 3022
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSII_GRADLATSEX_INC
\brief Indicador de que un valor de grados sexagesimales de latitud de un bloque
       SITE/ID de un fichero SINEX es incorrecto.
\date 15 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSII_GRADLATSEX_INC 3023
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSII_GRADLONSEX_INC
\brief Indicador de que un valor de grados sexagesimales de longitud de un bloque
       SITE/ID de un fichero SINEX es incorrecto.
\date 15 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSII_GRADLONSEX_INC 3024
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSII_MINSEX_INC
\brief Indicador de que un valor de minutos sexagesimales de un bloque SITE/ID
       de un fichero SINEX es incorrecto.
\date 15 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSII_MINSEX_INC 3025
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSII_SEGSEX_INC
\brief Indicador de que un valor de segundos sexagesimales de un bloque SITE/ID
       de un fichero SINEX es incorrecto.
\date 15 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSII_SEGSEX_INC 3026
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSE_CODSREX_INC
\brief Indicador de que un código del sistema de referencia utilizado para
       definir la excentricidad de una antena de un bloque SITE/ECCENTRICITY de
       un fichero SINEX es incorrecto.
\date 23 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSE_CODSREX_INC 3027
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_CODGNSS_INC
\brief Indicador de que un código de constelación GNSS utilizado en un fichero
       SINEX es incorrecto.
\date 28 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_CODGNSS_INC 3028
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSAP_CODFREC_INC
\brief Indicador de que un código frecuencia de satélite GNSS de un bloque
       SATELLITE/PHASE_CENTER de un fichero SINEX es incorrecto.
\date 28 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSAP_CODFREC_INC 3029
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSAP_TIPOPCV_INC
\brief Indicador de que un código indicador de tipo de variación del centro de
       fase de un bloque SATELLITE/PHASE_CENTER de un fichero SINEX es
       incorrecto.
\date 28 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSAP_TIPOPCV_INC 3030
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSAP_MODAPPCV_INC
\brief Indicador de que un código indicador de modelo de aplicación de las
       variaciones del centro de fase de un bloque SATELLITE/PHASE_CENTER de un
       fichero SINEX es incorrecto.
\date 28 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSAP_MODAPPCV_INC 3031
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_BSOES_IDPARAM_INC
\brief Indicador de que un identificador de parámetro estadístico de un bloque
       SOLUTION/STATISTICS de un fichero SINEX es incorrecto.
\date 28 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_BSOES_IDPARAM_INC 3032
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_IDUNID_INC
\brief Indicador de que un identificador de unidades utilizado en un fichero
       SINEX es incorrecto.
\date 29 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_IDUNID_INC 3033
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_TIPPAR_INC
\brief Indicador de que un identificador de tipo de parámetro utilizado en un
       fichero SINEX es incorrecto.
\date 29 de enero de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_TIPPAR_INC 3034
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_PTRIAN_INC
\brief Indicador de que un identificador de parte triangular de una matriz
       simétrica utilizado en un fichero SINEX es incorrecto.
\date 17 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_PTRIAN_INC 3035
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_TIPOMAT_INC
\brief Indicador de que un identificador de tipo de matriz utilizado en un
       fichero SINEX es incorrecto.
\date 17 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_TIPOMAT_INC 3036
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_SNX_POSMAT_INC
\brief Indicador de que una posición en una matriz almacenada en un fichero
       SINEX es incorrecta.
\date 17 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_SNX_POSMAT_INC 3037
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//GTS
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GTS_VERT_FHULL
\brief Indicador de que un vértice de una nube de puntos está fuera del
       \em convex \em hull que la engloba.
\date 09 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_GTS_VERT_FHULL 4001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GTS_VERT_FSUP
\brief Indicador de que un vértice está fuera de una superficie.
\date 22 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_GTS_VERT_FSUP 4002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GTS_VERT_DUPL
\brief Indicador de que un vértice de una nube de puntos está duplicado.
\date 09 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_GTS_VERT_DUPL 4003
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GTS_CONF_CONSTR
\brief Indicador de que ha habido un conflicto con un constreñimiento en un
       proceso de triangulación.
\date 09 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_GTS_CONF_CONSTR 4004
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//PMAREA
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PMAREA_NO_HAY_BLOQUE
\brief Indicador de que no existe un bloque buscado en un fichero.
\date 24 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_PMAREA_NO_HAY_BLOQUE 5001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PMAREA_LIN_FICH_INC
\brief Indicador de que una línea de fichero de parámetros de marea es
       incorrecta.
\date 25 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_PMAREA_LIN_FICH_INC 5002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PMAREA_DEF_BLOQUE_INC
\brief Indicador de que una definición de bloque de parámetros de marea en un
       fichero es incorrecta.
\date 25 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_PMAREA_DEF_BLOQUE_INC 5003
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PMAREA_LIM_FDOM
\brief Indicador de que alguno de los límites de la malla está fuera de dominio.
\date 25 de abril de 2010: Creación de la constante.
*/
#define GEOC_ERR_PMAREA_LIM_FDOM 5004
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//GEOPOT
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GEOPOT_GRADO_ORDEN_MAL
\brief Indicador de que los grados y/u órdenes pasados a una función no son
       correctos.
\date 25 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_GEOPOT_GRADO_ORDEN_MAL 6001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GEOPOT_GRACE_LINFO_NO
\brief Indicador de que no hay línea (o la que hay no es la primera) de
       información general de un fichero de un desarrollo del potencial de la
       Tierra en armónicos esféricos en formato de GRACE.
\date 16 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_GEOPOT_GRACE_LINFO_NO 6002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GEOPOT_GRACE_LINFO_REPE
\brief Indicador de que la línea de información general de un fichero de un
       desarrollo del potencial de la Tierra en armónicos esféricos en formato
       de GRACE está repetida.
\date 16 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_GEOPOT_GRACE_LINFO_REPE 6003
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GEOPOT_GRACE_CAB_INCOMP
\brief Indicador de cabecera incompleta en un fichero de un desarrollo del
       potencial de la Tierra en armónicos esféricos en formato de GRACE está
       repetida.
\date 17 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_GEOPOT_GRACE_CAB_INCOMP 6004
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GEOPOT_GRACE_MEZCLA_TIPO_COEF
\brief Indicador de que en un fichero de un desarrollo del potencial de la
       Tierra en armónicos esféricos en formato de GRACE hay definiciones de
       coeficientes de distintas versiones.
\date 23 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_GEOPOT_GRACE_MEZCLA_TIPO_COEF 6005
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GEOPOT_GRACE_NLINEAS_DATOS_MAL
\brief Indicador de que en un fichero de un desarrollo del potencial de la
       Tierra en armónicos esféricos en formato de GRACE no coinciden el número
       de líneas de datos leídas en dos pasadas distintas sobre el fichero.
\date 24 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_GEOPOT_GRACE_NLINEAS_DATOS_MAL 6006
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//NUMLOVE
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_NUMLOVE_NO_HAY_BLOQUE
\brief Indicador de que no existe un bloque buscado en un fichero.
\date 29 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_NUMLOVE_NO_HAY_BLOQUE 7001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_NUMLOVE_DEF_BLOQUE_INC
\brief Indicador de que una línea de fichero de números de Love es incorrecta.
\date 29 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_NUMLOVE_DEF_BLOQUE_INC 7002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_NUMLOVE_LIN_FICH_INC
\brief Indicador de que una definición de bloque de números de Love en un
       fichero es incorrecta.
\date 29 de noviembre de 2010: Creación de la constante.
*/
#define GEOC_ERR_NUMLOVE_LIN_FICH_INC 7003
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//GSHHS
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GSHHS_VERS_ANTIGUA
\brief Indicador de que la versión de un fichero de GSHHS es antigua.
\date 16 de abril de 2011: Creación de la constante.
*/
#define GEOC_ERR_GSHHS_VERS_ANTIGUA 8001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_GSHHS_CREA_POLI
\brief Indicador de que ha ocurrido un error de tipo
       #GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG o
       #GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG al crear una estructura \ref polig o
       \ref polil
\date 19 de junio de 2011: Creación de la constante.
*/
#define GEOC_ERR_GSHHS_CREA_POLI 8002
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//POLIG
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG
\brief Indicador de que dos vectores de coordenadas no contienen el mismo número
       de polígonos.
\date 27 de mayo de 2011: Creación de la constante.
*/
#define GEOC_ERR_POLIG_VEC_DISTINTO_NUM_POLIG 9001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG
\brief Indicador de que dos vectores de coordenadas no contienen los mismos
       polígonos.
\date 27 de mayo de 2011: Creación de la constante.
*/
#define GEOC_ERR_POLIG_VEC_DISTINTOS_POLIG 9002
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//POLIL
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL
\brief Indicador de que dos vectores de coordenadas no contienen el mismo número
       de polilíneas.
\date 03 de junio de 2011: Creación de la constante.
*/
#define GEOC_ERR_POLIL_VEC_DISTINTO_NUM_POLIL 10001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL
\brief Indicador de que dos vectores de coordenadas no contienen las mismas
       polilíneas.
\date 03 de junio de 2011: Creación de la constante.
*/
#define GEOC_ERR_POLIL_VEC_DISTINTAS_POLIL 10002
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
}
#endif
/******************************************************************************/
/******************************************************************************/
//PROYEC
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PROYEC_INI_PROJ
\brief Indicador de que ha ocurrido un error en la inicialización de una
       proyección de PROJ.4.
\date 31 de mayo de 2011: Creación de la constante.
*/
#define GEOC_ERR_PROYEC_INI_PROJ 11001
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PROYEC_NO_INV_PROJ
\brief Indicador de que una proyección cartográfica de PROJ.4 no tiene paso
       inverso.
\date 31 de mayo de 2011: Creación de la constante.
*/
#define GEOC_ERR_PROYEC_NO_INV_PROJ 11002
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ERR_PROYEC_PROJ_ERROR
\brief Indicador de que ha ocurrido un error al proyectar un punto con PROJ.4.
\date 31 de mayo de 2011: Creación de la constante.
*/
#define GEOC_ERR_PROYEC_PROJ_ERROR 11003
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

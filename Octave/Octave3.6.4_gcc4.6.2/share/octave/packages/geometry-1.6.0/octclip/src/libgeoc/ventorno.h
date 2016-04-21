/* -*- coding: utf-8 -*- */
/**
\ingroup anespec general
@{
\file ventorno.h
\brief Definición de variables de entorno y declaración de funciones para su
       control.
\author José Luis García Pallero, jgpallero@gmail.com
\date 31 de marzo de 2011
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
#ifndef _VENTORNO_H_
#define _VENTORNO_H_
/******************************************************************************/
/******************************************************************************/
#include<stdlib.h>
#include<string.h>
/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ENV_NOM_VAR_PILOMBS
\brief Nombre de la variable de entorno para imprimir o no pasos intermedios en
       la ejecución de la función \ref AnalisisLombSig.
\date 31 de marzo de 2011: Creación de la constante.
*/
#define GEOC_ENV_NOM_VAR_PILOMBS "GEOC_ENV_PILOMBS"
/******************************************************************************/
/******************************************************************************/
/**
\def GEOC_ENV_VAL_REF_PILOMBS
\brief Valor de referencia de la variable de entorno #GEOC_ENV_NOM_VAR_PILOMBS.
\date 31 de marzo de 2011: Creación de la constante.
*/
#define GEOC_ENV_VAL_REF_PILOMBS "0"
/******************************************************************************/
/******************************************************************************/
/**
\brief Comprueba si una variable de entorno está definida y es igual a un valor.
\param[in] var Nombre de la variable de entorno a comprobar.
\param[in] valRef Valor de referencia de la variable de entorno.
\return Tres posibilidades:
        - Menor que 0: La variable de entorno no está definida.
        - 0: La variable de entorno existe, pero tiene un valor distinto a
             \em valRef.
        - Mayor que 0: La variable de entorno existe y tiene el mismo valor que
                       \em valRef.
\date 31 de marzo de 2011: Creación de la función.
\todo Esta función todavía no está probada.
*/
int VarEnvValRef(const char* var,
                 const char* valRef);
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

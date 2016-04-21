/* -*- coding: utf-8 -*- */
/**
\ingroup geocnan geom matriz gshhs
@{
\file geocnan.c
\brief Definición de funciones para el trabajo con constantes Not-a-Number.
\author José Luis García Pallero, jgpallero@gmail.com
\date 26 de mayo de 2011
\version 1.0
\section Licencia Licencia
Copyright (c) 2010-2011, José Luis García Pallero. All rights reserved.

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
#include"libgeoc/geocnan.h"
/******************************************************************************/
/******************************************************************************/
double GeocNan(void)
{
    //devolvemos el valor de NaN
    //le calculamos el valor absoluto porque, en algunos sistemas, al imprimir
    //un valor GEOC_NAN normal, éste sale con un signo negativo delante
    //aclaración a 22 de septiembre de 2011: parecía que con lo del fabs()
    //estaba solucionado el asunto del signo negativo, pero no es así
    //la impresión con signo negativo parece que depende de los flags de
    //optimización al compilar y de los propios compiladores
    //no obstante, se mantiene el fabs()
    return fabs(GEOC_NAN);
}
/******************************************************************************/
/******************************************************************************/
int EsGeocNan(const double valor)
{
    //comparamos y salimos de la función
    return valor!=valor;
}
/******************************************************************************/
/******************************************************************************/
size_t* PosGeocNanEnVector(const double* datos,
                           const size_t nDatos,
                           const size_t incDatos,
                           size_t* nNan)
{
    //índice para recorrer bucles
    size_t i=0;
    //vector de salida
    size_t* salida=NULL;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //inicializamos a 0 el número de NaN encontrados
    *nNan = 0;
    //comprobamos una posible salida rápida
    if(nDatos==0)
    {
        //salimos de la función
        return salida;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos los elementos de los vectores
    for(i=0;i<nDatos;i++)
    {
        //comprobamos si el elemento del vector es NaN
        if(EsGeocNan(datos[i*incDatos]))
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
size_t LonFormatoNumSimple(const char formato[])
{
    //cadena auxiliar para la impresión
    char cadena[GEOC_NAN_LON_FORM_NUM_SIMPLE+1];
    //longitud de la cadena imprimida
    size_t lon=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //imprimimos en la cadena auxiliar un valor numérico
    sprintf(cadena,formato,1);
    //calculamos la longitud de la cadena imprimida
    lon = strlen(cadena);
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return lon;
}
/******************************************************************************/
/******************************************************************************/
void FormatoNumFormatoTexto(const char formatoNum[],
                            char formatoTexto[])
{
    //número de carácteres de los resultados impresos con el formato numérico
    size_t lon=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //calculamos el número de carácteres de los resultados impresos con el
    //formato numérico
    lon = LonFormatoNumSimple(formatoNum);
    //creamos la cadena de formato para imprimir texto
    sprintf(formatoTexto,"%s%zu%s","%",lon,"s");
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //salimos de la función
    return;
}
/******************************************************************************/
/******************************************************************************/
void ImprimeGeocNanTexto(FILE* idFich,
                         const size_t nNan,
                         const char formato[],
                         const int retCarro)
{
    //índice para recorrer bucles
    size_t i=0;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //recorremos el número de elementos a imprimir
    for(i=0;i<nNan;i++)
    {
        //imprimimos
        fprintf(idFich,formato,GEOC_NAN_TXT);
    }
    //comprobamos si hay que añadir salto de línea
    if(retCarro)
    {
        fprintf(idFich,"\n");
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

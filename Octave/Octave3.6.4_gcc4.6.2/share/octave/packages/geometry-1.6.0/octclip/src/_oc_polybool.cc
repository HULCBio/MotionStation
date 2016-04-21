/* -*- coding: utf-8 -*- */
/* Copyright (C) 2011  José Luis García Pallero, <jgpallero@gmail.com>
 *
 * This file is part of OctCLIP.
 *
 * OctCLIP is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
/******************************************************************************/
/******************************************************************************/
#define HELPTEXT "\
-*- texinfo -*-\n\
@deftypefn{Loadable Function}{[@var{X},@var{Y},@var{nPol},@var{nInt},\
@var{nPert}] =}_oc_polybool(@var{sub},@var{clip},@var{op})\n\
\n\
@cindex Performs boolean operations between two polygons.\n\
\n\
This function performs boolean operations between two polygons using the\n\
Greiner-Hormann algorithm (http://davis.wpi.edu/~matt/courses/clipping/).\n\
\n\
@var{sub} is a two column matrix containing the X and Y coordinates of the\n\
vertices for the subject polygon.\n\n\
@var{clip} is a two column matrix containing the X and Y coordinates of the\n\
vertices for the clipper polygon.\n\n\
@var{op} is a text string containing the operation to perform between\n\
@var{sub} and @var{clip}. Possible values are:\n\
\n\
@itemize @bullet\n\
@item @var{'AND'}\n\
Intersection of @var{sub} and @var{clip}.\n\n\
@item @var{'OR'}\n\
Union of @var{subt} and @var{clip}.\n\n\
@item @var{'AB'}\n\
Operation @var{sub} - @var{clip}.\n\n\
@item @var{'BA'}\n\
Operation of @var{clip} - @var{sub}.\n\
@end itemize\n\
\n\
For the matrices @var{sub} and @var{clip}, the first point is not needed to\n\
be repeated at the end (but is permitted). Pairs of (NaN,NaN) coordinates in\n\
@var{sub} and/or @var{clip} are ommitted.\n\
\n\
@var{X} is a column vector containing the X coordinates of the vertices of\n\
the resultant polygon(s).\n\n\
@var{Y} is a column vector containing the Y coordinates of the vertices of\n\
the resultant polygon(s).\n\n\
@var{nPol} is the number of output polygons.\n\n\
@var{nInt} is the number of intersections between @var{sub} and @var{clip}.\n\n\
@var{nPert} is the number of perturbed points of the @var{clip} polygon in\n\
any particular case (points in the oborder of the other polygon) occurs see\n\
http://davis.wpi.edu/~matt/courses/clipping/ for details.\n\
\n\
This function do not check if the dimensions of @var{sub} and @var{clip} are\n\
correct.\n\
\n\
@end deftypefn"
/******************************************************************************/
/******************************************************************************/
#include<octave/oct.h>
#include<cstdio>
#include<cstring>
#include<cstdlib>
#include<cmath>
#include"octclip.h"
/******************************************************************************/
/******************************************************************************/
#define ERRORTEXT 1000
/******************************************************************************/
/******************************************************************************/
DEFUN_DLD(_oc_polybool,args,,HELPTEXT)
{
    //error message
    char errorText[ERRORTEXT+1]="_oc_polybool:\n\t";
    //output list
    octave_value_list outputList;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //checking input arguments
    if(args.length()!=3)
    {
        //error text
        sprintf(&errorText[strlen(errorText)],
                "Incorrect number of input arguments\n\t"
                "See help _oc_polybool");
        //error message
        error(errorText);
    }
    else
    {
        //loop index
        size_t i=0;
        //polygons and operation
        ColumnVector xSubj=args(0).matrix_value().column(0);
        ColumnVector ySubj=args(0).matrix_value().column(1);
        ColumnVector xClip=args(1).matrix_value().column(0);
        ColumnVector yClip=args(1).matrix_value().column(1);
        std::string opchar=args(2).string_value();
        //computation vectors
        double* xA=NULL;
        double* yA=NULL;
        double* xB=NULL;
        double* yB=NULL;
        //double linked lists
        vertPoliClip* polA=NULL;
        vertPoliClip* polB=NULL;
        //operation identifier
        enum GEOC_OP_BOOL_POLIG op=GeocOpBoolInter;
        //output struct
        polig* result=NULL;
        //number of polygons, intersections and perturbations
        size_t nPol=0,nInter=0,nPert=0;
        //number of elements for the output vectors
        size_t nElem=0;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //pointers to data
        xA = xSubj.fortran_vec();
        yA = ySubj.fortran_vec();
        xB = xClip.fortran_vec();
        yB = yClip.fortran_vec();
        //create double linked lists for subject and clipper polygons
        polA = CreaPoliClip(xA,yA,static_cast<size_t>(xSubj.length()),1,1);
        polB = CreaPoliClip(xB,yB,static_cast<size_t>(xClip.length()),1,1);
        //error checking
        if((polB==NULL)||(polB==NULL))
        {
            //free peviously allocated memory
            LibMemPoliClip(polA);
            LibMemPoliClip(polB);
            //error text
            sprintf(&errorText[strlen(errorText)],"Error in memory allocation");
            //error message
            error(errorText);
            //exit
            return outputList;
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //select operation
        if((!strcmp(opchar.c_str(),"AND"))||(!strcmp(opchar.c_str(),"and")))
        {
            op = GeocOpBoolInter;
        }
        else if((!strcmp(opchar.c_str(),"OR"))||(!strcmp(opchar.c_str(),"or")))
        {
            op = GeocOpBoolUnion;
        }
        else if((!strcmp(opchar.c_str(),"AB"))||(!strcmp(opchar.c_str(),"ab")))
        {
            op = GeocOpBoolAB;
        }
        else if((!strcmp(opchar.c_str(),"BA"))||(!strcmp(opchar.c_str(),"ba")))
        {
            op = GeocOpBoolBA;
        }
        else
        {
            //free peviously allocated memory
            LibMemPoliClip(polA);
            LibMemPoliClip(polB);
            //error text
            sprintf(&errorText[strlen(errorText)],
                    "The third input argument (op=%s) is not correct",
                    opchar.c_str());
            //error message
            error(errorText);
            //exit
            return outputList;
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //clipping
        result = PoliBoolGreiner(polA,polB,op,GEOC_GREINER_FAC_EPS_PERTURB,
                                 &nInter,&nPert);
        //error checking
        if(result==NULL)
        {
            //free peviously allocated memory
            LibMemPoliClip(polA);
            LibMemPoliClip(polB);
            //error text
            sprintf(&errorText[strlen(errorText)],"Error in memory allocation");
            //error message
            error(errorText);
            //exit
            return outputList;
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //number or output polygons
        nPol = result->nPolig;
        //dimensions for the output vectors
        if(nPol)
        {
            nElem = result->nElem;
        }
        else
        {
            nElem = 0;
        }
        //output vectors
        ColumnVector xResult(nElem);
        ColumnVector yResult(nElem);
        //copy output data
        for(i=0;i<nElem;i++)
        {
            xResult(i) = result->x[i];
            yResult(i) = result->y[i];
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //output parameters list
        outputList(0) = xResult;
        outputList(1) = yResult;
        outputList(2) = nPol;
        outputList(3) = nInter;
        outputList(4) = nPert;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //free memory
        LibMemPoliClip(polA);
        LibMemPoliClip(polB);
        LibMemPolig(result);
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return outputList;
}

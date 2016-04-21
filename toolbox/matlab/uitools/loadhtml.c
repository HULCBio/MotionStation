/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/* $Revision: 1.24 $  $Date: 2002/06/21 20:31:33 $  $Author: maberman $ */

/*
 * $Log: loadhtml.c,v $
 * Revision 1.24  2002/06/21 20:31:33  maberman
 * Updated copyrights to 2002.
 * Related Records: 127981
 * Code Reviewer: diff, copyrightupdate.pl
 *
 * Revision 1.24  2002/06/17 18:58:31  maberman
 * Updated copyrights to 2002.
 * Related Records: 127981
 * Code Reviewer: diff, copyrightupdate.pl
 *
 * Revision 1.23  2001/04/15 12:03:27  scott
 * Update copyrights to 2001.
 * Related Records: 93825
 * Code Reviewer: mdiff&emacs; BAT:118303c@R12compiler
 *
 * Revision 1.22  2000/09/18  22:01:45  greg
 * Fix log prefix
 * Related Records: CVS
 * Code Reviewer: marc, mmirman
 *
 * Revision 1.21  2000/06/02 04:41:53  joeya
 * Copyright fix
 *
 * Revision 1.20  1999/01/18 21:13:22  joeya
 * Updated the ending copyright date
 *
 * Revision 1.19  1997/11/21  23:48:54  moler
 * Update copyright.
 *
 * Revision 1.18  1997/10/29  17:21:49  barnard
 * Corrected memory leak errors that were causing asserts due to the
 * new array handling in MATLAB.
 * Related Records: 33798
 * Code Reviewer: Giesing
 *
 * Revision 1.17  1996/10/18  21:41:03  barnard
 * Added Copyright line.  Fixes G17478.
 * Code Reviewer:
 *
 * Revision 1.16  1995/12/13  20:33:06  barnard
 * More updates to increase MATLAB 5 compatibility.
 * (ie. for smoother operation within MATLAB 5)
 *
 * Revision 1.15  1995/12/12  16:56:19  rayn
 * Port V4 style MEX API to strict V5.
 *
 * Revision 1.14  1995/12/11  21:27:25  barnard
 * Updating the v5 HTHELP -related files to the current v4 level.  These
 * filesoutdated by the latest v4 release of UITOOLS.  Now the v5 HTHELP is
 * sync'ed with the latest v4 release.
 *
 * Revision 1.15  1995/05/19  20:47:51  barnard
 * Made 'link' color black on black and white terminals so that it would
 * show up.  This was a problem on UNIX black and white screens.
 *
 * Revision 1.14  1995/05/08  17:53:51  barnard
 * Corrected line wrapping bugs.  Made heading command conform with HTML
 * standards.  Corrected list item line wrapping problems.
 *
 * Revision 1.13  1995/02/09  15:57:59  barnard
 * Made mods to run on VAX platforms.  Also, corrected allocation bug.
 * Initialized with zeros to aud array.  This was causing a FPE on VAX when
 * reading the data back out.
 *
 * Revision 1.12  1995/01/19  21:09:36  barnard
 * Corrected PC problems. Removed memory.h include.  Adjusted object length
 * for the PC.
 *
 * Revision 1.11  1995/01/13  20:43:18  barnard
 * Added some (int) type casting for relops with strlen.
 *
 * Revision 1.10  1995/01/12  16:46:11  barnard
 * Increased array sizes for filenames and links.
 *
 * Revision 1.9  1995/01/09  17:08:06  barnard
 * Corrected input argument checker.
 *
 * Revision 1.8  1995/01/06  18:43:29  barnard
 * Changed parsing algorithm to ignore line feeds in the source HTML file.
 * This now matches the behavior of Mosaic and Netscape.  HTHELP will no
 * longer obey line feeds in the source file.
 *
 * Revision 1.7  1995/01/04  20:37:07  barnard
 * Convert all tabs and CRs to spaces.  Eliminates black squares on PC.
 *
 * Revision 1.6  1994/12/22  19:30:00  barnard
 * Fixed malloc bug so that it works on SGI and Mac also.
 *
 * Revision 1.5  1994/12/21  19:02:59  barnard
 * Corrected bug in 'box' and 'escape' code processing.
 *
 * Revision 1.4  1994/12/20  21:58:23  barnard
 * Modified large memory alloc. for efficiency.
 *
 * Revision 1.3  1994/12/01  14:23:41  barnard
 * Correct extent property for escape char and list items.
 *
 * Revision 1.2  1994/11/30  20:01:19  barnard
 * Removed unnecessary variables and corrected handling of empty files.
 *
 * Revision 1.1  1994/11/30  16:43:34  barnard
 * Initial revision
 * */
/*********************************************************************/

/* 
 *  LOADHTML.C:
 *  This MEX file performs the text loading and parsing for HTHELP.
 *
 *  Paul Barnard 
 *  Copyright 1984-2002 The MathWorks, Inc. 
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include "mex.h"

#ifndef max
#define	max(A, B)	((A) > (B) ? (A) : (B))
#endif

#ifndef min
#define	min(A, B)	((A) < (B) ? (A) : (B))
#endif

/*
 ********************************************************************** 
 * LOADHTML Subroutine.
 ********************************************************************** 
 */
#ifdef __STDC__
char *loadhtml(
        char *cmd,
        char *fn,
        char *lnk,
        char *txt,
        double fig,
        double ax,
        double *LH,
        char *computer
	)
#else
char *loadhtml(cmd,fn,lnk,txt,fig,ax,LH,computer)
char   *cmd,*fn,*lnk,*txt,*computer;
double fig,ax,*LH;
#endif
{
/* Define the required variables. */
FILE   *filep;
char   *TextString,*TextStringLow,DlgName[80],thisfn[255],
       *lnkLow,*tmp,*str,*sloc,*eloc,*BS,*tmpp,code[10],
       linkcallback[255],nexttexttag[255],cmdlet,cmdlet2,endcmd,
       *p,*q,*r,*nextp,*TSlen,pre[255],cmdbdy[255],cmdbdylow[255],
       lnkfn[255],tag[255],basefontname[] = "Helvetica";
int    i,j,linnum,inlink,listmode,indmode,tab,nlhs,nrhs,listcnt,
       istart,ib,preflg;
unsigned int hnum,incode;
double xpos,ypos,pLH,bLH,pos[2],xdata[2],ydata[2],h,*siz,t,*aud,
       LinkColor[3] = {0.2, 0.2, 0.70},relfontsize[4] = {4, 3, 2, 1},
       basefontsize = 12,fontsize,ForegroundColor[3] = {0, 0, 0};
size_t ln,lnkln;
mxArray *plhs[1],*prhs[8],*mxPositionStr,*mxPosMat,*mxStringStr,
        *mxTagStr,*mxhMat,*mxtMat,*mxsizMat,*mxxdataStr,*mxxdataMat,
        *mxydataStr,*mxydataMat,*mxButtondwnStr,*mxColorStr,
        *mxLinkColorMat,*mxextentStr,*mxaxMat,*mxDTextFWStr,
        *mxboldStr,*mxnormalStr,*mxDTextFSStr,*mxfontsizeMat,
        *mxForeColorMat,*mxDTextFNStr,*mxbaseFNMat,*mxDTextFAStr,
        *mxitalicStr,*mxCourierStr;

/* Allocate space on the heap for strings and arrays. */
if ((tmp=mxCalloc(50000, sizeof(char))) == NULL)
  mexErrMsgTxt("Out of Memory in loadhtml.mex");

/* Initialize pointer which may or may not be used. */
lnkLow = 0;

/* First read the file or load the string depending on the command. */
if (strcmp(cmd,"load") == 0) { /* if load */

   /* Allocate space for the string to be read. */
   if ((str=mxCalloc(50000, sizeof(char))) == NULL)
     mexErrMsgTxt("Out of Memory in loadhtml.mex");

   /* Open the file 'fn' for reading. */
   if ((filep=fopen(fn,"r")) == NULL) {
      strcpy(str,"<TITLE>ERROR</TITLE>\n\n***Unable to load file.***\n");
      strcpy(thisfn,"Not a File");
      strcpy(lnk,"");

   } else {
      strcpy(thisfn,fn);
      
      /* Loading file */
      str[0] = '\0';
      while(!feof(filep)) {
         if (fgets(tmp, 255, filep)) strcat(str,tmp);
      }

      fclose(filep);

   }

   TextString = str;

   /* Free 'txt' because we don't need it anymore. */
   mxFree(txt);

} else {
   /* Load the passed string. */
   TextString = txt;
   strcpy(thisfn,fn);
}

/*
 * Start digging through the string for info.
 * Begin by converting string to lowercase.
 */
ln = strlen(TextString);
if ((TextStringLow=mxCalloc(ln+1, sizeof(char))) == NULL)
  mexErrMsgTxt("Out of Memory in loadhtml.mex");
for (i=0;i<=ln;i++) TextStringLow[i] = tolower(TextString[i]);

/* Find the starting and ending points. */
if (lnk[0] != '\0') { /* If a starting link exists... */
   /* Find the desired link. */
   strcpy(tmp, "<a name=\"");
   lnkln = strlen(lnk);
   if ((lnkLow=mxCalloc(lnkln+1, sizeof(char))) == NULL)
     mexErrMsgTxt("Out of Memory in loadhtml.mex");
   for (i=0;i<=lnkln;i++) lnkLow[i] = tolower(lnk[i]);
   strcat(tmp, lnkLow);
   strcat(tmp, "\">");
   if ((sloc=strstr(TextStringLow, tmp)) == NULL) {
      strcpy(str, "<title>Error</title>Link \"");
      strcat(str, lnk);
      strcat(str, "\" not found in file ");
      strcat(str, thisfn);
      strcat(str, "\n\0");
      TextString = str;
      for (i=0;i<=(int) strlen(str);i++) TextStringLow[i] = tolower(TextString[i]);
      strcpy(thisfn, "Not a File");
      strcpy(lnk, "");
      ln = strlen(TextStringLow);
      sloc = TextStringLow + ln;
   }

   /* Look for a <title> (BS) before that sloc. */
   for (i=0;&TextStringLow[i] <= sloc;i++) tmp[i] = TextStringLow[i];
   tmp[i] = '\0';
   tmpp = tmp;
   while (BS = strstr(tmpp, "<ti")) {  /* This finds the last <title> */
      tmpp = BS + 1;                   /* before the 'sloc'.          */
   }
   BS = &TextStringLow[tmpp-1 - tmp];

} else {
   sloc = TextStringLow;               /* Take the first BS */
   BS = strstr(TextStringLow, "<ti");  /* we can find.      */

}

/* Parse the beginning of the section for a section name. */
DlgName[0] = '\0';
if (BS != NULL) {
   BS = &TextString[BS - TextStringLow];  /* Move pointer to TS. */
   sloc = strchr(BS, '>');
   sloc++;
   for (i=0;*(sloc+i) != '<';i++) DlgName[i] = *(sloc + i);
   DlgName[i] = '\0';
   sloc += i;
   sloc = strchr(sloc, '>');  /* Skip over the "</title>". */
   sloc++;                     /* Advance one more to skip this */
   if (*sloc == '\n') sloc++;  /* line if sloc at end.          */
   sloc = &TextStringLow[sloc - TextString];  /* Move pointer back to TSLow. */
}
if (DlgName[0] == '\0') strcpy(DlgName, "Hyper Text Help");

/* Find the end of the section. */
eloc = strstr(sloc, "<ti");
if (eloc == NULL) eloc = &TextStringLow[ln];
eloc--;

/* Pull out the section of text in which we are interested. */
for (i=0;(sloc + i) <= eloc;i++) TextString[i] = TextString[(sloc - TextStringLow) + i];
TextString[i] = '\0';
for (i=0;(sloc + i) <= eloc;i++) TextStringLow[i] = *(sloc + i);
TextStringLow[i] = '\0';

/*
 * Make a call to MATLAB setting the name of the figure with
 * the DlgName.
 *
 * set(fig,'Name',DlgName);
 */
nrhs = 3;
prhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
*mxGetPr(prhs[0]) = fig;
prhs[1] = mxCreateString("Name");
prhs[2] = mxCreateString(DlgName);
nlhs = 0;
mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

/*
 * Convert tabs and CR's to spaces.  Both tabs and CR's are
 * replaced with a single space.
 */
p = TextString;
while (p = strchr(p, '\t')) p[0] = ' ';
p = TextString;
while (p = strchr(p, '\r')) p[0] = ' ';

/* Set up params before looping through text string. */
ypos = 0.0;
if (lnk[0] == '\0') {
   strcpy(nexttexttag, "toplink");
} else {
   nexttexttag[0] = '\0';
}

/*
 * If the screen is black and white then set the
 * link color strictly to black.
 *
 * if get(0,'ScreenDepth')==1, LinkColor = [1 1 1]; end
 *
 */
nrhs = 2;
prhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
t = 0;
*mxGetPr(prhs[0]) = t;
prhs[1] = mxCreateString("ScreenDepth");
nlhs = 1;
plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
mexCallMATLAB(nlhs,plhs,nrhs,prhs,"get");
if (mxGetScalar(plhs[0]) == 1) for (i=0;i<=2;i++) LinkColor[i]=ForegroundColor[i];

TSlen = &TextString[strlen(TextString) - 2];
pLH = LH[3];
linnum = 1;  /* This is the line we are on. */
strcpy(code, "box");
tab = 5;  /* 5 space tab. */
inlink = 0;
listmode = 0;
listcnt = 0;
indmode = 0;
preflg = 0;
linkcallback[0] = '\0';
p = TextString;  /* 'p' is pointer to current string location. */
if ((nextp = strchr(TextString, '\n')) == NULL)
  mexErrMsgTxt("Error:  File must contain at least one carriage return.");

/*
 * Set up the pointers to MEX objects that are constant
 * through each loop.
 */
mxPositionStr  = mxCreateString("Position");
mxPosMat       = mxCreateDoubleMatrix(1, 2, mxREAL);
mxStringStr    = mxCreateString("String");
mxTagStr       = mxCreateString("Tag");
mxhMat         = mxCreateDoubleMatrix(1, 1, mxREAL);
mxtMat         = mxCreateDoubleMatrix(1, 1, mxREAL);
mxsizMat       = mxCreateDoubleMatrix(1, 4, mxREAL);
mxxdataStr     = mxCreateString("xdata");
mxxdataMat     = mxCreateDoubleMatrix(1, 2, mxREAL);
mxydataStr     = mxCreateString("ydata");
mxydataMat     = mxCreateDoubleMatrix(1, 2, mxREAL);
mxButtondwnStr = mxCreateString("Buttondownfcn");
mxColorStr     = mxCreateString("Color");
mxLinkColorMat = mxCreateDoubleMatrix(1, 3, mxREAL);
mxextentStr    = mxCreateString("extent");
mxaxMat        = mxCreateDoubleMatrix(1, 1, mxREAL);
mxDTextFWStr   = mxCreateString("DefaultTextFontWeight");
mxboldStr      = mxCreateString("bold");
mxnormalStr    = mxCreateString("normal");
mxDTextFSStr   = mxCreateString("DefaultTextFontSize");
mxfontsizeMat  = mxCreateDoubleMatrix(1, 1, mxREAL);
mxForeColorMat = mxCreateDoubleMatrix(1, 3, mxREAL);
mxDTextFNStr   = mxCreateString("DefaultTextFontName");
mxbaseFNMat    = mxCreateString(basefontname);
mxDTextFAStr   = mxCreateString("DefaultTextFontAngle");
mxitalicStr    = mxCreateString("italic");
mxCourierStr   = mxCreateString("Courier");
/*
 * Now we loop through the text string, parsing it, and putting
 * it up, line at a time.
 * p marks where we are.  nextp the end of the line.
 */
while (p < TSlen) {
   /* Do the line... */
   if (p[0] == '\n') {
      bLH = pLH;  /* Blank line -- skip space. */
   } else {
     /*
      * Line has something on it.  Only skip space if there's
      * text displayed.	(That way lines with just markups don't
      * use up space in the display.)
      */
      bLH = 0;    /* The biggest Line Height so far on the line. */
   }
   xpos = 0.0;  /* Reset the xpos. */
   if (indmode) xpos = tab;

   /* Find nextp. */
   if (preflg) {
      if ((nextp = strchr(p, '\n')) == NULL) break;
   } else {
      incode = 0;
      ib = 0;
      for (i=0;((i+1) <= 70) || (*(p+i+ib) != ' ' && *(p+i+ib) != '\n') || 
           incode;i++) {
        if ((tmp[i + ib] = *(p + i + ib)) == '\0') break;

        if (tmp[i + ib] == '<' || tmp[i + ib] == '&') {
           incode = 1;
           istart = i;
	   
        } else if (tmp[i + ib] == '>' || tmp[i + ib] == ';') {
           incode = 0;
           ib = ib + i - istart + 1;
           i = istart - 1;
        }
      }
      nextp = p + i + ib;

   }

   while (p <= nextp) {
      /* Update the tmp array.*/
      for (i=0;(p + i) < nextp;i++) tmp[i] = *(p + i);
      tmp[i] = '\0';

      if      (tmp[0] == '<') strcpy(code, "box");
      else if (tmp[0] == '&') strcpy(code, "escape");
      else {
         q = strchr(tmp, '<'); r = strchr(tmp, '&');
         if (q != NULL) {
            if (r != NULL) {
               if (q < r) strcpy(code, "box");
               else {
                  strcpy(code, "escape");
                  q = r;
               }
	    } else strcpy(code, "box");
            for (i=0;&tmp[i] < q;i++) pre[i] = tmp[i];

	 } else if (r != NULL) {
            strcpy(code, "escape");
            for (i=0;&tmp[i] < r;i++) pre[i] = tmp[i];

	 } else for (i=0;i < (int) strlen(tmp);i++) pre[i] = tmp[i];

         pre[i] = '\0';
         p += strlen(pre);

        /*
         * Replace '\n' characters with ' ' before printing.  However,
         * if the last character is a ' ', delete the '\n' and don't
         * print it.  Finally, if the last character is a '.', replace
         * the '\n' with a ' ' and add one more ' ' to the output.
         */
         j = 0;
         for (i=0;i < (int) strlen(pre);i++) {
            if (pre[i] != '\n') {
               tmp[j] = pre[i];
               j++;

	    } else if (i > 0) {
               if (!(pre[i-1] == ' ' || pre[i-1] == '>' || pre[i-1] == '\n')) {
                  tmp[j] = ' ';
                  j++;
		}
               if (pre[i-1] == '.') {
                  tmp[j] = ' ';
                  j++;
	       }

	    }
         }
         tmp[j] = '\0';

        /*
         * Draw the text before the < or &.
         * Leave this MATLAB call for later.
         *
         * h=text('position',[xpos ypos],'string',tmp,...
         *        'tag',nexttexttag);
         */
         nrhs = 6;
         prhs[0] = mxPositionStr;
         prhs[1] = mxPosMat;
         pos[0] = xpos; pos[1] = ypos;
         memcpy(mxGetPr(prhs[1]), &pos, 2*sizeof(double));
         prhs[2] = mxStringStr;
         prhs[3] = mxCreateString(tmp);
         prhs[4] = mxTagStr;
         prhs[5] = mxCreateString(nexttexttag);
         nlhs = 1;
         plhs[0] = mxhMat;
         mexCallMATLAB(nlhs,plhs,nrhs,prhs,"text");
         h = mxGetScalar(plhs[0]);

         nexttexttag[0] = '\0';
         bLH = max(pLH, bLH);

         /* If there are more commands on the line or
          * you need to underline the text...
          */
         if ((p < nextp) || inlink) {
           /*
            * siz=textextent(h,0);   --OR--
            * siz = get(h,'extent');
            * 
            * nrhs = 2;
            * prhs[0] = mxhMat;
            * mxSetPr(prhs[0], &h);
            * prhs[1] = mxtMat;
            * t = 0;
            * mxSetPr(prhs[1], &t);
            * nlhs = 1;
            * plhs[0] = mxsizMat;
            * mexCallMATLAB(nlhs,plhs,nrhs,prhs,"textextent");
            * siz = mxGetPr(plhs[0]);
            */
            nrhs = 2;
            prhs[0] = mxhMat;
            *mxGetPr(prhs[0]) = h;
            prhs[1] = mxextentStr;
            nlhs = 1;
            plhs[0] = mxsizMat;
            mexCallMATLAB(nlhs,plhs,nrhs,prhs,"get");
            siz = mxGetPr(plhs[0]);

            /* Fudge the text size based on the host. */
            /* On anything other than a Mac, pull back the size one space. */
            /* Except on a PC, where we add a space. */
            /* No longer needed for MATLAB 5.
             * if ((computer[0] == 'P') && (computer[1] == 'C')) siz[2] += 1.0;
             * else if ((computer[0] != 'M') || (computer[1] != 'A')) siz[2] -= 1.0;
             */
	 }

         if (inlink) {
           /* Underline & Change the color & set the callback.
            *
            * line('xdata',[xpos xpos+siz(3)],...
            *      'ydata',[ypos+0.85*pLH ypos+0.85*pLH],...
            *      'Buttondownfcn',linkcallback,
            *      'Color',LinkColor);
            */
            nrhs = 8;
            prhs[0] = mxxdataStr;
            prhs[1] = mxxdataMat;
            xdata[0] = xpos; xdata[1] = xpos + siz[2];
            memcpy(mxGetPr(prhs[1]), &xdata, 2*sizeof(double));
            prhs[2] = mxydataStr;
            prhs[3] = mxydataMat;
            ydata[0] = ypos + 0.85*pLH; ydata[1] = ydata[0];
            memcpy(mxGetPr(prhs[3]), &ydata, 2*sizeof(double));
            prhs[4] = mxButtondwnStr;
            prhs[5] = mxCreateString(linkcallback);
            prhs[6] = mxColorStr;
            prhs[7] = mxLinkColorMat;
            memcpy(mxGetPr(prhs[7]), &LinkColor, 3*sizeof(double));
            nlhs = 0;
            mexCallMATLAB(nlhs,plhs,nrhs,prhs,"line");
            
           /*
            * set(h,'Color',LinkColor, ...
            *       'Buttondownfcn',linkcallback);
            */
            nrhs = 5;
            prhs[0] = mxhMat;
            *mxGetPr(prhs[0]) = h;
            prhs[1] = mxColorStr;
            prhs[2] = mxLinkColorMat;
            memcpy(mxGetPr(prhs[2]), &LinkColor, 3*sizeof(double));
            prhs[3] = mxButtondwnStr;
            prhs[4] = prhs[5];     /* Use previously created pointer */
            nlhs = 0;              /* for linkcallback (prhs[5]).    */
            mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

         }

         if (p >= nextp) break;
         xpos += siz[2];

      }

      /* Now everything after the < or &... */
      cmdlet = tolower(p[1]);
      /* A little bit of pre-parsing of the command. */
      if (code[0] == 'b') endcmd = '>';
      else endcmd = ';';
      if (p[2] == endcmd) {
         cmdlet2 = '\0';
         cmdbdy[0] = '\0';
         cmdbdylow[0] = '\0';
         p += 3;
      } else {
         cmdlet2 = tolower(p[2]);
         if (q = strchr(p, endcmd)) {
            for (i=0;(p + (2+i)) < q;i++) {
               cmdbdy[i] = p[2 + i];
               cmdbdylow[i] = tolower(p[2 + i]);
            }
            cmdbdy[i] = '\0';
            cmdbdylow[i] = '\0';
         }
         p += (strlen(cmdbdy) + 3);
      }

      /* Processing for a box command. */
      if (code[0] == 'b') {
         /* Start a link reference. */
         if (cmdlet == 'a') {
            /* Get the filename, linkname, and command. */
            q = strtok(cmdbdy, "\"");
            for (i=0;i < (int) strlen(q);i++)
              cmdbdylow[i] = tolower(*(q + i));
            cmdbdylow[i] = '\0';
            q = strtok('\0', "\"");
            for (i=0;i < (int) strlen(q);i++)
              lnkfn[i] = *(q + i);
            lnkfn[i] = '\0';
            if (lnkfn[0] == '#') {
               for (i=0;i < (int) strlen(thisfn);i++) {
                  tmp[i] = lnkfn[i];
                  lnkfn[i] = thisfn[i];
	       }
               tmp[i] = '\0';
               for (j=0;j < (int) strlen(tmp);j++)
                 lnkfn[i + j] = tmp[j];
               lnkfn[i + j] = '\0';
	    }

            /* Set up the proper link callback based on the command. */
            if (strstr(cmdbdylow, "href")) {
               inlink = 1;
               strcpy(linkcallback, "hthelp(\'load\',\'");
               strcat(linkcallback, lnkfn);
               strcat(linkcallback, "\');");
            } else if (strstr(cmdbdylow, "name")) {
               strcpy(nexttexttag, "link:");  /* This is a reference.  Prepare */
               strcat(nexttexttag, lnkfn);    /* a tag for next piece of text. */
            } else if (strstr(cmdbdylow, "cont") ||
                      strstr(cmdbdy, "func")) {
               inlink = 1;
               strcpy(linkcallback, "hthelp(\'");
               strcat(linkcallback, lnkfn);
               strcat(linkcallback, "\');");
	    } else if (strstr(cmdbdylow, "run")) {
               inlink = 1;
               strcpy(linkcallback, lnkfn);
            }

         /* Bold, Block, or Break. */
         } else if (cmdlet == 'b') {
            if (cmdlet2 == '\0') {
	      /*
               * set(ax,'DefaultTextFontWeight','bold');
               */
               nrhs = 3;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFWStr;
               prhs[2] = mxboldStr;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");
            } else if (cmdlet2 == 'l') {
               indmode = 1;
               xpos = tab;
	    } else if (cmdlet2 == 'r') {
               xpos = 0;
               break;
	    }

         /* Definition list, title, or description. */
	 } else if (cmdlet == 'd') {
	    /* Def. list. */
            if (cmdlet2 == 'l') {
               indmode = 0;
	    /* Def. title. */
	    } else if (cmdlet2 == 't') {
	       indmode = 0;
	       xpos = 0;
               break;
	    /* Def. description. */
	    } else if (cmdlet2 == 'd') {
	       indmode = 1;
	       xpos = tab;
               break;
	    }

         /* Heading number or horizontal rule. */
	 } else if (cmdlet == 'h') {
	    /* Horizontal rule. */
            if (cmdlet2 == 'r') {
              /*
               * line([0 100],[ypos+bLH ypos+bLH],...
               *      'Color',ForegroundColor);
               */
	       nrhs = 4;
               prhs[0] = mxxdataMat;
               xdata[0] = 0; xdata[1] = 100;
               memcpy(mxGetPr(prhs[0]), &xdata, 2*sizeof(double));
               prhs[1] = mxydataMat;
               ydata[0] = ypos + bLH; ydata[1] = ydata[0];
               memcpy(mxGetPr(prhs[1]), &ydata, 2*sizeof(double));
               prhs[2] = mxColorStr;
               prhs[3] = mxForeColorMat;
               memcpy(mxGetPr(prhs[3]), &ForegroundColor, 3*sizeof(double));
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"line");

               xpos = 0;
               ypos += bLH;
               break;

            /* Heading with number. */
	    } else {
               xpos = 0;
               ypos += bLH;
	       if (cmdlet2 == '\0') cmdlet2 = '2';
               t = cmdlet2 - 48;  /* Convert to double from char. */
               hnum = min((unsigned int) (t-1), (unsigned int) relfontsize[0]);
               fontsize = basefontsize + 2*relfontsize[hnum];

              /*
               * set(ax,'DefaultTextFontSize',fontsize);
               */
               nrhs = 3;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFSStr;
               prhs[2] = mxfontsizeMat;
               *mxGetPr(prhs[2]) = fontsize;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

               pLH = LH[hnum];
	    }

         /* Italics. */
         } else if (cmdlet == 'i') {
           /*
            * set(ax,'DefaultTextFontAngle','italic');
            */
            nrhs = 3;
            prhs[0] = mxaxMat;
            *mxGetPr(prhs[0]) = ax;
            prhs[1] = mxDTextFAStr;
            prhs[2] = mxitalicStr;
            nlhs = 0;
	    mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

         /* Create a list item. */
         } else if (cmdlet == 'l') {
            xpos = 3;
            tab = 7;
            indmode = 1;
            ypos += bLH;
            if (listmode == 1) {
               listcnt += 1;
               tmp[0] = listcnt + 48;
               tmp[1] = '\0';
               strcat(tmp, ". ");
	    } else if (listmode == 2) {
               strcpy(tmp, "O  ");
	    }

           /*
            * text('position',[xpos ypos],...
            *      'string',tmp,...
            *      'tag',nexttexttag);
            */
            nrhs = 6;
            prhs[0] = mxPositionStr;
            prhs[1] = mxPosMat;
            pos[0] = xpos; pos[1] = ypos;
            memcpy(mxGetPr(prhs[1]), &pos, 2*sizeof(double));
            prhs[2] = mxStringStr;
            prhs[3] = mxCreateString(tmp);
            prhs[4] = mxTagStr;
            prhs[5] = mxCreateString(nexttexttag);
            nlhs = 1;
            plhs[0] = mxhMat;
            mexCallMATLAB(nlhs,plhs,nrhs,prhs,"text");
            h = mxGetScalar(plhs[0]);

           /*
            * siz = get(h,'extent');
            */
            nrhs = 2;
            prhs[0] = mxhMat;
            *mxGetPr(prhs[0]) = h;
            prhs[1] = mxextentStr;
            nlhs = 1;
            plhs[0] = mxsizMat;
            mexCallMATLAB(nlhs,plhs,nrhs,prhs,"get");
            siz = mxGetPr(plhs[0]);

            /* Fudge the text size based on the host. */
            /* On anything other than a Mac, pull back the size one space. */
            if ((computer[0] != 'M') || (computer[1] != 'A')) siz[2] -= 1.0;

            xpos += siz[2];
            ypos -= bLH;  /* Negate the carriage return that occurs on loop exit. */
            break;  /* This forces a re-calculation of nextp. */

         /* Create an ordered (numbered) list. */
         } else if (cmdlet == 'o') {
            listmode = 1;
            listcnt = 0;

         /* Paragraph break or preformatted text. */
         } else if (cmdlet == 'p') {
            /* Preformatted text. */
            if (cmdlet2 == 'r') {
              /*
               * set(ax,'DefaultTextFontName','Courier',...
               *        'DefaultTextFontSize',10);
               */
               nrhs = 5;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFNStr;
               prhs[2] = mxCourierStr;
               prhs[3] = mxDTextFSStr;
               prhs[4] = mxfontsizeMat;
               t = 10;
               *mxGetPr(prhs[4]) = t;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

               preflg = 1;  /* Indicates preformatted text processing. */
               xpos = 0.0;
               break;

            /* Paragraph break. */
	    } else {
               xpos = 0.0;
               bLH = pLH;
               ypos += bLH;
               break;
	    }

         /* Typewriter text. */
         } else if (cmdlet == 't') {
              /*
               * set(ax,'DefaultTextFontName','Courier',...
               *        'DefaultTextFontSize',10);
               */
               nrhs = 5;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFNStr;
               prhs[2] = mxCourierStr;
               prhs[3] = mxDTextFSStr;
               prhs[4] = mxfontsizeMat;
               t = 10;
               *mxGetPr(prhs[4]) = t;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

         /* Create an unnumbered list. */
         } else if (cmdlet == 'u') {
            listmode = 2;
	 
         /* Process command to turn something off. */
         } else if (cmdlet == '/') {
	    /* Turn off a link reference. */
            if (cmdlet2 == 'a') inlink = 0;

	    /* Turn off bold or blockquote. */
	    else if (cmdlet2 == 'b') {
               if (cmdbdylow[1] == 'l') {
                  indmode = 0;
	       } else {
	         /*
                  * set(ax,'DefaultTextFontWeight','normal');
                  */
                  nrhs = 3;
                  prhs[0] = mxaxMat;
                  *mxGetPr(prhs[0]) = ax;
                  prhs[1] = mxDTextFWStr;
                  prhs[2] = mxnormalStr;
                  nlhs = 0;
	          mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");
	       }

	    /* Turn off definition list. */
	    } else if (cmdlet2 == 'd') {
               indmode = 0;
               xpos = 0;
               ypos += bLH;
               break;

            /* Turn off a heading. */
            } else if (cmdlet2 == 'h') {
              /*
               * set(ax,'DefaultTextFontName',basefontname,...
               *        'DefaultTextFontSize',basefontsize);
               */
               nrhs = 5;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFNStr;
               prhs[2] = mxbaseFNMat;
               prhs[3] = mxDTextFSStr;
               prhs[4] = mxfontsizeMat;
               *mxGetPr(prhs[4]) = basefontsize;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

               pLH = LH[3];
               xpos = 0;
               break;

            /* Turn off italics. */
            } else if (cmdlet2 == 'i') {
              /*
               * set(ax,'DefaultTextFontAngle','normal');
               */
               nrhs = 3;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFAStr;
               prhs[2] = mxnormalStr;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

            /* End an ordered or unnumbered list. */
            } else if ((cmdlet2 == 'o') || (cmdlet2 == 'u')) {
               tab = 5;
               indmode = 0;
               listmode = 0;
               xpos = 0;
               ypos += bLH;
               break;

            /* Turn off preformatted or typewriter text. */
            } else if ((cmdlet2 == 'p') || (cmdlet2 == 't')) {
              /*
               * set(ax,'DefaultTextFontName',basefontname,...
               *        'DefaultTextFontSize',basefontsize);
               */
               nrhs = 5;
               prhs[0] = mxaxMat;
               *mxGetPr(prhs[0]) = ax;
               prhs[1] = mxDTextFNStr;
               prhs[2] = mxbaseFNMat;
               prhs[3] = mxDTextFSStr;
               prhs[4] = mxfontsizeMat;
               *mxGetPr(prhs[4]) = basefontsize;
               nlhs = 0;
	       mexCallMATLAB(nlhs,plhs,nrhs,prhs,"set");

               preflg = 0;

	    }  /* End of '/' processing. */

         }  /* End of box command processing. */

      /* Processing for an escape character. */
      } else if (code[0] == 'e') {
         tmp[0] = '\0';
         if (cmdlet == 'l') tmp[0] = '<';
         else if (cmdlet == 'g') tmp[0] = '>';
	 else if (cmdlet == 'a') tmp[0] = '&';
	 else if (cmdlet == 'q') tmp[0] = '\"';
         tmp[1] = '\0';

        /*
         * text('position',[xpos ypos],...
         *      'string',tmp,...
         *      'tag',nexttexttag);
         */
         nrhs = 6;
         prhs[0] = mxPositionStr;
         prhs[1] = mxPosMat;
         pos[0] = xpos; pos[1] = ypos;
         memcpy(mxGetPr(prhs[1]), &pos, 2*sizeof(double));
         prhs[2] = mxStringStr;
         prhs[3] = mxCreateString(tmp);
         prhs[4] = mxTagStr;
         prhs[5] = mxCreateString(nexttexttag);
         nlhs = 1;
         plhs[0] = mxhMat;
         mexCallMATLAB(nlhs,plhs,nrhs,prhs,"text");
         h = mxGetScalar(plhs[0]);

        /*
         * siz = get(h,'extent');
         */
         nrhs = 2;
         prhs[0] = mxhMat;
         *mxGetPr(prhs[0]) = h;
         prhs[1] = mxextentStr;
         nlhs = 1;
         plhs[0] = mxsizMat;
         mexCallMATLAB(nlhs,plhs,nrhs,prhs,"get");
         siz = mxGetPr(plhs[0]);

         /* Fudge the text size based on the host. */
         /* On anything other than a Mac, pull back the size one space. */
         if ((computer[0] != 'M') || (computer[1] != 'A')) siz[2] -= 1.0;

         xpos += siz[2];

      }  /* End of box and escape processing. */
      
   }  /* End while for line. */

   ypos += bLH;
   if (p >= nextp) {   
      p = nextp + 1;  /* Skip over the EOL character. */
      if (*p == ' ') p++;  /* Skip over additional space if two in a row at break. */
      if ((nextp = p) == NULL) break;
   }
   linnum ++;

   /* Skip over completely blank lines. */
   /* Ignore for now...
    * while (nextp == p) {
    *    p = nextp + 1;
    *    if ((nextp = strchr(p, '\n')) == NULL) {
    *       break;
    *       break;
    *    }
    * }
    */

}  /* End while for whole TextString. */

/* We're done placing this section on the axis.  Let's setup
 * the userdata in the axis to identify it.  In the tag we put
 * "fn:filename.hlp" or whatever 'thisfn' happens to be.
 * In the Userdata, the first item set here is the maximum value
 * of ypos.  The second item is the number of lines of text on the
 * screen which is initialized to zero here and set in HTHELP.  The
 * third item is the relative time (reltime) of the axis and is set
 * in HTHELP.  The final item is the Dialog Name which is set here.
 *
 * set(ax,'tag',['fn:' thisfn],'userdata',[ypos LinesPerScreen reltime DlgName]);
 */
tag[0] = '\0';
strcat(tag, "fn:");
strcat(tag, thisfn);

/* Set the axis user data. */
prhs[4] = mxCreateDoubleMatrix(1, 100, mxREAL);
aud = mxGetPr(prhs[4]);
aud[0] = ypos;
aud[1] = 0;                              /* Leaves room for time entry. */
for (i=0;i < (int) strlen(DlgName);i++)  /* to be done in HTHELP.       */
  aud[3 + i] = DlgName[i];
aud[3 + i] = '\0';

/* Set up for the MATLAB call. */
prhs[2] = mxCreateString(tag);
mexSet(ax,"tag",prhs[2]);
mexSet(ax,"userdata",prhs[4]);

/* Free allocated memory. */
mxFree(tmp);
mxFree(TextStringLow);
if (lnkLow) mxFree(lnkLow);  /* Only free if lnkLow was used. */

/* The end. */
return (TextString);
}

/*
 ********************************************************************** 
 * Gateway function to MATLAB.
 ********************************************************************** 
 */
void mexFunction(
	int		nlhs,
	mxArray	*plhs[],
	int		nrhs,
	const mxArray *prhs[]
	)
{
	char *TS,*cmd,*fn,*lnk,*txt,*computer;
        double fig,ax,*LH;
        unsigned int ln;

        /* Check for proper number of arguments */
	if (nrhs != 8) {
	   mexErrMsgTxt("LOADHTML requires eight input arguments.");
	} else if (nlhs > 1) {
	   mexErrMsgTxt("LOADHTML requires one output argument.");
	}

        /* Convert MATLAB double pointers to strings. */
        ln = mxGetN(prhs[0])+1;
        cmd = mxCalloc(ln,sizeof(char));
        mxGetString(prhs[0],cmd,ln);

        ln = mxGetN(prhs[1])+1;
        fn = mxCalloc(ln,sizeof(char));
        mxGetString(prhs[1],fn,ln);

        ln = mxGetN(prhs[2])+1;
        lnk = mxCalloc(ln,sizeof(char));
        mxGetString(prhs[2],lnk,ln);

        ln = mxGetN(prhs[3])+1;
        txt = mxCalloc(ln,sizeof(char));
        mxGetString(prhs[3],txt,ln);

        fig = mxGetScalar(prhs[4]);

        ax = mxGetScalar(prhs[5]);

	LH = mxGetPr(prhs[6]);

        ln = mxGetN(prhs[7])+1;
        computer = mxCalloc(ln,sizeof(char));
        mxGetString(prhs[7],computer,ln);

	/* Do the actual reading and parsing in a subroutine */
	TS = loadhtml(cmd,fn,lnk,txt,fig,ax,LH,computer);

	/* Create a string matrix for the return argument */
        plhs[0] = mxCreateString(TS);

        mxFree(cmd);
        mxFree(fn);
        mxFree(lnk);
        mxFree(computer);
        mxFree(TS);

	return;
}




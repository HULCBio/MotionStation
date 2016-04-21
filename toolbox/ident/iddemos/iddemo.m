echo off
%   The SYSTEM IDENTIFICATION TOOLBOX is an analysis module
%   that contains tools for building mathematical models of
%   dynamical systems, based upon observed input-output data.
%   The toolbox contains both PARAMETRIC and NON-PARAMETRIC
%   MODELING methods.
%
%   Identification Toolbox demonstrations:
%
%   1) The Graphical User Interface (ident): A guided Tour.
%   2) Build simple models from real laboratory process data.
%   3) Compare different identification methods.
%   4) Data and model objects in the Toolbox.
%   5) Dealing with multivariable systems.
%   6) Building structured and user-defined models.
%   7) Model structure determination case study.
%   8) Use of frequency domain data.
%   9) How to deal with multiple experiments.
%   10) Spectrum estimation (Marple's test case).
%   11) Adaptive/Recursive algorithms.
%   12) Use of SIMULINK and continuous time models.
%   13) Case studies.
%   14) Use of Process Models (gain+time constant+delay)
%
%   0) Quit

%   L. Ljung
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $ $Date: 2004/04/10 23:16:06 $

k=0;
while (1)
   help iddemo
   k = input('Select a demo number: ');
   if isempty(k),k=20;end
   if k == 0, break, end
   if k==1, iduidemo(0),break, end
   if k==2, iddemo1, end
   if k==3, iddemo2, end
   if k==4, iddemo6, end
   if k==5, iddemo9, end
   if k==6, iddemo7, end
   if k==7, iddemo3, end
   if k==8, iddemofr, end
   if k==9, iddemo8, end
   if k==10,iddemo4, end
   if k==11,iddemo5,end
   if k==12,iddemosl,end
   if k==13, cs,      end
   if k==14, iddemopr,end
end

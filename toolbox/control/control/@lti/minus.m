function SysOut = minus(Sys1,Sys2)
%MINUS  Binary minus for LTI models.
%          
%   SYS = MINUS(SYS1,SYS2) is invoked by SYS=SYS1-SYS2.
%
%   See also PLUS, UMINUS, LTIMODELS.

%   Author(s): A. Potvin, 3-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 05:49:37 $

SysOut = Sys1 + (-Sys2);

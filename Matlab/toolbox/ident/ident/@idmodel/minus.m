function SysOut = minus(Sys1,Sys2)
%MINUS  Binary minus for IDMODEL models.
%          
%   MOD = MINUS(MOD1,MOD2) is invoked by MOD=MOD1-MOD2.
%
%   See also PLUS, UMINUS.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2001/04/06 14:22:16 $

SysOut = Sys1 + (-Sys2);

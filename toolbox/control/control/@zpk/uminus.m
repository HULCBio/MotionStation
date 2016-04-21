function sys = uminus(sys)
%UMINUS  Unary minus for LTI models.
%
%   MSYS = UMINUS(SYS) is invoked by MSYS = -SYS.
%
%   See also MINUS, LTIMODELS.

%       Author(s): A. Potvin, 3-1-94
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.9 $  $Date: 2002/04/10 06:11:40 $

% Effect on other properties: none

sys.k = -sys.k;


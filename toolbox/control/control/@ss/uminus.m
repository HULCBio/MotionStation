function sys = uminus(sys)
%UMINUS  Unary minus for LTI models.
%
%   MSYS = UMINUS(SYS) is invoked by MSYS = -SYS.
%
%   See also MINUS, LTIMODELS.

%       Author(s): A. Potvin, 3-1-94
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $  $Date: 2002/04/10 06:00:03 $

for k=1:prod(size(sys.c))
   sys.c{k} = -sys.c{k};
end
sys.d = -sys.d;


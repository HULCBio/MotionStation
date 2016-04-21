function sys = uminus(sys)
%UMINUS  Unary minus for LTI models.
%
%   MSYS = UMINUS(SYS) is invoked by MSYS = -SYS.
%
%   See also MINUS, LTIMODELS.

%   Author(s): A. Potvin
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:06:37 $

% Effect on other properties: None

for k=1:prod(size(sys)),
   sys.num{k} = -sys.num{k};
end


function sys = uminus(sys)
%UMINUS  Unary minus for LTI models.
%
%   MSYS = UMINUS(SYS) is invoked by MSYS = -SYS.
%
%   See also MINUS, LTIMODELS.

%   Author(s): S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:16:19 $

% Effect on other properties: None

sys.ResponseData = -sys.ResponseData;


function U = ipex003( X, t )
% Transforms X from two dimensions to three by appending
% a constant column containing the scalar value in t.tdata.
% A handle to this function can be passed to
% MAKETFORM('custom',...) as its INVERSE_FCN argument.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/01/26 06:02:41 $

U = [X repmat(t.tdata,[size(X,1) 1])];

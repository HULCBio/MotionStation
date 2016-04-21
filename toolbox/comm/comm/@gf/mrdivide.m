function z = mrdivide(x,y,varargin)
%MRDIVIDE Matrix right division / of GF arrays.
%   A/B is the matrix division of B into A, which is roughly the
%   same as A*INV(B), except it is computed in a different way.
%   More precisely, A/B = (B'\A')'. See MLDIVIDE for details.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:16:03 $ 

z = transpose(mldivide(transpose(y),transpose(x)));


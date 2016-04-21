function d = nnmdlin(a,d,w)
%NNMDLIN  Logistic Delta Function for Marquardt.
%         Returns the delta values for a layer of
%         linear neurons.
%         (See MDELTALOG,MDELTATAN,LEARN_MARQ,PURELIN)
%         
%         NNMDLIN(A)
%         Returns a matrix of delta vectors for an ouput
%         layer.
%
%         NNMDLIN(A,D,W), D is an S2xQ matrix,
%           W is an S2xS1 matrix.
%         Returns a matrix of delta vectors for a hidden
%         layer of linear neurons whose outputs have
%         been passed through a weight matrix W to another
%         layer with delta vectors D.

% $Revision: 1.6 $
% First Version, 8-31-95.
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.


%==================================================================

[na,ma]=size(a);

if nargin == 1
  d=-kron(ones(1,ma),eye(na));
else
  d = w'*d;
end


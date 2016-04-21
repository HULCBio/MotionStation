function d = nnmdlog(a,d,w)
%  NNMDLOG Logistic Delta Function for Marquardt.
%          Returns the delta values for a layer of
%          log-sigmoid neurons for use with Marquardt
%          backpropagation.
%          (See MDELTALIN,MDELTATAN,LEARN_MARQ,TANSIG)
%          
%          NNMDLOG(A), A is an SxQ matrix.
%          Returns a matrix of delta vectors for an OUTPUT
%          layer of log-sigmoid neurons with outputs A
%          for the network.
%
%          NNMDLOG(A,D,W), A is an S1xQ matrix,
%            D is an S2xQ matrix, W is an S2xS1 matrix.
%          Returns a matrix of delta vectors for a HIDDEN
%          layer of log-sigmoid neurons with outputs A
%          which had been passed through a weight matrix W
%          to another layer with delta vectors D.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

[s1,q]=size(a);

if nargin == 1
  d = -kron(((ones-a).*a),ones(1,s1)).*kron(ones(1,s1),eye(s1));
else
  d = ((ones-a).*a).*(w'*d);
end

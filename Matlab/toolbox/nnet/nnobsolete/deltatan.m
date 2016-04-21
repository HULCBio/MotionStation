function d = deltatan(a,d,w)
%DELTATAN Delta function for TANSIG neurons.
%
%  This function is obselete.
%  Use DTANSIG to calculates TANSIG derivatives.

nntobsf('deltatan','Use DTANSIG to calculates TANSIG derivatives.')

%          
%  DELTATAN(A,E)
%    A - S1xQ matrix of output vectors
%    E - S1xQ matrix of associated errors
%  Returns an SxQ matrix of output layer derivatives.
%  
%  DELTATAN(A,D,W)
%    D - S2xQ matrix of next layer delta vectors
%    W - S2xS1 weight matrix between layers.
%  Returns an SxQ matrix of hidden layer derivatives.
%  
%  DELTATAN(A)
%  Returns derivatives of outputs A (not error) for TRAINLM.
%  
%  See also NNTRANS, BACKPROP, TANSIG, DELTALOG, DELTALIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:53 $

if nargin < 1,error('Not enough input arguments'),end

if nargin == 1
  d = 1-(a.*a);
elseif nargin == 2
  d = (1-(a.*a)).*d;
else
  d = (1-(a.*a)).*(w'*d);
end

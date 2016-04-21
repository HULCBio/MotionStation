function d = deltalin(a,d,w)
%DELTALIN Delta function for PURELIN neurons.
%
%  This function is obselete.
%  Use DPURELIN to calculates PURELIN derivatives.

nntobsf('deltalin','Use DPURELIN to calculates PURELIN derivatives.')

%  
%  DELATLIN(A)
%    A - S1xQ matrix of output vectors.
%  Returns the S1xQ matrix of derivatives of the output vectors
%    with respect to the net input of the PURELIN transfer function.
%  
%  DELTALIN(A,E)
%    E - S1xQ matrix of associated errors
%  Returns an S1xQ matrix of derivatives of error for an output layer.
%  
%  DELTALIN(A,D,W)
%    D - S2xQ matrix of next layer delta vectors
%    W - S2xS1 weight matrix between layers.
%  Returns an S1xQ matrix of derivatives of error for a hidden layer.
%  
% See also NNTRANS, BACKPROP, PURELIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:44 $

if nargin == 1
  d = ones(size(a));
elseif nargin == 2
  d = d;
else
  d = w'*d;
end

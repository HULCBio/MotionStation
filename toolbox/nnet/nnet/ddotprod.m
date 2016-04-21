function d=ddotprod(code,w,p,z)
%DDOTPROD Dot product weight derivative function.
%
%  Syntax
%  
%    dZ_dP = ddotprod('p',W,P,Z)
%    dZ_dW = ddotprod('w',W,P,Z)
%
%  Description
%  
%    DDOTPROD is a weight derivative function.
%
%    DDOTPROD('p',W,P,Z) takes three arguments,
%      W - SxR weight matrix.
%       P - RxQ Inputs.
%      Z - SxQ weighted input.
%    and returns the SxR derivative dZ/dP.
%
%    DDOTPROD('w',W,P,Z) returns the RxQ derivative dZ/dW.
%
%  Examples
%
%    Here we define a weight W and input P for an input with
%    3 elements and a layer with 2 neurons.
%
%      W = [0 -1 0.2; -1.1 1 0];
%      P = [0.1; 0.6; -0.2];
%     
%    Here we calculate the weighted input with DOTPROD, then
%    calculate each derivative with DDOTPROD.
%
%      Z = dotprod(W,P)
%      dZ_dP = ddotprod('p',W,P,Z)
%      dZ_dW = ddotprod('w',W,P,Z)
%
%  Algorithm
%
%    The derivative of a product of two elements with respect to one
%    element is the other element.
%
%      dZ/dP = W
%      dZ/dW = P
%
%  See also DOTPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

switch code
  case 'p', d = w;
  case 'w', d = p;
  otherwise, error(['Unrecognized code.'])
end

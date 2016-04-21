function w = initc(p,s)
%INITC Inititialize competitive layer.
%
%  This function is obselete.
%  Use NNT2C and INIT to update and initialize your network.

nntobsf('initc','Use NNT2C and INIT to update and initialize your network.')

%  INITC(P,S)
%    P - Rx2 matrix of input vectors.
%    S - Number of neurons in layer.
%  Returns SxR weight matrix.
%  
%  IMPORTANT: Each ith row of P must contain expected
%    min and max values for the ith input.
%  
%  EXAMPLE: W = initc([-2 2;0 5],3)
%           p = [1 2 3]';
%           a = simuc(p,W)
%  
%  See also INITFUN, COMPNET, SIMUC, TRAINC.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:56 $

% INPUTS
[R,Q] = size(p);
if Q < 2,error('First argument did not have multiple columns.'),end

w = midpoint(s,p);

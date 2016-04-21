function w = initsm(p,s)
%INITSM Inititialize self-organizing map.
%  
%  This function is obselete.
%  Use NNT2SOM and INIT to update and initialize your network.

nntobsf('initsm','Use NNT2SOM and INIT to update and initialize your network.')

%  INITSM(P,S)
%    P - Rx2 matrix of input vectors.
%    S - Number of neurons in layer.
%  Returns:
%    W - SxR weight matrix.
%  
%  IMPORTANT: Each ith row of P must contain expected
%    min and max values for the ith input.
%  
%  EXAMPLE: w = initsm([-2 2;0 5],6);
%           m = nbgrid(2,3);
%           p = [1; 2];
%           a = simusm(p,w,m)
%  
%  See also NNINIT, SELFORG, SIMUSM, TRAINSM.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:14 $

% INPUTS
[R,Q] = size(p);
if Q < 2,error('Matrix expected as first argument.'),end

w = midpoint(s,[min(p,[],2) max(p,[],2)]);

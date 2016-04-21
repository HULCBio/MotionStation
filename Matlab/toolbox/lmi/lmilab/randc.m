% RANDC returns random matrix with entries in [-0.5,0.5]

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [M] = randc(m,n)

if nargin==1, n=m; end

M=rand(m,n)-.5*ones(m,n);

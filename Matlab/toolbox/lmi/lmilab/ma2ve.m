% V=ma2ve(M,type)
%
% Converts the matrix M into the vector V of its "free entries".
% The matrix data is stored row by row and structure
% is taken into account. For symmetric matrices, only data on
% or below the diagonal is stored in V.
%
% Input:
%    M           matrix
%    TYPE        specifies the structure of M
%                   1 -> symmetric
%                   2 -> full rectangular
%

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $
function [V]=ma2ve(M,type)

if nargin < 2, error('usage: V=ma2ve(M,type)'); end

V=[];

if isempty(M), return; end

if type==1,

  % WARNING: M symmetrized if necessary...
  M=(M+M')/2;

  i=1;
  for col=M,
    V=[V;col(1:i)]; i=i+1;
  end

else

%%% v4 code
%  V(:)=M';

%%% v5 code
   tmpM = M';
   V = tmpM(:);
end

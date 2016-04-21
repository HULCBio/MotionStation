function m = nnminr(m)
%NNMINR Find minimum of each row.
%  
%  This function is obselete.
%  Use MIN(M,[],1).

nntobsf('nnminr','Use MIN(M,[],1).')

% NNMINR(M)
%   M - matrix.
% Returns column of minimum row values.
%
% EXAMPLE: M = [1 2 3; 4 5 2]
%          nnminr(M)
%
% SEE ALSO: nnmaxr

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:12 $

[N,M] = size(m);

if M > 1
  m = min(m')';
end

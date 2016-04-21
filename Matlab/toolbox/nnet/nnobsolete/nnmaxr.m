function m = nnmaxr(m)
%NNMAXR Find maximum of each row.
%  
%  This function is obselete.
%  Use MAX(M,[],1).

nntobsf('nnmaxr','Use MAX(M,[],1).')

%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNMAXR(M)
%   M - Matrix.
% Returns column of maximum row values.
%
% EXAMPLE: M = [1 2 3; 4 5 2]
%          maxrow(M)
%
% SEE ALSO: nnmaxr

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:09 $

[N,M] = size(m);

if M > 1
  m = max(m')';
end

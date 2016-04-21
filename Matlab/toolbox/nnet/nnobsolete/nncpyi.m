function b = nncpyi(m,n)
%NNCPYI Make interleaved copies of a matrix.
%  
%  This function is obselete.

nntobsf('nncpyi','')

%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNCPYI(M,N)
%   M - Matrix of columns = [C1 C2 ...].
%   N - Number of copies to make.
% Returns:
%   Matrix = [C1 C1 ... C1 C2 C2 ... C2 ... ]
%   where each column in M appears N times.
%
% EXAMPLE: M = [1 2; 3 4; 5 6];
%          n = 3;
%          X = nncpyi(M,n)
%
% SEE ALSO: nncpy, nncpyd

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:02 $

[mr,mc] = size(m);
b = zeros(mr*n,mc);
ind = 1:mr;
for i=[0:(n-1)]*mr
  b(ind+i,:) = m;
end
b = reshape(b,mr,n*mc);

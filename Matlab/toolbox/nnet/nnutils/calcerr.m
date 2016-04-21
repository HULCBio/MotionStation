function d=calcerr(a,b)
%CALCERR Calculates matrix or cell array errors.
%
%  E = CALCERR(T,A)
%    T - MxN matrix.
%    A - MxN matrix.
%  Returns
%    D - MxN matrix A-B.
%
%  E = CALCERR(A,B)
%    T - MxN cell array of matrices A{i,j}.
%    A - MxN cell array of matrices B{i,j}.
%  Returns
%    D - MxN cell array of matrices A{i,j}-B{i,j}.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:17:33 $

if isa(a,'double') & isa(b,'double')

  d = a-b;

elseif isa(a,'cell') & isa(b,'cell')

  [m,n] = size(a);
  d = cell(m,n);
  for i=1:m
    for j=1:n
      d{i,j} = a{i,j}-b{i,j};
    end
  end

else

  error('Inputs must both be matrices or both be cell-arrays')

end

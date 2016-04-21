function d = dnullpf(code,e,x,perf,pp)
%DNULLPF Derivative of null performance function.
%
%  DNULLPF('E',E,X,PERF)
%    E    - Layer errors.
%    X    - Vector of weight and bias values.
%   Returns zeros.
%
%  DNULLPF('X',E,X,PERF)
%   Returns zeros.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

switch lower(code)
  case 'e',
    [rows,cols] = size(e);
    d = cell(rows,cols);
  for i=1:rows
    for j=1:cols
      d{i,j} = zeros(size(e{i,j}));
    end
  end

  case 'x',
    d = zeros(size(x));

  otherwise,
    error(['Unrecognized code.'])
end

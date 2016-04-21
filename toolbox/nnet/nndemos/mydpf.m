function d = mydpf(code,e,x,perf,pp)
%MYDPF Example custom performance derivative function for MYPF.
%
%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    dPerf_dE = mydpf('e',E,X,perf,PP)
%    dPerf_dX = mydpf('x',E,X,perf,PP)
%      E  - Cell array of error vector(s).
%      X  - Vector of all weight and bias values.
%      PP - Performance parameters.
%      dPerf_dE - Cell array of derivative of performance dPerf/dE.
%      dPerf_dX - Derivative of performance dPerf/dX.
%
%  Example
%
%    e = {rand(4,5)};
%    x = rand(12,1);
%    pp = mypf('pdefaults')
%    perf = mypf(e,x,pp)
%    dperf_de = mydpf('e',e,x,perf,pp)
%    dperf_dx = mydpf('x',e,x,perf,pp)

% Copyright 1997-1998 The MathWorks, Inc.
% $Revision: 1.3.2.1 $

if nargin < 5, error('Not enough input argument.'), end

switch (code)
case 'e'

% ** Replace this code with your own calculation of dPerf/dE.

  [rows,cols] = size(e);
  d = cells(rows,cols);
  
  totalRows = 0;
  for i=1:rows, totalRows = totalRows + size(e{i,1},1); end
  totalCols = 0;
  for j=1:cols, totalCols = totalCols + size(e{1,i},2); end
  numErrors = totalRows*totalCols;
  
  for i=1:rows
    for j=1:cols
    d{i,j} = sign(e{i,j}) * 1/numErrors;
  end
  end
  
case 'x'

% ** Replace this code with your own calculation of dPerf/dX.

  numWeightsBiases = length(x);
  d = sign(x) * 1/numWeightsBiases;
end

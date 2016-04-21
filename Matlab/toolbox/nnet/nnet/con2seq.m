function s=con2seq(b,ts)
%CON2SEQ Convert concurrent vectors to sequential vectors.
%
%  Syntax
%  
%    s = con2seq(b)
%
%  Description
%
%    The neural network toolbox arranges concurrent vectors
%    with a matrix, and sequential vectors with a cell array
%    (where the second index is the time step).
%
%    CON2SEQ and SEQ2CON allow concurrent vectors to be converted
%    to sequential vectors, and back again.
%
%    CON2SEQ(B) takes one input,
%      B - RxTS matrix.
%    and returns one output,
%      S - 1xTS cell array of Rx1 vectors.
%
%    CON2SEQ(B,TS) can also convert multiple batches,
%      B  - Nx1 cell array of matrices with M*TS columns.
%      TS - Time steps.
%    and will return,
%      S - NxTS cell array of matrices with M columns.
%
%  Example
%
%    Here a batch of three values is converted to a
%    sequence.
%
%      p1 = [1 4 2]
%      p2 = con2seq(p1)
%
%    Here two batches of vectors are converted to a
%    two sequences with two time steps.
%
%      p1 = {[1 3 4 5; 1 1 7 4]; [7 3 4 4; 6 9 4 1]}
%      p2 = con2seq(p1,2)
%
%  See also SEQ2CON, CONCUR.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 2
  ts = size(b,2);
  b = {b};
end

if ~isa(b,'cell'),
 error('Input argument must be a cell array');
end
if size(b,2) ~= 1
  error('Input argument must have only one column.')
end
n = size(b,1);
s = cell(n,ts);
for i=1:n
  if isempty(b{i})
    s(i,:) = cell(1,ts);
  else
    q1 = size(b{i},2);
  q2 = q1/ts;
  if (q2*ts ~= q1)
    error('Matrix cannot be divided into TS parts equally.');
  end
  for j=1:ts
    s{i,j} = b{i}(:,[1:q2]+(j-1)*q2);
  end
  end
end

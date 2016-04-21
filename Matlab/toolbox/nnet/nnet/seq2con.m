function b=seq2con(s)
%SEQ2CON Convert sequential vectors to concurrent vectors.
%
%  Syntax
%
%    b = seq2con(s)
%
%  Description
%
%    The neural network toolbox represents batches of vectors
%    with a matrix, and sequences of vectors with multiple
%    columns of a cell array.
%
%    SEQ2CON and CON2SEQ allow concurrent vectors to be converted
%    to sequential vectors, and back again.
%
%    SEQ2CON(S) takes one input,
%      S - NxTS cell array of matrices with M columns.
%    and returns,
%      B - Nx1 cell array of matrices with M*TS columns.
%
%  Example
%
%    Here three sequential values are converted to concurrent values.
%
%      p1 = {1 4 2}
%      p2 = seq2con(p1)
%
%    Here two sequences of vectors over three time steps
%    are converted to concurrent vectors.
%
%      p1 = {[1; 1] [5; 4] [1; 2]; [3; 9] [4; 1] [9; 8]}
%      p2 = seq2con(p1)
%
%  See also CON2SEQ, CONCUR.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:34:53 $

% 3D case
if (ndims(s) == 3)
  r = size(s,1);
  c = size(s,2);
  b = cell(r,c);
  for i=1:r
    for j=1:c
      b{i,j} = [ s{i,j,:} ];
    end
  end
  return
end

% 2D case
r = size(s,1);
b = cell(r,1);
for i=1:r
  b{i} = [ s{i,:} ];
end

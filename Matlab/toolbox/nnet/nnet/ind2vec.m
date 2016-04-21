function v=ind2vec(i)
%IND2VEC Convert indices to vectors.
%
%  Syntax
%
%    vec = ind2vec(ind)
%
%  Description
%
%    IND2VEC and VEC2IND allow indices to be represented
%    either by themselves, or as vectors containing a 1 in the
%    row of the index they represent.
%
%    IND2VEC(IND) takes one argument,
%      IND - Row vector of indices.
%    and returns sparse matrix of vectors, with one 1 in
%    each column, as indicated by IND.
%
%  Examples
%
%    Here four indices are defined and converted to vector
%    representation.
%
%      ind = [1 3 2 3]
%      vec = ind2vec(ind)
%
%  See also VEC2IND.

% Mark Beale, 2-15-96.
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $

vectors = length(i);
v = sparse(i,1:vectors,ones(1,vectors));

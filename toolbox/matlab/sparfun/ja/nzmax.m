% NZMAX   行列内の非ゼロ要素に対して割り当てられるストレージの総量
% 
% スパース行列に対して、NZMAX(S) は S の非ゼロ要素に対して割り当てられた
% ストレージの量を出力します。
%
% フル行列に対して、NZMAX(S) は prod(size(S)) です。両方の場合で、
% nnz(S) < =  nzmax(S) < =  prod(size(S)) になります。
%
% 参考：NNZ, NONZEROS, SPALLOC.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:48 $

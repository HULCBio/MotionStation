% SPRANK   構造的なランク
% 
% r = SPRANK(A) は、スパース行列 A の構造的なランクを出力します。これは、
% 最大縦断、最大割り当て、2つに分かれた A のグラフでの最大マッチングと
% しても知られています。常に sprank(A) > =  rank(A) であり、正確には
% 確率が1で sprank(A) == rank(sprandn(A)) です。
%
% 参考：DMPERM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:36 $

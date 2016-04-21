% SETDIFF   差集合
% 
% SETDIFF(A,B) は、A と B がベクトルのとき、A の要素で B の要素でない
% 値を出力します。結果は、ソートされます。A と B は、文字列のセル配列
% でも設定できます。
%
% SETDIFF(A,B,'rows') は、A と B が同じ列数のとき、A から B にない行を
% 出力します。
%
% [C,I] = SETDIFF(...) は、C = A(I)(または C = A(I,:))のような、
% インデックスクベトル I を出力します。
% 
% 参考：UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:01 $

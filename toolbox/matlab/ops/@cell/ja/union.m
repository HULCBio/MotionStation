% UNION   文字列のセル配列に対する和集合
%
% UNION(A,B) は、A と B がベクトルのとき、A と B を組み合わせた値を出力
% しますが、重複するものは省きます。結果は、ソートされます
%
% [C,IA,IB] = UNION(A,B) は、C が要素 A(IA) と B(IB)(または A(IA,:) と 
% B(IB,:)) のソートされた組み合わせであるような、インデックスベクトル 
% IA と IB も出力します。
%
% 参考 : UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.


%   Copyright 1984-2002 The MathWorks, Inc. 

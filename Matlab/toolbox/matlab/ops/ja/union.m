% UNION   和集合
% 
% UNION(A,B) は、A と B がベクトルのとき、A と B を組み合わせた値を出力
% しますが、重複するものは省きます。結果は、ソートされます。A と B は、
% 文字列のセル配列でも設定できます。
%
% UNION(A,B,'rows') は、A と B が同じ列数をもつ行列のとき、A と B の各行
% を組み合わせた重複のない行を出力します
%
% [C,IA,IB] = UNION(...) は、C が要素 A(IA) と B(IB)(または A(IA,:) と 
% B(IB,:)) のソートされた組み合わせであるような、インデックスベクトル 
% IA と IB も出力します。
% 
% 参考：UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:10 $

% SETXOR   排他的論理和
% 
% SETXOR(A,B) は、A と B がベクトルのとき、A と B の共通部分にない値を
% 出力します。結果は、ソートされます。A と B は、文字列のセル配列でも
% 設定できます。
%
% SETXOR(A,B,'rows') は、A と B が同じ列数の行列のとき、A と B の共通
% 部分にない行を出力します。
%
% [C,IA,IB] = SETXOR(A,B) は、C が A(IA) と B(IB) の要素の並び替えられた
% 組み合わせとなるようなインデックスベクトル IA と IB も出力します。
%
% 参考：UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:02 $

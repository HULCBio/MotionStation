% INTERSECT   集合の共通部分
% 
% INTERSECT(A,B) は、A と B がベクトルのとき、A と B の両方に共通な値を
% 出力します。結果はソートされます。A と B は、文字のセル配列でも構いません。
%
% INTERSECT(A,B,'rows') は、A と B が同じ列数の行列のとき、A と B の両方に
% 共通な行を出力します。
%
% [C,IA,IB] = INTERSECT(...) は、C = A(IA) かつ C = B(IB)(またはC = A(IA,:)
% かつ、C = B(IB,:)) のようなインデックスベクトル IA と IB を出力します。
%
% 参考：UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:00:41 $

% PRIMPOLY   ガロア体に対する原始多項式の検出
%
% PR = PRIMPOLY(M) は、GF(2^M) に対する次数 M の原始多項式を計算します。
%
% PR = PRIMPOLY(M, OPT) は、GF(2^M) に対する原始多項式を計算します。
% OPT = 'min'  最小の重みの原始多項式を検出
% OPT = 'max'  最大の重みの原始多項式を検出
% OPT = 'all'  すべての原始多項式を検出
% OPT = L      重み L のすべての原始多項式を検出
%   
% PR = PRIMPOLY(M, OPT, 'nodisplay') または、
% PR = PRIMPOLY(M, 'nodisplay') は、デフォルトの表示スタイルを無効に
% します。
%
% PR の各要素は、等価な10進数による多項式を表します。
% OPT = 'all' または L で、1つ以上の原始多項式が制約を満たす場合、PR の
% 各要素は、差分方程式を表します。
% 制約を満たす原始多項式がない場合、PR は空になります。
% 例題:
%     PR = primpoly(3)
% 
%     Primitive polynomial(s) = 
%
%     D^3+D^1+1
%
%     PR =
%
%     11
%
%     PR = primpoly(4,'nodisplay')
%
%     PR =
%
%     19
%
% 参考 : ISPRIMITIVE.


%   Copyright 1996-2002 The MathWorks, Inc.

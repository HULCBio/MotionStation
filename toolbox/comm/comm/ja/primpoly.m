% PRIMPOLY   ガロア体に対する原始多項式の検出
%
% PR = PRIMPOLY(M) は、GF(2^M) に対する次数 M の原始多項式を計算します。
%
% PR = PRIMPOLY(M, OPT) は、GF(2^M) に対する原始多項式を計算します。
% OPT = 'min'  最小重み付けの原始多項式を検出
% OPT = 'max'  最大重み付けの原始多項式を検出
% OPT = 'all'  すべての原始多項式を検出
% OPT = L      重み L のすべての原始多項式を検出
%   
% PR = PRIMPOLY(M, OPT, 'nodisplay') または、
% PR = PRIMPOLY(M, 'nodisplay') は、原始多項式のデフォルト表示スタイル
% を無効にします。文字列 'nodisplay' は、2番目か3番目の引数のどちらかに
% 与えることができます。
%
% 出力の列ベクトル PR は、等価な10進数によってリストされる多項式を表し
% ます。OPT = 'all' または、L で、1つ以上の原始多項式が制約を満たす場合、
% PR の各要素は、差分多項式を表します。制約を満たす原始多項式がない場合、
% PR は空になります。
%
% 参考: ISPRIMITIVE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $   $Date: 2003/06/23 04:35:03 $



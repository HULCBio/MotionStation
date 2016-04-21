% GFWEIGHT   線形ブロック符号の最小距離を計算
% 
% WT = GFWEIGHT(G) は、与えられた生成行列 G の最小距離を出力します。
% WT = GFWEIGHT(G, GH_FLAG) は、最小距離を出力します。ここで、GH_FLAG は、
% 最初の入力パラメータの特徴を指定するために使います。
%   GH_FLAG == 'gen' の場合、G は生成行列です。
%   GH_FLAG == 'par' の場合、G はパリティチェック行列です。
%   GH_FLAG == n の場合、コードワード長を表し、G は巡回符号、または BCH
%   符号のいずれかに対する生成多項式になります。
%
% 参考： HAMMGEN, CYCLPOLY, BCHPOLY.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $ Date: $

% UNFIXPAR  
% 状態空間と ARX モデル構造の固定パラメータを自由パラメータに変更
%   
%       TH = UNFIXPAR(TH_OLD, MATRIX, ELEMENTS)
%
%   TH       : 更新された THETA 行列
%   TH_OLD   : オリジナルの THETA 行列
%   MATRIX   : どの行列を操作するか('A','B','C','D','K','X0'のどれか1つ)
%   ELEMENTS : どの要素を操作するか、n 行2列の行列で、各行が操作する要素
%              の行番号と列番号、この引数が省略されると、すべての要素が
%              操作されます。
%
% 例題： 
%    th1 = unfixpar(th, 'A', [3,1;2,2;1,3]);
%
% 行列が 'A1', 'A2', ...,'B0', 'B1', ...と与えられると、ARX 構造の対応す
% る行列が操作され、そのように定義された TH_OLD が定義されます。
%
% 注意: 
% UNFIXPAR は、標準のモデル構造に対してのみ機能します。MS2TH, ARX2TH, 
% ARX で定義されます。TH_OLD がユーザ定義の構造(MF2TH)に基づく場合、
% ユーザ自身で自由パラメータを設定する必要があります。
%
% 参考:    ARX, ARX2TH, MS2TH, FIXPAR, PEM, THSS

%   Copyright 1986-2001 The MathWorks, Inc.

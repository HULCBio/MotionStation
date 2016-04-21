% WRCOEF2    2次元のウェーブレット係数から単一ブランチを再構成
% WRCOEF2 は、イメージの係数を再構成します。
%
% X = WRCOEF2('type',C,S,'wname',N) は、レベル N でウェーブレット分解構造 [C,S]
% (WAVEDEC2 を参照)をベースにして、再構成される係数行列を計算します。'wname' は、
% ウェーブレット名を示す文字列です。'type' = a の場合、 Approximation 係数が再構
% 成されます。また、'type' = 'h' ('v' または 'd')の場合、水平(垂直または対角)方
% 向の Detail 係数が再構成されます。
%
% レベル N は、以下の範囲の整数でなければなりません。
% 'type' = 'a' の場合、0 < =  N < =  size(S,1)-2  
% 'type' = 'h'、'v' または 'd' の場合、1 < =  N < =  size(S,1)-2 
%
% ウェーブレット名を与える代わりに、フィルタを設定することもできます。
% X = WRCOEF2('type',C,S,Lo_R,Hi_R,N) に対して、
%   Lo_R は、再構成ローパスフィルタです。
%   Hi_R は、再構成ハイパスフィルタです。
%
% X = WRCOEF2('type',C,S,'wname')、または、X = WRCOEF2('type',C,S,Lo_R,Hi_R) は、
% 最大レベル N = size(S,1)-2 の係数を再構成します。
%
% 参考： APPCOEF2, DETCOEF2, WAVEDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.

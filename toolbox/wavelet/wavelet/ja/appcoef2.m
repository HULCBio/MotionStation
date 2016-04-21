% APPCOEF2　　2次元 Approximation 係数の抽出
% APPCOEF2 は、2次元信号の Approximation 係数を計算します。
%
% A = APPCOEF2(C,S,'wname',N) は、ウェーブレット分解構造 [C,S](wavedec2 参照)を
% 使って、レベル N の Approximation 係数を計算します。'wname' は、ウェーブレット
% 名を含む文字列で、 レベル N は、0 < =  N < =  size(S,1)-2 を満たす整数です。
%
% A = APPCOEF2(C,S,'wname') は、最後のレベル size(S,1)-2 の Approximation 係数を
% 抽出します。
%
% ウェーブレット名の代わりに、フィルタを設定することもできます。A = APPCOEF2...
% (C,S,Lo_R,Hi_R)、または、A = APPCOEF2(C,S,Lo_R,Hi_R,N) に対して、Lo_R は再構成
% ローパスフィルタで、Hi_R は再構成ハイパスフィルタです。
% 
% 参考： DETCOEF2, WAVEDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.

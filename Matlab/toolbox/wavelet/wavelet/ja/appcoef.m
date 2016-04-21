% APPCOEF　1次元 Approximation 係数の抽出
% APPCOEF は、1次元信号の Approximation 係数を計算します。
%
% A = APPCOEF(C,L,'wname',N) は、ウェーブレット分解構造 [C,L](WAVEDEC を参照)を
% 使って、レベル N での Approximation 係数を計算します。'wname' は、ウェーブレッ
% ト名を含む文字列です。レベル N は、0 < =  N < =  length(L)-2を満たす整数です。
%
% A = APPCOEF(C,L,'wname') は、最後のレベル length(L)-2 の Approximation 係数を
% 抽出します。
%
% ウェーブレット名の代わりに、フィルタを設定することもできます。A = APPCOEF(...
% C,L,Lo_R,Hi_R)、または、A = APPCOEF(C,L,Lo_R,Hi_R,N) の設定に対して、Lo_R は再
% 構成ローパスフィルタで、 Hi_R は再構成ハイパスフィルタです。
%
% 参考： DETCOEF, WAVEDEC.



%   Copyright 1995-2002 The MathWorks, Inc.

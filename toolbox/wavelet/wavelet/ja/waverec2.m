% WAVEREC2 　 多重2次元ウェーブレット再構成
% WAVEREC2 は、指定された('wname'、WFILTERS を参照)特定のウェーブレットまたは特
% 定の再構成フィルタ(Lo_R 及び Hi_R)のいずれかを使って、多重2次元ウェーブレット
% 再構成を実行します。
%
% X = WAVEREC2(C,S,'wname') は、多重レベルウェーブレット分解構造 [C,S] に基づい
% て、行列 X を再構成します(WAVEDEC を参照2)。
%
% X = WAVEREC2(C,S,Lo_R,Hi_R) に対して
%   Lo_R は、再構成ローパスフィルタで、
%   Hi_R は、再構成ハイパスフィルタです。
%
% 参考： APPCOEF2, IDWT2, WAVEDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.

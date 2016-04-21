% WAVEREC 　多重1次元ウェーブレット再構成
% WAVEREC は、指定された('wname'、WFILTERS を参照)特定のウェーブレットまたは特定
% の再構成フィルタ(Lo_R 及び Hi_R)のいずれかを使って、多重1次元ウェーブレット再
% 構成を実行します。
%
% X = WAVEREC(C,L,'wname') は、多重レベルウェーブレット分解構造 [C,L] に基づいて、
% 信号 X を再構成します(WAVEDEC を参照)。
%
% X = WAVEREC(C,L,Lo_R,Hi_R) に対して
%   Lo_R は、再構成ローパスフィルタで、
%   Hi_R は、再構成ハイパスフィルタです。
%
% 参考： APPCOEF, IDWT, WAVEDEC.



%   Copyright 1995-2002 The MathWorks, Inc.

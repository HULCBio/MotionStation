% UPCOEF 　　1次元ウェーブレット係数から直接再構成を行います。
% Y = UPCOEF(O,X,'wname',N) は、ベクトル X の N ステップ目の再構成された係数を計
% 算します。'wname' は、ウェーブレット名を含む文字引数です。
% N は、厳密な意味での正の整数です。
% O = 'a' の場合、Approximation 係数が再構成されます。
% O = 'd' の場合、Detail 係数が再構成されます。
%
% Y = UPCOEF(O,X,'wname',N,L) は、ベクトル X の N ステップの再構成された係数を計
% 算します。そして、結果の中から中央の L の長さを抽出します。
%
% ウェーブレットの名前を設定する代わりにフィルタを設定することもできます。
% Y = UPCOEF(O,X,Lo_R,Hi_R,N)、または、Y = UPCOEF(O,X,Lo_R,Hi_R,N,L) に対して、
% Lo_R は、再構成ローパスフィルタ、Hi_R は、再構成ハイパスフィルタです。
%
% Y = UPCOEF(O,X,'wname') は、Y = UPCOEF(O,X,'wname',1) と等価です。
%
% Y = UPCOEF(O,X,Lo_R,Hi_R) は、Y = UPCOEF(O,X,Lo_R,Hi_R,1) と等価です。
%
% 参考： IDWT.



%   Copyright 1995-2002 The MathWorks, Inc.

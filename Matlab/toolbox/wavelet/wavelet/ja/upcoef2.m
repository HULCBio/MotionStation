% UPCOEF2　 2次元のウェーブレット係数から直接再構成を行います。
% Y = UPCOEF2(O,X,'wname',N,S) は、行列 X の N ステップの再構成された係数を計算
% し、結果の中央から大きさ S の部分を抽出します。'wname' は、ウェーブレット名を
% 含む文字引数です。 O = 'a' の場合、Approximation 係数が再構成されます。他の場
% 合、O = 'h' (または 'v' か 'd') では、水平(または垂直か対角)Detail 係数が再構
% 成されます。N は厳密な意味での正の整数でなくてはなりません。
%
% また、ウェーブレットの名前を設定する代わりにフィルタを設定することもできます。
% Y = UPCOEF2(O,X,Lo_R,Hi_R,N,S) に対して、
%   Lo_R は、再構成ローパスフィルタで、
%   Hi_R は、再構成ハイパスフィルタです。
% 
% Y = UPCOEF2(O,X,'wname') は、Y = UPCOEF2(O,X,'wname',1) と等価です。
%
% Y = UPCOEF2(O,X,Lo_R,Hi_R) は、Y = UPCOEF2(O,X,Lo_R,Hi_R,1) と等価です。
%
% 参考： IDWT2.



%   Copyright 1995-2002 The MathWorks, Inc.

% IDWTPER2　 単一レベルの逆離散2次元ウェーブレット変換(周期的な取り扱い)
% X = IDWTPER2(CA,CH,CV,CD,'wname') は、データの周期性をもたせた逆ウェーブレット
% 変換を使って、設定したレベルの Approximation 行列 CA と Detail 行列 CH、CV、CD
% をベースにして、単一レベルでの再構成 Approximation 係数行列 X を計算します。
% 'wname' は、ウェーブレット名の文字引数です(WFILTER を参照)。
%
% ウェーブレット名の代わりにフィルタを設定することもできます。X = IDWTPER2(...
% CA,CH,CV,CD,Lo_R,Hi_R) に対して、
%   Lo_R は、再構成ローパスフィルタ
%   Hi_R は、再構成ハイパスフィルタです。
%
% sa = size(CA) = size(CH) = size(CV) = size(CD) の場合、size(X) = 2*sa が成立し
% ます。
%
% X = IDWTPER2(CA,CH,CV,CD,'wname',S)、または、X = IDWTPER2(CA,CH,CV,CD,...
% Lo_R,Hi_R,S) に対して、S は出力のサイズとなります。
%
% 参考： DWTPER2.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.

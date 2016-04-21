% IDWTPER　　 単一レベルの逆離散1次元ウェーブレット変換(周期的取り扱い)
% X = IDWTPER(CA,CD,'wname') は、データの周期性をもたせた逆ウェーブレット変換を
% 使って、設定したレベルの Approximation 係数ベクトル CA と Detail 係数ベクトル 
% CD をベースにして、単一レベルでの再構成 Approximation 係数ベクトル X を計算し
% ます。'wname' は、ウェーブレット名の文字引数です(WFILTER を参照)。
%
% ウェーブレット名の代わりにフィルタを設定することもできます。X = IDWTPER(...
% CA,CD,Lo_R,Hi_R) に対して、
%   Lo_R は、再構成ローパスフィルタ
%   Hi_R は、再構成ハイパスフィルタです。
%
% la = length(CA) = length(CD) の場合、 length(X) = 2*la が成立します。
%
% X = IDWTPER(CA,CD,'wname',L)、または、X = IDWTPER(CA,CD,Lo_R,Hi_R,L) に対して、
% L は出力の長さとなります。
%
% 参考： DWTPER.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.

% DWTPER2  　単一レベルの離散2次元ウェーブレット変換(周期的取り扱い)
% [CA,CH,CV,CD] = DWTPER2(X,'wname') は、入力行列 X の周期性を用いたウェーブレッ
% ト分解により得られる Approximation 係数行列 CA と Detail 係数行列 CH,CV,CD を
% 計算します。'wname' は、ウェーブレット名を含む文字列です(WFILTERS を参照)。
%
% ウェーブレット名を設定する代わりに、フィルタを設定することもできます。入力引数
% を3つ設定すると、つぎのようになります。
% 
%   [CA,CH,CV,CD] = DWTPER2(X,Lo_D,Hi_D)
% 
% ここで、
%   Lo_D は、分解ローパスフィルタです。
%   Hi_D は、分解ハイパスフィルタです。
%
% sx = size(X) の場合、size(CA) = size(CH) = size(CV) = size(CD) = CEIL(sx/2) が
% 成立します。
%
% 参考： DWT2, IDWTPER2.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.

% DWTPER 　単一レベルの離散1次元ウェーブレット変換(周期的な取り扱い)
% [CA,CD] = DWTPER(X,'wname') は、ベクトル X の周期性を用いたウェーブレット分解
% によって得られる Approximation 係数ベクトル CA と Detail 係数ベクトル CD を計
% 算します。'wname' は、ウェーブレット名を含む文字列です(WFILTERS を参照)。
%
% ウェーブレット名を設定する代わりに、フィルタを設定することもできます。入力引数
% を3つ設定すると、つぎのようになります。
% 
%   [CA,CD] = DWTPER(X,Lo_D,Hi_D)
% 
% ここで、
%   Lo_D は、分解ローパスフィルタです。
%   Hi_D は、分解ハイパスフィルタです。
%
% lx = length(X) の場合、length(CA) = length(CD) = CEIL(lx/2) となります。
%
% 参考： DWT, IDWTPER.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.

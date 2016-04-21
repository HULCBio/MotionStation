% [u,s,v,rk,using,vsing]=svdparts(M,tolabs,tolrel)
%
% 行列Mのランクと左/右ヌル空間、非ゼロ特異値を計算します。
%
% 特異値S(i)は、絶対許容誤差TOLABSか相対許容誤差TOLREL以下のとき、"zero"
% とみなされます。つまり、つぎのようになります。
% 
%       S (i)  <  TOLABS 、または、S (i)  <  TOLREL * S (1)
% 
% ここで、S(1)は最大特異値です。関連するスレッシュホールドを無効にするた
% めには、TOLABS(TOLREL)をゼロに設定します。
%
% 出力:
%   S            すべての"non-zero"'特異値を含むベクトル
%   U, V         非ゼロ特異値に関連する特異値ベクトル:
%                              M = U diag(S) V'
%   RK           最大許容誤差TOLABS, TOLRELであるMのランク
%   USING,VSING  Mの左/右ヌル空間の基底
%
% 参考：    SVD.

% Copyright 1995-2001 The MathWorks, Inc. 

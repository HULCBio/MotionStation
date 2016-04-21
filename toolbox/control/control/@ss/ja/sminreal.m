% SMINREAL   構造的最小実現を計算
%
% MSYS = SMINREAL(SYS) は、状態空間モデル SYS からどの入出力にも接続
% されてない状態を削除します。結果の状態空間モデル MSYS は、SYS と等価で
% 構造的に最小化されています。すなわち、SYS.A, SYS.B, SYS.C, SYS.E の
% すべての非ゼロ要素を1に設定したとき最小になります。
%
% 参考 : MINREAL.


%   Author(s): P. Gahinet and A.C. Grace
%   Copyright 1986-2002 The MathWorks, Inc. 

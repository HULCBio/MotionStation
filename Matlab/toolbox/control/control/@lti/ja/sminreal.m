% SMINREAL   構造的最小実現を計算
%
%
% MSYS = SMINREAL(SYS) は、状態空間モデル SYS からどの入出力にも接続されてな
% い状態を削除します。結果の状態空間モデル MSYS は、SYS と等価で構造的に最小
% 化されています。 すなわち、SYS.A, SYS.B, SYS.C, SYS.E のすべての非ゼロ要素
% を1に設定したとき最小になります。
%
% 参考 : MINREAL.


% Copyright 1986-2002 The MathWorks, Inc.

% SOS2CELL は、二次型行列をセル配列に変換します。
% C = SOS2CELL(S) は、つぎの型をした L 行6列の二次型行列 S を
%
%        S =   [B1 A1
%               B2 A2
%                ...
%               BL AL]
%
% つぎの型をしたセル配列 C に変換します。
%
%     C = { {B1,A1}, {B2,A2}, ... {BL,AL} }
%
% ここで、個々の分子ベクトル Bi と分母ベクトル Ai は、線形または二次の多
% 項式の係数を表します。
%
% ゲイン要素を入力引数として設定した C = SOS2CELL(S,G) は、つぎのような
% 型の定数項をもつものに変換します。
%
%     C = { {G,1}, {B1,A1}, {B2,A2}, ... {BL,AL} }
%
% 例題：
%     [b,a] = butter(4,.5);
%     [s,g] = tf2sos(b,a);
%     c = sos2cell(s,g)
%
% 参考： CELL2SOS, TF2SOS, SOS2TF, ZP2SOS, SOS2ZP, SOS2SS, SS2SOS.



%   Copyright 1988-2002 The MathWorks, Inc.

% CELL2SOS は、セル配列を2次型の行列に変換します。
% SOS = CELL2SOS(C) は、セル配列 C をつぎの型に変換します。
%
%     C = { {B1,A1}, {B2,A2}, ... {BL,AL} },
%
% ここで、個々の分子ベクトル Bi と分母ベクトル Ai は、線形、または、二次
% 多項式の係数を表し、つぎの型のL 行6列の二次型行列 SOS に変換します。
%
%        SOS = [B1 A1
%               B2 A2
%                ...
%               BL AL]
%
% 線形断面は、右側にゼロを付加します。
%
% 例題：
% % ゲインは、leading first-order sectionに組み込まれます。 
% c = {{[0.0181 0.0181],[1.0000 -0.5095]},{[1 2 1],[1 -1.2505  0.5457]}};
% s = cell2sos(c)
%
% % ゲインは、leading zeroth-order (スカラ) sectionに組み込まれます。:
%     c = {{0.0181,1},{[1 1],[1.0000 -0.5095]},{[1 2 1],[1 -1.2505  0.5457]}};
%     [s,g] = cell2sos(c)
%
% 参考：SOS2CELL, TF2SOS, SOS2TF, ZP2SOS, SOS2ZP, SOS2SS, SS2SOS.



%   Copyright 1988-2002 The MathWorks, Inc.

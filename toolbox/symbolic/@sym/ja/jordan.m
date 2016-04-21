% JORDAN   Jordan 正準型
% JORDAN(A)は、行列 A の Jordan 正準型を計算します。行列は、厳密な意味で
% 既知でなければなりません。行列の要素は、整数、または、小さな整数比でな
% ければなりません。入力行列の中のわずかな誤差でも Jordan 正準型を完全に
% 変えてしまうことがあります。
% 
% [V, J] = JORDAN(A) は、V\A*V = J であるような相似変換 V も計算します。
% V の列は、一般化固有ベクトルです。
%
% 例題:
% 
%      A = sym(gallery(5));
%      [V,J] = jordan(A)
%
% 参考： EIG, POLY.



%   Copyright 1993-2002 The MathWorks, Inc.

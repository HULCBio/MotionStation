% JORDAN   Jordan正準型
% JORDAN(A) は、行列 A の Jordan 正準型を計算します。行列は、正確に既知
% でなければなりません。行列の要素は、整数または小さな整数比でなければな
% りません。入力行列の中のわずかな誤差でもJordan型を完全に変えてしまうこ
% とがあります。
%
% [V,J] = JORDAN(A) は、V\A*V = J であるような相似変換Vも計算します。V 
% の列は、一般化固有ベクトルです。
%
% 例題:
%      A = gallery(5);
%      [V,J] = jordan(A)
%
% 参考： EIG, POLY.



%   Copyright 1993-2002 The MathWorks, Inc. 

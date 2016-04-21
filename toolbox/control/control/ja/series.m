% SERIES   2つの LTI モデルを連続的に結合
%
%
%                                   +------+
%                            v2 --->|      |
%                   +------+        | SYS2 |-----> y2
%                   |      |------->|      |
%          u1 ----->|      |y1   u2 +------+
%                   | SYS1 |
%                   |      |---> z1
%                   +------+
%
% SYS = SERIES(SYS1,SYS2,OUTPUTS1,INPUTS2) は、OUTPUTS1 で指定されたSYS1 の
% 出力を INPUT2 で指定された SYS2 の入力に接続して、2つの LTIモデル SYS1 と
% SYS2 を接続します。ベクトル OUTPUTS1 と INPUTS2 は、SYS1 と SYS2 の出力と
% 入力の関係のインデックスを含みます。結果の LTIモデル SYS は u1 から y2 へ
% 割り当てられます。
%
% OUTPUTS1 と INPUTS2 が省略された場合、SERIES は SYS1 と SYS2 を縦に接続し、
% つぎのような出力になります。 
%   SYS = SYS2 * SYS1
%
% SYS1 と SYS2 が LTI モデルの配列の場合、SERIES は同じサイズの LTI 配列
% SYS を出力し、つぎのようになります。 
%   SYS(:,:,k) = SERIES(SYS1(:,:,k),SYS2(:,:,k),OUTPUTS1,INPUTS2)
%
% 参考 : APPEND, PARALLEL, FEEDBACK, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.

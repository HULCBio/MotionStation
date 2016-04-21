% MINDELAY   遅れの全体数の最小化
%
% SYS.LTI = MINDELAY(SYS.LTI) は、つぎのような I/O の遅れをもつSSモデル
% の遅れの総数を最小化します。
%  * I/O の遅れの行列の要素の和を最小化するために、I/O の遅れを入力と
%    出力の遅れにマッピングします。
%  * 遅れのチャンネル数を最小化するために、入力対出力の遅れを平衡化
%    します。
%
% SYS.LTI = MINDELAY(SYS.LTI,'ALLDELAY') は、遅れをもつすべてのモデルに
% 同じ遅れを適用します。
%
% TF/SS, ZPK/SS, SS/C2D, SS/D2C, +, *, []で利用されています。


%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2002 The MathWorks, Inc. 

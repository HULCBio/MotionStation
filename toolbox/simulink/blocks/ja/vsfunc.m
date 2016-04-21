% VSFUNC   可変ステップS-functionの例
%
% この S-functionは、Simulinkの可変ステップブロックの作成方法を説明する例で
% す。このブロックは、1番目の入力を2番目の入力が指定する時間量だけ遅らせる可
% 変ステップ遅れを実現します。
%
%  dt      = u(2)
%  y(t+dt) = u(t)
%
% 参考 : SFUNTMPL, CSFUNC, DSFUNC.


% Copyright 1990-2002 The MathWorks, Inc.

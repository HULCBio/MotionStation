% function [sh,su,hsvu]=hankmr(sys,sig,k,opt)
%
% 次数nの状態空間SYSTEM行列SYSにおいて、次数Kの最適Hankelノルム近似を行
% います。入力SYSTEM行列SYSは、Hankel特異値SIGをもつ平衡化実現でなければ
% なりません(すなわち、SYSとSIGは、SYSBALの出力でなければなりません)。
% OPTは、省略されるか、またはつぎのように設定することもできます。
%
%  - 'a'に設定すると、非因果性の項で終了します。非因果性の項は、SHに組み
%    込まれ、SU = 0になります。
%  - 'd'に設定すると、H∞誤差範囲で無視されたHankel特異値SIG(i)の和を満
%    たすD-項を計算します。すなわち、SH+SUは、常にK個の安定な極をもつSYS
%    への最適H∞ノルム近似です。
%
% OPT = 'a'の場合、非因果性の項は、SHに組み込まれ、SU = 0になります。他
% の場合、SUは非因果性の項を含み、SHはk次の因果的システムになります。'd'
% オプションを使うと、SUのHankel特異値はHSVUに出力されます。
%
% 参考: SFRWTBAL, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL,SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

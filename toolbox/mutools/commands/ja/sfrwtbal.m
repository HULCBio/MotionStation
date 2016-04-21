% function [sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%
% MINV(WT1~)*SYS*MINV(wt2~)の安定部を計算し、SYS1はこの平衡化実現で、
% Hankel特異値SYS1をもちます。WT1とWT2は、SYSと同じ次元の安定な最小位
% 相、正方行列でなければなりません。WT2のデフォルト値は単位行列で、SYS
% は安定でなければなりません。
%
% SYS1(k)は、誤差MINV(WT1~)*(SYS-SYSHAT)*MINV(WT2~)の達成可能なH∞ノルム
% の下界です。ここで、SYSHATは次数Kで安定です。ルーチンは、つぎのような
% SYSHATを得るために、SFRWTBLDと共に使われます。
%
%   >>[sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%   >>sys1hat = strunc(sys1,k);
% または、
%   >>sys1hat = hankmr(sys1,sig1,k);
%   >>syshat = sfrwtbld(sys1hat,wt1,wt2);
%
% 結果の誤差は、周波数応答の計算を直接使って評価されます。
%
% 参考: HANKMR, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL, SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

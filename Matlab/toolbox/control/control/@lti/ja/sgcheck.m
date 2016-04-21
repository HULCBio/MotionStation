% SGCHECK   様々なLTIの操作において、予期しないクラッシュを避けるために
%           静的ゲインのサンプル時間を調節
%
% [L1,L2] = SGCHECK(L1,L2,SFLAGS) は、LTIモデル SYS1 と SYS2 のサンプル
% 時間 L1.Ts と L2.Ts を、つぎのフラグ SFLAGS に基づいて調節します。
%
%    SFLAGS(1) = 1  ---> SYS1 が静的ゲイン
%    SFLAGS(2) = 1  ---> SYS2 が静的ゲイン
%
% L1 と L2 は、SYS1 と SYS2 の親 LTI です。
%
% 低水準ユーティリティ


%       Author(s):  P. Gahinet, 5-23-96
%       Copyright 1986-2002 The MathWorks, Inc. 

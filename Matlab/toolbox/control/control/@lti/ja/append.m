% APPEND   APPEND 操作での LTI プロパティを管理
%
% SYS.LTI = APPEND(SYS1.LTI,SYS2.LTI,SFLAGS) は、つぎのシステムのLTIプロ
% パティを設定します。
% 
%   SYS = APPEND(SYS1,SYS2)
%
% 2要素のベクトル SFLAGS は、静的ゲインのフラグです。
%   * SFLAGS(1) = 1 --> SYS1 が静的ゲイン
%   * SFLAGS(2) = 1 --> SYS2 が静的ゲイン


%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 

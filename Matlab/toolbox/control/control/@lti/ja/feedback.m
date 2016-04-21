% FEEDBACK   FEEDBACK の操作に対するLTIプロパティを管理
%
% SYS.LTI = FEEDBACK(SYS1.LTI,SYS2.LTI,SFLAGS) は、つぎのシステムの LTI 
% プロパティを設定します。
% 
%          SYS = FEEDBACK(SYS1,SYS2)
%
% 2要素のベクトル SFLAGS は、静的ゲインについてのフラグです。
%   * SFLAGS(1) = 1 --> SYS1 は、静的ゲインです。
%   * SFLAGS(2) = 1 --> SYS2 は、静的ゲインです。


%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 

% SLPROFILE_HILITE_SYSTEM   プロファイルされたSimulinkモデル内の
%                           ブロックを検索
%
% SLPROFILE_HILITE_SYSTEM('path/block') は、指定したブロックに対応した 
% Simulinkウィンドウを開きます。モデルが、指定された場合は、モデルが
% 開きます。
%
% SLPROFILE_HILITE_SYSTEM('encoded-path','path/block') は、まず、
% 'path/block' を処理する前に、つぎのキャラクタ列を変換します。
%     キャラクタ列  変換された値
%        --------  ---------------
%        '\\'      '\'
%        '\s'      ' '
%        '\t'      TAB
%        '\n'      new-line
%        '\T'      '''' (シングルコーテション)
%        '\Q'      '"'  (ダブルコーテション)
%
% 'encoded-path' の取り扱いが、Simulink Profiler で使用されます。


%   Copyright 1990-2002 The MathWorks, Inc.

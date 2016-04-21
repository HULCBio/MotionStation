% SAVE_SYSTEM   Simulinkシステムの保存
%
% SAVE_SYSTEM は、カレントの最上位システムをそのカレントの名前のファイルに保
% 存します。
%
% SAVE_SYSTEM('SYS') は、指定した最上位システムをそのカレントの名前のファイ
% ルに保存します。システムは、既に開かれていなければなりません。
%
% SAVE_SYSTEM('SYS','NEWNAME') は、指定した最上位システムを指定した新しい名
% 前のファイルに保存します。システムは、既に開かれていなければなりません。
%
% SAVE_SYSTEM('SYS','NEWNAME','BreakLinks') は、指定した最上位システムを指定
% した新しい名前のファイルに保存します。全てのブロックライブラリリンクは、新
% しいファイルでは解除されます。システムは、既に開かれていなければなりません。
%
% SAVE_SYSTEM('SYS','NEWNAME','LINKACTION', 'VERSION') は、指定した最上位シ
% ステムを指定したNEWNAMEという名前の旧バージョンに保存します。LINKACTIONは、
% '' と'BreakLinks'のいずれかです。VERSIONは、'R13SP1', 'R13', 'R12P1', '
% R12'のいずれかです。
%
% 例題:
%
% save_system
%
% は、カレントのシステムを保存します。
%
% save_system('vdp')
%
% は、vdpシステムを保存します。
%
% save_system('vdp','myvdp')
%
% は、vdpシステムを'myvdp'という名前のファイルに保存します。
%
% save_system('vdp','myvdp','BreakLinks')
%
% は、vdpシステムを'myvdp'という名前のファイルに保存し、ブロックライブラ
% リのリンクを解除します。
%
% save_system('vdp', 'myvdp', '', 'R13SP1')
%
% は、'vdp'システムを'myvdp'という名前のSimulinkのR13(SP1)バージョンに保存し
% ます。ブロックライブラリへのリンクは解除しません。
%
% 参考 : OPEN_SYSTEM, CLOSE_SYSTEM, NEW_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.

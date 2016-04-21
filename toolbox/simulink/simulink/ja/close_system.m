% CLOSE_SYSTEM   Simulinkシステムウィンドウ、または、ブロックダイアログ ボッ
% クスを閉じる
%
% CLOSE_SYSTEM は、カレントのシステム、または、サブシステムウィンドウを閉じま
% す。閉じようとするシステムが変更された場合、CLOSE_SYSTEM はエラーになります。
%
% CLOSE_SYSTEM('SYS') は、指定したシステム、または、サブシステムウィンドウを閉
% じます。
%
% CLOSE_SYSTEM('SYS',SAVEFLAG) は、SAVEFLAG が1である場合、指定した最上位シス
% テムをカレントの名前でファイルに保存し、システムを閉じてメモリから除去しま
% す。SAVEFLAG が0の場合は、このコマンドはシステムを保存せずに閉じます。
%
% CLOSE_SYSTEM('SYS','NEWNAME') は、指定した最上位システムを指定した新しい名
% 前でファイルに保存してから、システムを閉じます。
%
% CLOSE_SYSTEM('BLK') は、'BLK'がブロックの絶対パス名であるとき、指定したブロッ
% クに関連するダイアログボックスを閉じます。
%
% 例題:
%
% close_system
%
% は、カレントのシステムを閉じます。
%
% close_system('vdp')
%
% は、vdpシステムを閉じます。
%
% close_system('engine',1)
%
% は、engineシステムをそのカレントの名前で保存してから、それを閉じます。
%
% close_system('vdp','myvdp')
%
% は、vdpシステムを'myvdp'という名前で保存してから、それを閉じます。
%
% close_system('engine/Combustion/Unit Delay')
%
% は、engineシステムのCombustionサブシステムにおけるUnit Delayブロックの
% ダイアログボックスを閉じます。
%
% 参考 : OPEN_SYSTEM, SAVE_SYSTEM, NEW_SYSTEM, BDCLOSE.


% Copyright 1990-2002 The MathWorks, Inc.

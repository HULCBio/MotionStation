% NEW_SYSTEM   新規の空のSimulinkシステムを作成
%
% NEW_SYSTEM('SYS') は、指定した名前で新規の空のシステムを作成します。
%
% オプションの第二引数を使って、システムタイプを指定します。
% NEW_SYSTEM('SYS','Library') は、新規の空のライブラリを作成します。
% NEW_SYSTEM('SYS','Model') は、新規の空のシステムを作成します。
%
% オプションの第三引数を使って、その内容が新規モデルにコピーされるサブシステ
% ムを指定します。この第三引数は、第二引数が'Model'であるときにのみ利用可能で
% す。NEW_SYSTEM('SYS','MODEL','FULL_PATH_TO_SUBSYSTEM')は、サブシステム内に
% ブロックをもつ新規モデルを作成します。
%
% NEW_SYSTEM は、システムウィンドウまたはライブラリウィンドウを開きません。
%
% 例題:
%
% new_system('mysys')
%
% は、'mysys'という名前の新規のシステムを作成しますが、開きません。
%
% new_system('mysys','Library')
%
% は、'mysys'という名前の新規のライブラリを作成しますが、開きません。
%
% load_system('f14')
% new_system('mysys','Model','f14/Controller')
%
% は、'mysys'という名前の新規のライブラリを作成しますが、開きません。
% これは、'f14'デモモデルの'Controller'という名前のサブシステムに同じブロッ
% クをもちます。
%
% 参考 : OPEN_SYSTEM, CLOSE_SYSTEM, SAVE_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.

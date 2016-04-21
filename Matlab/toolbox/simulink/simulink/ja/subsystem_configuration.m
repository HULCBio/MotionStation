% SUBSYSTEM_CONFIGURATION   configurable subsystemの設定と管理
%
% この関数は、SimulinkのConfigurable Subsystemブロックの振るまいを管理
% するために利用します。これは、5つの(文字列)引数のうちの1つによって呼び
% 出すことができます。
%
% 新規subsystem_configuration
% =========================== 
% カレントブロック(gcb)は、ライブラリ内のすべてのブロックを表現する
% "shell"として設計されています。 
% GUIは、ユーザにライブラリ名を尋ねます。これは、入力引数を指定しないで、
% 関数を呼び出した場合のデフォルトの挙動です。
%
% subsystem_configurationの構築
% ============================= 
% shellに対するマスクは、この段階でブロック名とパラメータが設定されます。
% マスクの下にある参照ブロックが作成され、ライブラリに含まれるすべての
% 入出力の superset を表す inport と outport に接続されます。ブロックの
% デフォルトの識別子は、リストの一番最初です。通常、GUIのfigureウィンドウ
% は、この段階で削除されます。第二引数'apply'が用いられる場合は、GUIは
% 開いたままです。すなわち、subsystem_configuration('establish','apply')
% です。
%
% subsystem_configurationの再構築
% ===============================
% 新しいライブラリ名がマスク変数LibraryNameに入力されたので、現在の内容
% は破棄され、新たなconfigurationが作成されます。第二引数を用いて、適用
% するconfiguration ブロックを示します。すなわち、
% subsystem_configuration('reestablish', ConfigBlock)で、デフォルトは
% gcb です。  
%
% subsystem_configurationの更新
% ============================== 
% これは、ユーザがconfigurationを変更するときに呼び出されます。
% 基になる参照ブロックの識別子が変更され、必要な入力と出力の再接続が
% 行われます。第二引数を用いて、適用するconfigurationブロックを示します
% (デフォルトはgcbです)。すなわち、
% subsystem_configuration('update', ConfigBlock) です。
%
% 最後の2つの関数は、'LibraryName' または 'Choice' の set_param によって、
% コマンドラインからもアクセスできます。つまり、ライブラリを変更
% (reestablish)するには、
%       set_param(configblk, 'LibraryName', 'newLib')
% または、カレントのブロックの選択を変更(update)するには、
%       set_param(configblk, 'Choice', 'newchoice')
% です。
%
% subsystem_configurationのコピー
% ===============================
% この関数は、ユーザがconfigurable subsystemブロックをコピーするときに
% 呼び出されます。これは、親ブロックとのリンクを解除し、Simulinkライブラリ
% ブラウザに表示するために、ブロックに含まれているEmpty Subsystemを削除
% します。


%   Copyright 1990-2002 The MathWorks, Inc.

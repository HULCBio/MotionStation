% SLBLOCKS   特定のツールボックスまたはブロックセットに対するブロック ライブ
% ラリの定義
%
% SLBLOCKS は、SimulinkのBlocksetに関する情報を出力します。
% 出力される情報は、つぎのフィールドをもつBlocksetStructの形式です。
%
%  Name                SimulinkブロックライブラリのBlocksets & Toolboxesサ
% ブ                    システムのBlockset名 OpenFcn      Blocksets &
% Toolboxesサブシステムでブロックをダブル          クリックしたときに呼び出
% すMATLAB表現(関数) MaskDisplay  Blocksets & Toolboxサブシステム内のブロッ
% クで用いるMask Displayコマンドを指定するオプションのフィールド
%  Browser      以下に記述するSimulinkライブラリブラウザ構造体の配列
%
% Simulinkライブラリブラウザは、Blockset内に表示するライブラリ、また、それらに
% 与えている名前を知っている必要があります。この情報を与えるためには、
% Simulink Library Blowserで各ライブラリに対して1配列要素をもつBlowserデー
% タ構造体の配列を定義してください。各配列要素は、フィールドを2つもちます。
%
%  Library      ライブラリブラウザに含ませるライブラリのファイル名 (mdl-ファ
% イル) Name         ライブラリブラウザウィンドウ内のライブラリに対して表示
% される名前。 Name         ライブラリブラウザウィンドウ内のライブラリに対し
% て表示される名前。Nameは、mdl-ファイル名と同じである必要はありません。
%
% 例:
%
% %
% % Simulinkブロックライブラリに対して、BlocksetStructを定義
% % simulink_extrasのみをBlocksets & Toolboxesに表示
% %
% blkStruct.Name        = ['Simulink' sprintf('\n' Extras];
% blkStruct.OpenFcn     = simulink_extras;
% blkStruct.MaskDisplay = disp('Simulink\nExtras');
%
% %
% % simulinkとsimulink_extrasをLibrary Browserに表示
% %
% blkStruct.Browser(1).Library = 'simulink';
% blkStruct.Browser(1).Name    = 'Simulink';
% blkStruct.Browser(2).Library = 'simulink_extras';
% blkStruct.Browser(2).Name    = 'Simulink Extras';
%
% 参考 : FINDBLIB, LIBBROWSE.


% Copyright 1990-2002 The MathWorks, Inc.

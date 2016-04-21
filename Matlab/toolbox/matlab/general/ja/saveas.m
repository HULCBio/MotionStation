% SAVEAS   Figureまたはモデルを希望する出力書式で保存
% 
% SAVEAS(H,'FILENAME')
% ハンドル H で識別されるFigureまたはモデルを、FILENAME というファイルに保
% 存します。ファイルの書式は、FILENAMEの拡張子によって決定されます。
%
% SAVEAS(H,'FILENAME','FORMAT')
% ハンドル H で識別されるFigureまたはモデルを、FILENAME というファイル
% に FORMAT で指定した書式で保存します。FORMAT は、FILENAME の拡
% 張子と同じ値でも構いません。FILENAME の拡張子は、FORMAT と同じで
% なくても構いません。FORMAT を使って、FILENAME の拡張子を変更します。
%
% FORMATで利用できるオプション:
%
%   'fig'  - FigureをバイナリFIG-ファイルとして保存します。OPENを使って
%            リロードします。
%   'm'    - FigureとバイナリFIG-ファイルを保存し、リロード用に呼び出し
%            可能なM-ファイルを生成します。
%   'mfig' - Mとして保存します。
%   'mmat' - パラメータと値の組の引数をもった一連の作成コマンドを含んだ
%            ものとしてfigureを呼び出し可能なM-ファイルに保存します。
%            大きなデータは、MAT-ファイルに保存されます。
% 	     注意: MMAT は、新しいグラフィックス機能のうちサポートしない
%		   ものがあります。このフォーマットは、コードを調査する
%                  ためにご利用ください。Fig-ファイルはすべての機能を
%                  サポートし、読み込みが高速です。
%
% PRINT で利用できるデバイスもオプションとして利用できます。
%
% 例題:
%
% 現在のfigureを MATLAB fig ファイルとして書き出します。
%
%     saveas(gcf、'output'、'fig')
%
% 現在のfigureをWindowsビットマップファイルとして書き出します。
%
%     saveas(gcf、'output'、'bmp')
%
% 参考： LOAD, SAVE, OPEN, PRINT


%   Copyright 1984-2002 The MathWorks, Inc.

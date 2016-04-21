% RTWMAKECFG   RTW makeファイルにインクルードとソースディレクトリを追加
%
% makeInfo=RTWMAKECFG は、以下のフィールドを含む構造体配列を出力します。:
%
%   makeInfo.includePath - 付加的なインクルードディレクトリを含むセル配列。
%                          これらのディレクトリは、rtwの生成されたmake
%                          ファイルのインクルード命令として展開されます。
%     
%   makeInfo.sourcePath  - 付加的なソースディレクトリを含むセル配列。
%                          これらのディレクトリは、rtwの生成されたmake
%                          ファイルのルールとして展開されます。
%
%   makeInfo.library     - 付加的なruntimeライブラリ名とモデルオブジェクト
%                          を含む構造体。この情報は、rtwの生成されたmake
%                          ファイルのルールとして展開されます。


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/07/22 21:07:08 $


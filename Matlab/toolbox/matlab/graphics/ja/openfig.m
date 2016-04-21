% OPENFIG  新しくコピー、または保存された figure の既存のコピーを開く
%
% OPENFIG('NAME.FIG', 'new') は、.fig ファイル NAME.FIG に含まれている
% figure を開き、スクリーン上を完全に含ませます。拡張子 .fig は
% オプションで指定できます。絶対パスは、.fig ファイルがMATLABパス上に
% 存在する限りオプションで指定できます。
%
% .fig ファイルが、非可視状態のfigureを含んでいる場合、OPENFIG はその
% ハンドル番号を出力し、非可視状態のままにします。ユーザは、適切に
% figure を可視化する必要があります。
%
% OPENFIG('NAME.FIG') は、OPENFIG('NAME.FIG','new') と等価です。
%
% OPENFIG('NAME.FIG', 'reuse') は、コピーが現在figureが開いていない場合
% のみ、.fig ファイルに含まれる figure を開きます。そうでない場合は、
% 既存のコピーが、スクリーン上にあるようにします。既存のコピーが可視
% 状態の場合は、すべての他のウィンドウの上に位置させます。
%
% OPENFIG(...,'invisible') は、figureを見えないようにして上記のように
% 開きます。
%
% OPENFIG(...,'visible') は、figureを見えるようにして、上記のように
% 開きます。
%
% F = OPENFIG(...) は、figureのハンドルを出力します。
%
% 参考：OPEN, MOVEGUI, GUIDE, GUIHANDLES, SAVE, SAVEAS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/28 01:56:01 $

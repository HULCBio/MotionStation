% XPCBOOTDISK は、xPC Target ブートフロッピディスクを作成します。
% 
% XPCBOOTDISK は、UPDATEXPCENV を実行して更新される前のカレントの xPC 環境
% の xPC Target ブートフロッピーを作成します。xPC Target ブートフロッピー
% の作成は、正しいブート可能なカーネルイメージをディスク上に書き込むことで
% す。ユーザは、フロッピードライブの中に空のフォーマットされたディスクを挿
% 入する必要があります。
% 
% 注意：
% 存在しているファイルは、すべて XPCBOOTDISK の実行で、消去されます。挿入
% したフロッピーが、同じ環境設定の xPC Target ブートフロッピーである場合、
% XPCBOOTDISK は、フロッピーに新しいブートイメージを書き込むことは行ないま
% せん。最後に、XPCBOOTDISK は、作成プロセスのまとめを表示します。
% 
% 参考： SETXPCENV, GETXPCENV, UPDATEXPCENV, XPCBOOTDISK, XPCSETUP.

%   Copyright 1994-2002 The MathWorks, Inc.

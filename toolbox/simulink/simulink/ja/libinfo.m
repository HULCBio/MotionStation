% LIBINFO   ライブラリ情報
%
% LibData = LIBINFO(Sys) は、Sys とその下層のすべてのシステムに関するライブ
% ラリ情報を出力します。LibData は、つぎのもので構成されるデータ構造体です。
%  LibData(n).Block          =  'ブロック名'、または、ライブラリリンク をもつ
% ブロックのハンドル LibData(n).Library        =  ライブラリMDLファイル名
% LibData(n).ReferenceBlock =  ライブラリ内のリンクされたブロックの 絶対パ
% ス名 LibData(n).LinkStatus     =  'resolved'、または、'unresolved'
%
% LibData の各要素は、ライブラリリンクを含むSys内のブロックです。
%
% LIBINFO は、find_system と同じタイプの呼び出し形式に基づいて、上記以外の入
% 力引数をもちます。たとえば、つぎのように使用します。
%
%  LibData = libinfo(Sys,'FollowLinks','off')
%
% 参考 : FIND_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.

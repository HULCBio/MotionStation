% PNAMES は、パブリックプロパティ名と設定値を出力します。
%
% [PROPS,ASGNVALS] = PNAMES(DAT,'true') は、オブジェクト DAT のパブリック
% プロパティ(文字列のセル配列)の名前 PROPS とそれに使用している値(文字の
% セル配列) ASGNVALS の一覧を出力します。PROPS は、大文字、小文字の区別を
% もつプロパティ名を含んでいます。
%
% [PROPS,ASGNVALS] = PNAMES(SYS,'lower')  は、小文字で表したプロパティ名
% を出力します。これは、GET や SET の中で、名前の検索をする場合にスピード
% アップになります。
%
% 参考：  GET, SET.



%       Copyright 1986-2001 The MathWorks, Inc.

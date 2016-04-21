% STRREP   文字列の置換
% 
% S = STRREP(S1,S2,S3) は、文字列 S1 内の文字列 S2 を、すべて文字列 S3 で
% 置き換えます。新たな文字列が出力されます。
%
% STRREP(S1,S2,S3) は、S1、S2、S3 のいずれかが文字列のセル配列のとき、
% 対応する入力要素を使って、STRREP を実行して得られる、S1、S2、S3 と同じ
% サイズのセル配列を出力します。入力は、すべて同じサイズ(またはスカラの
% セル)でなければなりません。文字列は、正しい行数をもつキャラクタ配列
% でも構いません。
%
% 例題:
% 
%   s1 = 'This is a good example';
%   strrep(s1,'good','great') は、'This is a great example'を出力します。
%   strrep(s1,'bad','great') は、'This is a good example'を出力します。
%   strrep(s1,'','great') は、'This is a good example'を出力します。
%
% 参考：STRFIND.


%   M version contributor: Rick Spada  11-23-92
%   Copyright 1984-2002 The MathWorks, Inc. 

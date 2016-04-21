% PMATCH は、大文字、小文字の区別をしないで、文字列の比較を行います。
%
% [INDICES,STATUS] = PMATCH(STRCELL,STR) は、基準の名前を含むセル配列 
% STRCELL と比較されるセル配列 STR を必要とします。これは、STRCELL(IND-
% EX) が、STR と一致するすべての文字列であることを示すインデックスベクト
% ルを出力します。
%   
% STATUS は、一つのセル全体が完全に一致した場合空行列を出力します。他の
% 場合は、"standard"と云うエラーメッセージを出力します。
%
% 注意：
% PMATCH iは、LTI オブジェクト用に最適化されています。比較の目的では、
% STR の最初の2キャラクタのみを使ってください。

%   Copyright 1986-2001 The MathWorks, Inc.

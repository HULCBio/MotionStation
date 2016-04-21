% STRMATCH   適合する文字列の検出
% 
% I = STRMATCH(STR,STRS) は、文字列 STRS のキャラクタ配列またはセル配列
% の行を検索し、文字列 STR から始まる文字列を見つけ、その適合した行の
% インデックスを出力します。
% STRMATCH は、STRS がキャラクタ配列のとき、最も高速です。
%
% I = STRMATCH(STR,STRS,'exact') は、STRS 内で STR と完全に一致している
% 文字列のインデックスのみを出力します。
%
% 例題
% 
% i = strmatch('max',strvcat('max','minimax','maximum'))は、1行目と3行目が
% 'max' から始まるため、i = [1; 3] を出力します。
% 
% i = strmatch('max',strvcat('max','minimax','maximum'),'exact')は、
% 1行目のみが 'max' と正確に一致するため、i = 1 を出力します。
%   
% 参考：STRFIND, STRVCAT, STRCMP, STRNCMP.


%   Mark W. Reichelt, 8-29-94
%   Copyright 1984-2002 The MathWorks, Inc. 

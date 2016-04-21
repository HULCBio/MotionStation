% FINDSTR   一方の文字列内にある文字列の検出
%  
% K = FINDSTR(S1,S2) は、2つの文字列内の長い文字列内で、設定した文字
% または文字列が表される位置のインデックスを出力します。
%
% FINDSTR は、2つの引数内で対称です。つまり、S1 または S2 は、長い文字列
% 内でサーチされる短いパターンである場合があります。この挙動を望まない
% 場合は、代わりに STRFIND を利用してください。
%
% 例題
% 
%     s = 'How much wood would a woodchuck chuck?';
%     findstr(s,'a') は、21を出力します。
%     findstr(s,'wood') は、[10 23] を出力します。
%     findstr(s,'Wood') は、[] を出力します。
%     findstr(s,' ') は、[4 9 14 20 22 32] を出力します。
%
% 参考：STRFIND, STRCMP, STRNCMP, STRMATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:46 $
%   Built-in function.

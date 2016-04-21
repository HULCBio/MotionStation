% STRFIND   あるものの中の文字の検出
% 
% K = STRFIND(TEXT,PATTERN) は、文字列 TEXT の中で、文字 PATTERN が出現
% する最初のインデックスを出力します。
%
% STRFIND は、PATTERN が TEXT よりも長い場合は、常に [] を出力します。
% S2 の中に S1が、あるいは、S1 の中に S2 が含まれている場合の検出には、
% FINDSTR を使ってください。
%
% 例題：
%       s = 'How much wood would a woodchuck chuck?';
%       strfind(s,'a')    は、21を出力します。
%       strfind('a',s)    は、[] を出力します。
%       strfind(s,'wood') は、[10 23] を出力します。
%       strfind(s,'Wood') は、[] を出力します。
%       strfind(s,' ')    は、[4 9 14 20 22 32] を出力します。
%
% 参考：FINDSTR, STRFIND, STRCMP, STRNCMP, STRMATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:07:10 $
%   Built-in function.


% WEEKDAY   曜日の出力
% 
% [D,W] = WEEKDAY(T) は、シリアルな日付番号または日付の文字列である T で
% 与えられる数値と文字列の形式で、曜日を出力します。これは、短い英語の曜日
% を出力します。
%
% [D, W] = WEEKDAY(T, FORM) :
% [D, W] = WEEKDAY(T, LOCALE):
% [D, W] = WEEKDAY(T, FORM, LOCALE):
% form引数は、つぎのいずれかです。
%         short   --      省略形の曜日(デフォルト)
%         long    --      完全な曜日
% locale引数は、つぎのいずれかです。
%         local   --      local書式を利用
%         en_US   --      デフォルトのUS English書式を利用(デフォルト)
%   
% これらの引数は、両方共オプションで、日付番号の後の任意の順番でかまいません。
%
% 曜日は、English localesに対してつぎの値に割り当てられています。
%
%                1     Sun
%                2     Mon
%                3     Tue
%                4     Wed
%                5     Thu
%                6     Fri
%                7     Sat
%
%   他の言語localesに対しては、2番目の出力引数は、そのlocaleでの等価な曜日を
% 含みます。
%
% たとえば、[d,w] = weekday(728647) または [d,w] = weekday('19-Dec-1994')
% は、English localeに対してはd = 2 と w = Mon を出力します。
% 
% 参考：EOMDAY, DATENUM, DATEVEC.


%   Copyright 1984-2002 The MathWorks, Inc. 

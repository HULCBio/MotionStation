% ISPREF は、存在している優先順位を検索します。
%
% ISPREF('GROUP','PREF') は、GROUP や PREF により指定された設定が存在
% している場合は1を、その他の場合は0を出力します。
%
% ISPREF('GROUP') は、GROUP により指定された設定が存在する場合は1を、
% その他の場合は0を出力します。
%
% ISPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) は、設定名のセル配列と
% 同じ長さの論理配列、すなわち、各設定が存在する場合は1を、その他の場合は
% 0をもつ配列を出力します。
%
% 例題：
%      addpref('mytoolbox','version',1.0)
%      ispref('mytoolbox','version')
%
% 参考：ADDPREF, GETPREF, SETPREF, RMPREF.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $

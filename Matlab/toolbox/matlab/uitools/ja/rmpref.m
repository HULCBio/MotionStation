% RMPREF 設定の解除
%
% RMPREF('GROUP','PREF') は、GROUP や PREF で指定された設定を削除します。
% 存在しない設定を削除しようとすると、エラーになります。
%
% RMPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) は、セル配列の中に設定
% された個々の設定を削除します。存在しない設定を削除しようとすると、
% エラーになります。
%
% RMPREF('GROUP') は、指定した GROUP に関するすべての設定を削除します。
% 存在しない設定を削除しようとすると、エラーになります。
%
% 例題：
%      addpref('mytoolbox','version',1.0)
%      rmpref('mytoolbox')
%
% 参考：ADDPREF, GETPREF, SETPREF, ISPREF.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $

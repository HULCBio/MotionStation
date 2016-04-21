% ADDPREF   優先順位の追加
% 
% ADDPREF(GROUP,PREF,VAL) は、文字列 GROUP と PREF で指定された優先順位
% を作成し、その値を VAL に設定します。既に存在している優先順位を追加
% しようとすると、エラーになります。
%
% GROUP は、優先順位の関係したものをラベル付けします。ユーザは、有効な変数
% 名、および、'MathWorks_GUIDE_ApplicationPrefs'のように他と識別できる名
% 前を選択することができます。
%
% PREF は、そのグループの中で個々の優先順位を識別しますが、これは正しい
% 記述の変数名である必要があります。
%
% ADDPREF('GROUP',{'PREF1','PREF2',...'PREFn'},{VAL1,VAL2,...VALn}) は、
% 名前と対応する値のセル配列で指定した優先順位を作成します。
%
% 優先順位の値は、MATLABセッション中は変更されません。また、ストアして
% いる部分は、システムに依存します。
%
% 例題：
%      addpref('mytoolbox','version',1.0)
%
% 参考： GETPREF, SETPREF, RMPREF, ISPREF.


%   Copyright 1984-2002 The MathWorks, Inc.

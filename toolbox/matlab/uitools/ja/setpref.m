% SETPREF  プレファレンスの設定
%
% SETPREF('GROUP','PREF',VAL) は、GROUP と PREF で指定されたプレファレンス
% に 値 VAL を設定します。存在しないプレファレンスを設定しようとすると、
% プレファレンスが作成されます。
%
% GROUP は、関連するプレファレンスをまとめたものをラベル付けしたものです。
% それらには、MATLABの正しい変数名記法を使い、他と区別できるユニークな名前、
% たとえば、'MathWorks_GUIDE_ApplicationPrefs'を付けます。
%
% PREF は、そのグループの中の個々のプレファレンスの設定を識別し、正しい
% MATLABの変数記法を使います。
%
% SETPREF('GROUP',{'PREF1','PREF2',...'PREFn'},{VAL1,VAL2,...VALn}) は、
% セル配列の中の各プレファレンスを名前で指定し、それに対応する値を設定
% します。
%
% プレファレンス値は、固定されており、MATLABセッション間で保持されます。
% 保存場所は、システムに依存します。
%
% 例題:
%    addpref('mytoolbox','version',0.0)
%    setpref('mytoolbox','version',1.0)
%    getpref('mytoolbox','version')
%
% 参考　GETPREF, ADDPREF, RMPREF, ISPREF.



%   Copyright 1984-2002 The MathWorks, Inc.

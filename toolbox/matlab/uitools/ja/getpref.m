% GETPREF 優先順位の取得
%
% GETPREF('GROUP','PREF') は、GROUP と PREF で指定した優先順位の値を
% 出力します。存在しない優先順位を得ようとすると、エラーがでます。
%
% GROUP は、優先順位について関連するものをまとめてラベル付けしたもので
% す。これらを選択するには、MATLABの正しい変数名記法で、他と区別の付く
% 名前、たとえば、'MathWorks_GUIDE_ApplicationPrefs'を使ってください。
%
% PREF は、対象のグループの中の個々の優先順位を識別します。ここで、PREF 
% は正しい変数名でなければなりません。
%
% GETPREF('GROUP','PREF',DEFAULT) は、GROUP と PREF で指定した優先順位
% が存在する場合にカレントの値を出力します。その他の場合は、指定した
% デフォルト値をもつ優先順位を作成し、その値を戻します。
%
% GETPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) は、GROUP と優先順位の
% セル配列で指定した優先順位の値を含むセル配列を戻します。戻り値は、
% 入力セル配列と同じ大きさです。優先順位のいずれも存在しない場合、エラー
% になります。
%
% GETPREF('GROUP',{'PREF1',...'PREFn'},{DEFAULT1,...DEFAULTn}) は、GROUP 
% で指定した優先順位のカレント値をもつセル配列と優先順位の名前のセル配列
% を出力します。存在していない優先順位は、指定したデフォルト値と共に作成
% され、出力されます。
%
% GETPREF('GROUP') は、GROUP の中のすべての優先順位の名前と値を構造体
% として出力します。
%
% GETPREF は、すべてのグループと優先順位を構造体として出力します。
%
% 優先順位値は、MATLABセッション間で、固定値として取り扱われます。
% これらをストアする場所は、システムに依存します。
%
% 例題：
%      addpref('mytoolbox','version',1.0)
%      getpref('mytoolbox','version')
%
% 例題：
%      getpref('mytoolbox','version',1.0);
% 
% 参考：SETPREF, ADDPREF, RMPREF, ISPREF, UIGETPREF, UISETPREF


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $

% RPT_EVENT_NEWMODEL
% RPT_EVENT_NEWMODEL は、zslmethods/loopobjectにより、モデル内でループが
% 生じる度にコールされます。loopobjectメソッドは、親オブジェクトを作成す
% るRPT_EVENT_NEWMODELと名付けたすべてのメソッドをサーチします。その後、
% つぎのシンタックスを使って、メソッドを実行します。
%
%    ok=rpt_event_newmodel(helper_object,mdlStruct)
%
% ここで、 mdlStruct は、つぎのフィールドをもつ構造体です。
%       m.MdlName      カレントモデルの名前
%       m.SysLoopType  "カレント"システムでのループに関するルール
%       m.MdlCurrSys   "カレント"システムのリスト
%       m.isMask       マスクが存在するか否か
%       m.isLibrary    ライブラリリンクルール
%
% メソッドが適切に機能する場合、ok は、論理真(1)を出力します。
%
% 参考 ZSLMETHODS/LOOPOBJECT



% $Revision: 1.8 $ $Date: 2002/06/17 12:23:10 $ 
% Copyright 1994-2002 The MathWorks, Inc.

% newsys = dellmi(lmisys,lmid)
%
% LMISYSで記述された連立LMIから、ラベルがLMIDであるLMIを削除します。LMID
% は、NEWLMIを使って作成された初期システムの順序付けです。LMIの削除の過
% 程の表示を簡単にするために、LMIDをこのLMIが作成されたときにNEWLMIによ
% って出力された識別子に設定します。
%
% このLMIのみに現れる行列変数は、自動的に削除されます。
%
% 入力:
%   LMISYS         LMIシステムを記述する配列
%   LMID           (NEWLMIによって出力される)削除されるLMIの識別子
% 出力:
%   NEWSYS         LMIシステムの更新された記述
%
% 参考：    NEWLMI, DELMVAR.



% Copyright 1995-2002 The MathWorks, Inc. 

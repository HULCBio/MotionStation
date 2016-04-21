%function y = trsp(sys,input,tfinal,int,x0,texthan)
%
% SYSTEM行列の時間応答を計算します。
%   SYS     : SYSTEMまたはCONSTANT行列
%   INPUT   : VARYING入力ベクトルまたは定数
%   TFINAL  : 最終時間(オプション、デフォルト = 入力の最終時間)
%   INT     : 積分ステップ(オプション、デフォルトでは入力とSYSに基づき決
%             定されます。TRSPが選択する区間は、しばしば非常に小さく、計
%             算に時間を要する場合があるので、ユーザがこの引数を設定する
%             ことを推奨します)。
%   X0      : 初期状態(オプション、デフォルト = 0)。
% 　TEXTHAN : 更新情報用のuicontrolテキストオブジェクトのハンドル番号。
%             これは、SIMGUIでのみ使われます。
%
% INTが0に設定されると、TRSPは、適切な積分ステップを使います。出力は、選
% 択された積分ステップサイズで生成されます。出力点の数を減らすためには、
% 関数VDCMATEを使います。
%
% 参考: DTRSP, SAMHLD, SIMGUI, TUSTIN, VINTERP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

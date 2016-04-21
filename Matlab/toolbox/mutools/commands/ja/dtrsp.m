%function y = dtrsp(sys,input,T,tfinal,x0,texthan)
%
% 離散システムの時間応答を計算します。
%	SYS    : パックされた形式のA,B,C,D SYSTEM行列またはCONSTANT行列
%	INPUT  : VARYING形式の入力ベクトルまたはCONSTANT行列
%	T      : サンプリング時間
%	TFINAL : 最終時刻の値(オプション、デフォルト = 入力の最終時刻)
%	X0     : 初期状態(オプション、デフォルト = 0)
%       TEXTHAN: 更新情報に対するuicontrolテキストオブジェクトのハンドル
%                番号。これは、SIMGUIでのみ使われます。
%
% 参考: TRSP, SAMHLD, SIMGUI, TUSTIN, VINTERP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

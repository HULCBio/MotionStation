%function [v,y,u] = sdtrsp(sys,K,input,h,tfinal,int,x0,z0,texthan)
%
% サンプル値データフィードバック相互結合の時間応答を計算します。これは、
% 機能的に、つぎのステートメントと等価です。
%
%  v = starp(sys,K) * input
%
% ここで、SYSは連続時間プラントで、Kは離散時間コントローラです。Yはコン
% トローラへの入力で、Uはコントローラ出力です。他の入力は、つぎのように
% なります。
%
%   SYS    : 連続系プラント(SYSTEMまたはCONSTANT)
%   K      : 離散時間コントローラ(SYSTEMまたはCONSTANT)
%   INPUT  : VARYING入力ベクトルまたは定数
%   H      : 離散系コントローラのサンプリング周期
%   TFINA L: 最終時間の値(オプション、デフォルト = 入力の最終時間)
%   INT    : 積分ステップ(オプション、デフォルトでは入力とSYSに基づき決
%            定されます。SDTRSPが選択する区間は、しばしば非常に小さく、
%            計算に時間を要する場合があるので、ユーザがこの引数を設定す
%            ることを推奨します)。
%	     プログラムは、1以上の整数nについて、int = h/nとします。
%   X0     : 連続系プラントの初期状態(オプション、デフォルト = 0)
%   Z0     : 離散系コントローラの初期状態(オプション、デフォルト = 0)
%   TEXTHAN: 更新情報用のuicontrolテキストオブジェクトのハンドル番号。こ
%            れは、SIMGUIでのみ使われます。
%
% INTが0に設定されると、SDTRSPは、適切な積分ステップを使います。出力は、
% 選択された積分ステップサイズで生成されます。出力点の数を減らすためには、
% 関数VDCMATEを使います。
%
% 参考: DHFNORM, DHFSYN, SDHFNORM, SDHFSYN, TRSP, DTRSP,
%       SAMHLD, SIMGUI, TUSTIN, VINTERP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

% ACTXCONTROL   ActiveXコントロールの作成
% 
%  H = ACTXCONTROL('PROGID', POSITION, PARENT, ...
%           ['CALLBACK' | {EVENT1 E_HANDLER1; EVENT2 E_HANDLER2; ...}])
% は、ActiveXコントロールを定義します。
%
% Hは、コントロールのデフォルトインタフェースのハンドル番号です。
%
% PROGIDは、ActiveXオブジェクトのプログラムIDで、ACTXCONTROLの入力引数
% としてのみ用いられます。
%
% POSITIONは、場所を表すベクトルで、特に指定しない場合には、デフォルト値
% [20 20 60 60]となります。
%
% PARENTは、Handle Graphics figureウィンドウやSimulinkシステムウィンドウ
% に描画するためのハンドルです。PARENTのデフォルト値は、GCFです。
% 
% CALLBACKは、使用するイベントハンドルを与えます。CALLBACKのデフォルト
% 値は、''です。
% 
% EVENTx E_HANDLERxは、一組のイベント(名前、または、番号のどちらかで指
% 定する)と、そのイベントに対するハンドルです。
% 
%  例題: 
%
%      h=actxcontrol('mwsamp.mwsampctrl.2')
%   
% 参考 : ACTXSERVER


% Copyright 1984-2002 The MathWorks, Inc.

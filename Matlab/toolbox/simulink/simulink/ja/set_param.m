% SET_PARAM   Simulinkシステムパラメータとブロックパラメータを設定
%
% SET_PARAM('OBJ','PARAMETER1',VALUE1,'PARAMETER2',VALUE2,...) の 'OBJ'は、
% システム、または、ブロックのパス名であり、指定したパラメータを指定した値に設
% 定します。パラメータ名については、大文字と小文字の区別はありません。値の文字
% 列については、大文字と小文字は区別されます。ダイアログボックスの項目に対応
% するパラメータは、すべて文字列の値をもっています。
%
% 例題:
%
% set_param('vdp','Solver','ode15s','StopTime','3000')
%
% は、vdpシステムの Solver および StopTime パラメータを設定します。
%
% set_param('vdp/Mu','Gain','1000')
%
% は、vdpシステム内のブロック Mu の Gain を1000(スティッフ)に設定します。
%
% set_param('vdp/Fcn','Position',[50 100 110 120])
%
% は、vdpシステム内の Fcn ブロックの Position を設定します。
%
% set_param('mymodel/Zero-Pole','Zeros','[2 4]','Poles','[1 2 3]')
%
% は、mymodelシステム内の Zero-Pole ブロックに対する Zeros および Poles
% パラメータを設定します。
%
% set_param('mymodel/Compute','OpenFcn','my_open_fcn')
%
% は、mymodelシステム内の Compute ブロックの OpenFcn コールバックパラ メータを
% 設定します。関数 'my_open_fcn' は、ユーザが Compute ブロックをダブルクリック
% すると実行されます。　
%
% 参考 : GET_PARAM, FIND_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.

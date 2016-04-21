% DELETE_PARAM   Simulink システムからパラメータを削除
%
% DELETE_PARAM('SYS','PARAMETER1', 'PARAMETER2', ...) は、リストされたパラメー
% タがコマンド ADD_PARAM を利用してシステムに追加されたものであれば、それら
% のパラメータをシステムから削除します。 なお、'SYS' はシステムを表します。
% Simulink パラメータを削除しようと試みるとき、エラーが起こります。
%
% 例題:
%
% add_param('vdp','Param1','Value1','Param2','Value2')
% delete_param('vdp','Param1')
%
% は、vdp システムにパラメータ Param1 と Param2 を加え、その後、
% システムから Param1 を削除します。
%
% 参考 : ADD_PARAM, GET_PARAM, SET_PARAM


% Copyright 1990-2002 The MathWorks, Inc.

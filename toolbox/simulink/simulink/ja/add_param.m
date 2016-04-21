% ADD_PARAM   Simulink システムにパラメータを追加
%
% ADD_PARAM('SYS','PARAMETER1','VALUE1','PARAMETER2','VALUE2',...) は、指定
% したパラメータをシステムに追加し、それらを指定した値に初期化します。 なお、
% 'SYS'は、システムです。パラメータ名については、大文字と小文字の区別はありません
% 。値の文字列については、大文字と小文字は区別されます。
% パラメータの値は、文字列である必要があります。
% 一旦、パラメータをシステムに追加すると、その新しいパラメータに関しても、標準の
% Simulinkパラメータ同様、set_param と get_paramを利用することができます。
%
% 例題:
%
% add_param('vdp','Param1','Value1','Param2','Value2')
%
% は、パラメータParam1とParam2を、値 'Value1'と'Value2' とともに
% vdp システムに追加します。
%
% 参考 : DELETE_PARAM, GET_PARAM, SET_PARAM


% Copyright 1990-2002 The MathWorks, Inc.

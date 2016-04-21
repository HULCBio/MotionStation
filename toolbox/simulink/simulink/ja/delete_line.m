% DELETE_LINE   Simulinkシステムからラインを削除
%
% DELETE_LINE('SYS','OPORT','IPORT')は、指定したブロック出力端子 'OPORT'から
% 指定したブロック入力端子 'IPORT' までのラインを削除します。'OPORT'と '
% IPORT' は、ブロック名と端子識別子から構成される 'block/port' 形式の文字列
% です。ほとんどのブロック端子は、'Gain/1'や'Sum/2'のように、上から下または左
% から右に番号付けすることによって識別します。Enable,Trigger, State端子は、
% 'subsystem_name/Enable'や 'Integrator/State'や'subsystem_name/Ifaction'
% のように名前で識別されます。
%
% DELETE_LINE('SYSTEM',[X Y]) は、指定した点(X,Y)を含むシステムのラインの
% 1つが存在すれば、それを削除します。
%
% 例題:
%
% delete_line('mymodel','Sum/1','Mux/2')
%
% は、SumブロックをMuxブロックの2番目の入力に接続しているラインをmymodel
% モデルから削除します。
%
% 参考 : ADD_LINE.


% Copyright 1990-2002 The MathWorks, Inc.

% SETFIS は、ファジイ推論システムのプロパティを設定します。
% 
% FIS2 = SETFIS(FIS1,'fisPropName',newPropValue) は、'fisPropName' に対
% 応するFISプロパティが newPropValue に設定される以外、FIS1 と同じ内容の
% FIS 行列 FIS2 を出力します。
%
% FIS2 = SETFIS(FIS1,varType,varIndex,'varPropName',newPropValue) は、
% varType と varIndex で指定された変数に関連したプロパティを新しく設定し
% た FIS2 を出力します。
% 
% FIS2 = SETFIS(FIS1,varType,varIndex,'mf',mfIndex, 'mfPropName',....
% newPropValue) は、varType、varIndex、mfIndex で指定されたメンバシップ
% 関数に関連したプロパティに新しい値を設定した FIS2 を出力します。
%
% 例題:
%           a = newfis('tipper');
%           a = addvar(a,'input','service',[0 10]);
%           a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           getfis(a)
%           a = setfis(a,'Name','tip_example');
%           a = setfis(a,'DefuzzMethod','bisector');
%           a = setfis(a,'input',1,'Name','quality');
%           getfis(a)
%
% 参考    GETFIS.


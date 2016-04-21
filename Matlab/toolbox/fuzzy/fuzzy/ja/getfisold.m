% getfisold は、ファジィ推論システムのプロパティを取得します。
% 
% OUT = getfisold(FIS) は、ファジイ推論システム FIS に関する一般的な情報
% を出力します。OUT = getfisold(FIS,'fisProp') は、'fisProp' と名付けた 
% FIS プロパティのカレント値を出力します。
% 
% OUT = getfisold(FIS,'varType',varIndex) は、指定した FIS 変数に関する
% 一般的な情報のリストを出力します。
% OUT = getfisold(FIS,'varType',varIndex,'varProp') は、'varProp' と名付
% けた変数プロパティのカレント値を出力します。
%
% OUT = getfisold(FIS,'varType',varIndex,'mf',mfIndex) は、指定した FIS 
% メンバシップ関数に関する一般的な情報のリストを出力します。
% OUT = getfisold(FIS,'varType',varIndex,'mf',mfIndex,'mfProp') は、'mf-
% Prop' と名付けたメンバシップ関数のプロパティのカレント値を出力します。
% 
% 例題:
%        a = newfis('tipper');
%        a = addvar(a,'input','service',[0 10]);
%        a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%        a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%        getfisold(a)
%        getfisold(a,'input',1)
%        getfisold(a,'input',1,'mf',2)
%
% 参考     SETFIS, SHOWFIS.


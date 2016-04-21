% GETFIS ファジィ推論システムのプロパティの取得
% 
% OUT = GETFIS(FIS) は、ファジィ推論システム FIS の一般的な情報のリスト
% を出力します。
% OUT = GETFIS(FIS,'fisProp') は、'fisProp' と名付けた FIS プロパティの
% カレントの値を出力します。
% OUT = GETFIS(FIS, 'vartype', 'varindex') は、'varindex' の 'vartype'
% の一般的な情報のリストを出力します。
% OUT = GETFIS(FIS, 'vartype', 'varindex', 'varprop') は、'varindex' の
% 'vartype' に対する 'varprop' のカレントの値を出力します。 
% OUT = GETFIS(FIS, 'vartype', 'varindex', 'mf', 'mfindex') は、メンバ
% シップ関数 'mfindex' の一般的な情報のリストを出力します。
% OUT = GETFIS(FIS, 'vartype', 'varindex', 'mf', 'mfindex', 'mfprop') 
% は、'mfindex' の 'mf' に対する 'mfprop' のカレントの値を出力します。
%
% 例題
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    getfis(a)
%
% 参考    SETFIS, SHOWFIS.


%   Ned Gulley, 2-2-94, Kelly Liu 7-10-96
%   Copyright 1994-2002 The MathWorks, Inc. 

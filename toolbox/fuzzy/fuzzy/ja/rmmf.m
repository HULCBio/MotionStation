% RMMF   FIS からメンバシップ関数を除去
% 
% fis2 = RMMF(fis,varType,varIndex,'mf',mfIndex, warningDlgEnabled) は、
% FIS 行列 fis に関連したファジィ推論システムから設定されたメンバシップ
% 関数を除去します。確認が必要な場合、ブーリアン変数 'warningDlgEnabled'
% を指定します。変数 'varType' は、'input' または 'output' のどちらか
% です。メンバシップ関数の消去後、入力なしか出力メンバシップを含むすべて
% のルールは、fis から取り除かれます。
%
% 例題:
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    subplot(2,1,1),plotmf(a,'input',1)
%    a = rmmf(a,'input',1,'mf',2);
%    subplot(2,1,2),plotmf(a,'input',1)
%
% 参考    ADDMF, ADDRULE, ADDVAR, PLOTMF, RMVAR.


%   Ned Gulley, 2-2-94   Kelly Liu 7-22-96
%   Copyright 1994-2002 The MathWorks, Inc. 

% PLOTFIS FIS 入力―出力ダイアグラムの表示
% 
% PLOTFIS(FISSTRUCT) は、FIS 構造体 FISSTRUCT 関連のファジィ推論システム
% の入力-出力表示を作成します。入力とこれらのメンバシップ関数は、FIS 構
% 造体の特性の左側に表示され、出力とそのメンバシップ関数は、右側に表示さ
% れます。
%
% この FIS ダイアグラムは、(コマンド FUZZY で起動する)FIS Editor 上部の
% ものと類似しています。
%
% 例題:
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    a = addvar(a,'input','food',[0 10]);
%    a = addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%    a = addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%    a = addvar(a,'output','tip',[0 30]);
%    a = addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%    a = addmf(a,'output',1,'generous','trimf',[20 25 30]);
%    ruleList = [1 1 1 1 2; 2 2 2 1 2 ];
%    a = addrule(a,ruleList);
%    plotfis(a)
% 
% 参考    EVALMF, PLOTMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

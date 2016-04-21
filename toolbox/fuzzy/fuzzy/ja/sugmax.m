% SUGMAX 菅野ファジィシステムの最大出力範囲の検索
% 
% [maxOut,minOut] = SUGMAX(FIS) は、入力変数の範囲に前もって制限を設けて
% 行列 FIS に関連した菅野ファジイ推論システムに対する可能な最大出力と最
% 小出力に対応する2つのベクトル maxOut と minOut を出力します。maxOut と
% maxIn には、出力の要素数と同じ要素数をもっています。
%
% 例題
%    a = newfis('sugtip','sugeno');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    a = addvar(a,'input','food',[0 10]);
%    a = addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%    a = addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%    a = addvar(a,'output','tip',[0 30]);
%    a = addmf(a,'output',1,'cheap','constant',5);
%    a = addmf(a,'output',1,'generous','constant',25);
%    ruleList = [1 1 1 1 2; 2 2 2 1 2 ];
%    a = addrule(a,ruleList);
%    sugmax(a)



%   Copyright 1994-2002 The MathWorks, Inc. 

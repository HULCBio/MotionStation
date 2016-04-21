% SHOWRULE FIS ルールの表示
% 
% SHOWRULE(FIS) は、行列 FIS に関連したファジィ推論システムに対して、
% verbose フォーマットですべてのルールを表示します。
%
% SHOWRULE(FIS,ruleIndex) は、ベクトル ruleIndex により設定したルール
% を表示します。
%
% SHOWRULE(FIS,ruleIndex,ruleFormat) は、ruleFormat により設定したルー
% ルフォーマットを使ってルールを表示します。これには、'verbose' (デフォ
% ルト)、'symbolic' (言語ニュートラル)、および、'indexed' (メンバシップ
% 関数インデックス参照用)の中の1つを使うことができます。
%
% SHOWRULE(fis,ruleIndex,ruleFormat,lang) は、'english'、'francais'、
% 'deutsch' のいずれかである必要がある lang 設定の言語内にキーワードがあ
% ると仮定して、verbose モードでルールを表示します。キーワード(English)
% は、IF、THEN、IS、AND、OR、NOT です。
%
% 例題
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
%    showrule(a,[2 1],'symbolic')
%
% 参考    ADDRULE, PARSRULE, RULEEDIT.



%   Copyright 1994-2002 The MathWorks, Inc. 

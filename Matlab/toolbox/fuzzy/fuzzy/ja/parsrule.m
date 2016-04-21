% PARSRULE ファジィルールの文法的な記述
% 
% この関数の文法記述は、ファジィシステム(fis)のルール(txtRuleList)を決定
% し、適切なルールのリストをもつ FIS 構造体を出力するものです。オリジナ
% ルの入力 FIS 構造体 fis が最初にルールをもつ場合、新しい行列 fis2 と置
% き換えます。3つの異なるルールフォーマット(ruleFormat で設定)が、サポー
% トされています。これらは、*verbose*、*symbolic*、*indexed* です。デフ
% ォルトフォーマットは、*verbose* です。オプションの言語引数(lang)が使わ
% れるとき、verbose モードとなり、キーワードは、lang で与えられた言語に
% なります。ここで利用できる言語は、'english'、'francais'、'deutsch' で
% す。英語でのキーワードは、IF、THEN、IS、AND、OR、NOT です。
%
% outFIS = PARSRULE(inFIS,inRuleList) は、文字列行列 inRuleList にルール
% の構文解析を行って、更新した FIS 行列 outFIS を出力します。
%
% outFIS = PARSRULE(inFIS,inRuleList,ruleFormat) は、与えられた ruleFo-
% rmat によってルールの構文解析が行われます。
%
% outFIS = PARSRULE(inFIS,inRuleList,ruleFormat,lang) は、キーワードが 
% lang により与えられる言語として、verbose モードでルールの構文解析が行
% われます。
%
% 例題:
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addvar(a,'input','food',[0 10]);
%    a = addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%    a = addvar(a,'output','tip',[0 30]);
%    a = addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%    rule1 = 'if service is poor or food is rancid then tip is cheap';
%    a = parsrule(a,rule1);
%    showrule(a)
%
% 参考    ADDRULE, RULEEDIT, SHOWRULE.



%   Copyright 1994-2002 The MathWorks, Inc. 

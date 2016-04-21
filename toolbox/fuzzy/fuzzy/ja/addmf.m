% 表示
% a = addmf(a,varType,varIndex,mfName,mfType,mfParams)
%
% 詳細
% メンバシップ関数は、既に存在している FIS の変数名に、付加することがで
% きます。インデックスは、付加される順にメンバーシップ関数に割り当てられ
% ます。そのため、変数に付加された最初のメンバーシップ関数は、その変数に
% 対してメンバーシップ関数番号1となります。1つだけの入力しか定義されてい
% ない場合、システムへの入力変数番号2にメンバシップ関数を付加することが
% できません。関数は、つぎの順番に6つの入力引数を必要とします。
%
%   1. ワークスペース内のFIS構造体の MATLAB 変数名
%   2. (入力または出力に)メンバーシップ関数を付加する変数のタイプを表す
%      文字列
%   3. メンバーシップ関数を付加する変数のインデックス
%   4. 新しいメンバシップ関数の名前
%   5. 新しいメンバシップ関数のタイプ
%   6. メンバシップ関数を設定するパラメータベクトル
%
% 例題
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    plotmf(a,'input',1)
%
% 参考    ADDRULE, ADDVAR, PLOTMF, RMMF, RMVAR



%  Copyright 1994-2002 The MathWorks, Inc. 

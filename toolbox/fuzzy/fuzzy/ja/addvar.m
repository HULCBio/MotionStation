% 目的
% 変数を FIS に付加します。
%
% 表示
% a = addvar(a,varType,varName,varBounds)
%
% 詳細
% addvar は、つぎの順番で並べられた4つの引数をもっています。
% 1. FIS の名前
% 2. 変数のタイプ(入力または出力)
% 3. 変数の名前
% 4. 変数の制限範囲を記述するベクトル
% インデックスは、付加される順に変数に適用され、システムに付加される最初
% の入力変数は、そのシステムに対して入力変数番号1となります。入力変数と
% 出力変数は、別々に番号が付けられます。
%
% 例題
%     a = newfis('tipper');
%     a = addvar(a,'input','service',[0 10]);
%     getfis(a,'input',1)
%     MATLAB replies
%     Name = service
%     NumMFs = 0
%     MFLabels  = 
%     Range = [0 10]
%
% 参考    addmf, addrule, rmmf, rmvar



%   Copyright 1994-2002 The MathWorks, Inc. 

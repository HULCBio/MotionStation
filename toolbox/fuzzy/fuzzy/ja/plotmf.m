% PLOTMF 1つの変数に対するすべてのメンバシップ関数の表示
% 
% PLOTMF(fismat,varType,varIndex) は、verType や verIndex によって与えら
% れたタイプ(入力または出力)やインデックスを表す変数が表される行列 fis-
% mat により与えるファジィ推論システムで設定する変数関連のすべてのメンバ
% シップ関数をプロットします。この関数は、MATLAB の関数 subplot と共に用
% いることもできます。
%
% [xOut,yOut] = PLOTMF(fismat,varType,varIndex) は、メンバシップ関数関連
% の x と y のデータ点を、プロットすることなく出力します。
%
% PLOTMF(fismat,varType,varIndex,numPts) は、曲線をちょうど numPts 個の
% 点でプロットしたものと同じプロットを作成します。
%
% 例題
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    plotmf(a,'input',1)
%
% 参考    EVALMF, PLOTFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 

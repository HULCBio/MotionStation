% function [basic,sol,cost,lambda,tnpiv,flopcnt] = ....
%                                    linp(a,b,c,startbasic)
%
% 線形計画法に対するシンプレックスアルゴリズムです。データは、3つの行列、
% A (m行n列、m<=n)、B(m行1列)、C(1行n列)と、STARTBASICという基本的で、可
% 解である解に対応する整数要素のオプションベクトルです。この変数が省略さ
% れると、基本的な解が補助的な問題を使って得られます。出力は、つぎのもの
% を含みます。
%   BASIC   -  最適基本解のインデックス
%   SOL -  基本解のベクトル(size = m)
%   COST-  最適コスト
%   LAMBDA  -  2つの問題の解
%   TNPIV   -  ピボット演算の総数
%   FLOPCNT -  flopカウント
% 
% 参考: MU.

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:09 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 

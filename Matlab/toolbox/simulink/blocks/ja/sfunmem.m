% SFUNMEM   1積分ステップmemoryブロックS-function
%
% このM-ファイルS-functionは、下位互換性のために提供されています。
% このS-functionをmemoryブロックとして用いるSimulinkモデルは、ブロックを
% memoryブロックで置き換える必要があります。
%
% このM-ファイルS-functionは、値を保持し、1積分ステップ遅らせる、"memory"機能
% を実現します。そのため、積分プロセスでの時間の増分が大きくても小さくても、
% この関数は、1段前の積分ステップの入力変数を保持します。
%
% この関数は、clockを入力として、シミュレーションのステップサイズを取得するの
% に使います。
%
% 一般的なS-functionのテンプレートは、sfuntmpl.mを参照してください。
%
% 参考 : SLUPDATE, SFUNTMPL.


% Copyright 1990-2002 The MathWorks, Inc.

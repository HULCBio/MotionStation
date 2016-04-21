% SFUNDSC1   M-ファイル S-functionによる継承されたサンプル時間をもつメモリ
% の例
%
% このM-ファイルS-functionは、状態をもち
% サンプル時間を継承したS-functionを実現した例です。
% 実際のサンプル時間は、このS-functionを制御するブロックによって決定されます。
% このブロックは、連続時間または離散時間のいずれでも構いません。
% このS-functionは、前回の入力が現在の出力として与えられるストレージとして、
% 1つの離散状態要素を利用します。
%
% 一般的なS-functionのテンプレートは、sfuntmpl.mを参照してください。
%
% 参考 : SFUNTMPL.


% Copyright 1990-2002 The MathWorks, Inc.

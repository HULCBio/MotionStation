% 目的
% ルールエディタとルールの記述
%
% 表示
% ruleedit('a')
% ruleedit(a)
%
% 詳細
% Rule Editor を ruleedit('a') で起動すると、Rule Editor は、ファイル a.
% fis にストアされている FIS 構造体のルールを変更するために使われます。
% また、ファジィ推論システムで使われているルールを調べるためにも使います。
% このエディタを使ってルールを作成するには、最初に使用したい入力変数と出
% 力変数のすべてについて、FIS エディタを使って定義する必要があります。入
% 力変数、出力変数、結合、重みに対して、リストボックスとチェックボックス
% を使って、ルールを作成することができます。構文 ruleedit(a) は、a と呼
% ばれる FIS 構造体のワークスペース変数上で操作したい場合に使うものです。
%
% メニューアイテム
% Rule Editor 上には、関連 GUI ツールのオープン、システムのオープンとセ
% ーブなどを行うためのメニューバーがあります。Rule Editor の File メニュ
% ーは、FIS Editorのものと同じです。詳細については、リファレンスの fuzzy
% の部分を参照してください。
%
% Edit メニューアイテムを使って、つぎの機能を実行できます。
% Undo: 最も新しい変更を元に戻す。
%
% View メニューアイテムを使って、つぎの機能を実行できます。
% Edit FIS properties...         FIS Editor の起動
% Edit membership functions...   Membership Function Editor の起動
% View rules...                  Rule Viewer の起動
% View surface...                Surface Viewer の起動
%
% Options メニューアイテムを使って、つぎの機能を実行できます。
% Language  : 言語の選択：English、Deutsch、Francais
% Format    : つぎのフォーマットを選択: 
%             verbose は、*if*、*then* などの単語を使って実際の文を作成
%             symbolic は、verbose モードで使うワードに対するシンボリッ
%             ク表現
%             たとえば、、*if A and B then C*は*A & B  = > C.* になりま
%             す。
%             indexed は、FIS 構造体内にルールがストアされる方法を反映
%
% 参考    ADDRULE, MFEDIT, RULEVIEW, SHOWRULE, SURFVIEW



%   Copyright 1994-2002 The MathWorks, Inc. 

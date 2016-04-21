% TIMERFIND   timer オブジェクトの検出
%
% OUT = TIMERFIND は、メモリ内にあるすべての timer オブジェクトを配列
% OUT に出力します。
%
% OUT = TIMERFIND('P1', V1, 'P2', V2,...) は、パラメータ/値の組み合わせ
% P1, V1, P2, V2 として渡されたプロパティ値と一致する timer オブジェクト
% を配列 OUT に出力します。パラメータ-値の組み合わせは、セル配列として
% 指定することができます。
%
% OUT = TIMERFIND(S) は、構造体 S 内に定義されたプロパティ値と一致する
% timer オブジェクトを配列 OUT に出力します。S のフィールド名は、timer 
% オブジェクトのプロパティ名で、フィールドの値は、対応するプロパティ値
% です。
%   
% OUT = TIMERFIND(OBJ, 'P1', V1, 'P2', V2,...) は、一致するパラメータ-値
% の組み合わせを timer オブジェクト OBJ に制限します。OBJ は、timer 
% オブジェクトの配列です。
%
% パラメータ-値の文字列の組み合わせの構造体と、パラメータ-値のセル配列は、
% TIMERFIND への同じ呼び出しを使用することができます。
%
% TIMERFIND は、多くのプロパティに対して、プロパティ値の検索に大文字
% 小文字を区別することに注意してください。例えば、オブジェクトの Name 
% プロパティ値が 'MyObject' の場合、'myobject' を指定すると、TIMERFIND 
% は、一致するものを検索しません。プロパティ値の正確な形式を定義するには、
% GET 関数を使用してください。しかしながら、列挙されたリストのデータ
% タイプをもつプロパティは、プロパティ値に対する検索を行うときに大文字
% 小文字を区別しません。例えば、ExecutionMode のプロパティ値を 
% 'singleShot' または 'singleshot' の値としても、TIMERFIND は、オブ
% ジェクトを見つけることができます。
%
% 例題:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfind('Tag', 'displayProgress')
%      out2 = timerfind({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
% 参考 : TIMER/GET.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 

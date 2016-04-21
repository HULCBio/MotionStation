% TIMERFIND   指定されたプロパティ値による timer オブジェクトの検出
%
% OUT = TIMERFIND は、メモリ内に存在するすべての timer オブジェクトを
% 出力します。timer オブジェクトは、配列 OUT として出力されます。
%
% OUT = TIMERFIND('P1', V1, 'P2', V2,...)は、プロパティ名とプロパティ
% 値が、これらのパラメータ値の組み合わせ P1, V1, P2, V2,... として
% 渡されたものと一致する timer オブジェクトの配列 OUT を出力します。
% パラメータ値の組み合わせは、セル配列として指定することができます。
%
% OUT = TIMERFIND(S) は、プロパティ値が、フィールド名が timer オブジェ
% クトのプロパティ名で、フィールド値が必要なプロパティ値である構造体 
% S 内で定義されたものと一致するtimer オブジェクトの配列 OUT を出力し
% ます。
%   
% OUT = TIMERFIND(OBJ, 'P1', V1, 'P2', V2,...) は、パラメータ値一致
% 検索を、OBJ 内にリストされた timer オブジェクトのみに制限します。
% OBJ は、timer オブジェクトの配列でも構いません。
%
% TIMERFIND への同じコールとして、パラメータ値の文字列の組み合わせ、
% 構造体、およびパラメータ値のセル配列の組み合わせを使用することが
% できることに注意してください。
%
% プロパティ値が指定された場合、GET で返されるものと同じ書式を使わな
% ければなりません。例えば、GET が 'MyObject' として名前を出力する場合、
% TIMERFIND は、'myobject' の名前のプロパティ値をもつオブジェクトを
% 検出しません。しかし、プロパティ値に対して探索する場合、列挙された
% リストデータタイプをもつプロパティは、大文字、小文字は区別されません。
% 例えば、TIMERFIND は、'singleShot' または 'singleshot' の ExecutionMode 
% プロパティ値をもつオブジェクトを検出します。
%
% 例題:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfind('Tag', 'displayProgress')
%      out2 = timerfind({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
% 参考:  TIMER/GET.
%


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2003/04/18 16:32:21 $

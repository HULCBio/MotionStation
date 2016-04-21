%TIMERFINDALL 指定したプロパティ値をもつすべての timer オブジェクトの検索
%
% OUT = TIMERFINDALL は、オブジェクトの ObjectVisibility プロパティ値
% に依らず、メモリにあるすべての timer オブジェクトを出力します。timer
% オブジェクトは、 OUT に対する配列として出力されます。
%
% OUT = TIMERFINDALL('P1', V1, 'P2', V2,...) は、timer オブジェクトの配列、
% OUT を出力します。このオブジェクトのプロパティ名とプロパティ値は、パラメータ
% と値の組、P1, V1, P2, V2,... として渡されるものに一致します。パラメータと値
% の組は、セル配列として指定されます。
%
% OUT = TIMERFINDALL(S) は、timer オブジェクトの配列 OUT を出力します。 
% この timer オブジェクトのプロパティ値は、構造体 S に定義されたプロパティ
% 値と一致します。S のフィールド名は、timer オブジェクトのプロパティ名であり、
% フィールドの値は、要求されるプロパティ値です。
%   
% OUT = TIMERFINDALL(OBJ, 'P1', V1, 'P2', V2,...) は、OBJ にリストされる
% timer オブジェクトのパラメータと値の組に検索を制限します。
% OBJ は、timer オブジェクトの配列になります。
%
% TIMERFINDALL への同じ呼び出しにおいて、パラメータと値の文字列の組、
% 構造体、パラメータと値のセル配列の組を使用することができることに注意
% してください。
%
% プロパティ値が指定される場合、GET の出力と同じ書式を使用する必要があります。
% たとえば、GET が 'MyObject' として Name を返す場合、TIMERFINDALL は、
% 'myobject'の Name プロパティ値をもつオブジェクトを検索しません。
% しかし、並べられたリストのデータタイプをもつプロパティは、プロパティ値の
% 検索の場合、大文字と小文字を区別しません。 
% たとえば、TIMERFINDALL は、'FixedRate' または 'fixedrate' の Parity 
% プロパティ値をもつオブジェクトを検索します。
%
% 例題:
%   t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%   t2 = timer('Tag', 'displayProgress');
%   out1 = timerfindall('Tag', 'displayProgress')
%   out2 = timerfindall({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
% 参考 TIMERFIND, TIMER/GET.
%

%    RDD 03-27-2003
%    Copyright 2001-2003 The MathWorks, Inc. 

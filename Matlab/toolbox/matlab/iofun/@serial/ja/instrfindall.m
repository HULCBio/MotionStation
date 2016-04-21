%INSTRFINDALL 指定したプロパティ値をもつすべての serial port オブジェクト
%             を検索
%
% OUT = INSTRFINDALL は、オブジェクトの ObjectVisibility プロパティ値、
% に依らずメモリにあるすべての serial port オブジェクトを出力します。
% serial port オブジェクトは、配列としてOUT に出力されます。
%
% OUT = INSTRFINDALL('P1', V1, 'P2', V2,...) は、serial port 
% オブジェクトをもつ、配列 OUT を出力します。このオブジェクトの
% プロパティ名とプロパティ値は、パラメータと値の組、P1, V1, P2, V2,..
% として渡されるものに一致します。 パラメータと値の組は、セル配列として
% 指定することができます。
%
% OUT = INSTRFINDALL(S) は、serial port オブジェクトのプロパティ値が
% 構造体 S に定義されたものと一致する、配列、OUTを出力します。
% この構造体のフィールド名が serial port オブジェクトプロパティ名であり、
% フィールドの値が必要とされるプロパティ値です。
%   
% OUT = INSTRFINDALL(OBJ, 'P1', V1, 'P2', V2,...) は、OBJ にリストされる
% serial port オブジェクトにパラメータと値の組と一致するものに検索を制限
% します。OBJ は、serial port オブジェクトの配列になります。
%
% INSTRFIND への同じコールで、パラメータ-値の文字列の組、構造体、
% パラメータ-値のセル配列の組を使用することができることに注意して
% ください。
%
% プロパティ値が指定される場合、GET の出力と同じフォーマットを使用する
% 必要があります。たとえば、GET が Name を 'MyObject' として出力する場合、
% INSTRFIND は、'myobject' という Name プロパティ値をもつオブジェクトを
% 検索しません。しかし、並べられたリストのデータタイプをもつプロパティは、
% プロパティ値を検索する際、大文字と小文字を区別しません。たとえば、
% INSTRFIND は、'Even' または 'even' の Parity プロパティ値をもつ
% オブジェクトを検索します。
%
% 例題:
%       s1 = serial('COM1', 'Tag', 'Oscilloscope');
%       s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%       set(s1, 'ObjectVisibility', 'off');
%       out1 = instrfind('Type', 'serial')
%       out2 = instrfindall('Type', 'serial');
%
% 参考 SERIAL/GET, SERIAL/INSTRFIND.
%

% MP 9-19-02
% Copyright 1999-2004 The MathWorks, Inc. 

% INSTRFIND   指定したプロパティ値をもった serial port オブジェクトの検索
%
% OUT = INSTRFIND は、メモリ内に存在しているすべての serial port オブ
% ジェクトを出力します。serial port オブジェクトは、配列として、OUT に
% 出力されます。
%
% OUT = INSTRFIND('P1', V1, 'P2', V2,...) は、P1, V1, P2, V2,...と言う
% パラメータ-値の組で渡される serial port オブジェクトのプロパティ値と
% 一致するものを配列 OUT に出力します。パラメータ-値の組は、セル配列と
% して指定できます。
%
% OUT = INSTRFIND(S) は、serial port オブジェクトのプロパティ値が、構造
% 体 S のフィールド名がserial port オブジェクト名と一致して、フィールド
% 値が必要とされるプロパティ値であるものを配列 OUT を出力します。
%   
% OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) は、OBJ の中にリスト
% される serial port オブジェクトにパラメータ-値の組と一致するものを
% 探索します。OBJ は、serial port オブジェクトの配列です。
%
% INSTRFIND への同じコールで、パラメータ-値の文字列の組、構造体、
% パラメータ-値のセル配列の組を使用することができることに注意して
% ください。
%
% プロパティ値が指定される場合、GET が出力するものと同じフォーマットを
% 使用しなければなりません。たとえば、GET が、'MyObject'と同じ Name を
% 出力する場合、INSTRFIND は、'myobject' の Name プロパティ値をもつ
% オブジェクトを検索しません。しかし、計算リストデータタイプをもつ
% プロパティは、プロパティ値の検索において、大文字、小文字の区別を行い
% ません。たとえば INSTRFIND は、Parity プロパティ値、'Even' でも 
% 'even' でも設定したオブジェクトを検索できます。
%
% 例題:
%      s1 = serial('COM1', 'Tag', 'Oscilloscope');
%      s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%      out1 = instrfind('Type', 'serial')
%      out2 = instrfind('Tag', 'Oscilloscope')
%      out3 = instrfind({'Port', 'Tag'}, {'COM2', 'FunctionGenerator'})
%
% 参考 : SERIAL/GET.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 

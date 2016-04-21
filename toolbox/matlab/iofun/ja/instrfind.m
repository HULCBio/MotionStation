% INSTRFIND 　指定したプロパティ値をもつserialオブジェクトを検索
%
% OUT = INSTRFIND は、存在していて、かつ正しい型をもつすべてのserial 
% オブジェクトを出力します。serialオブジェクトは、配列として OUT に出
% 力されます。
%
% OUT = INSTRFIND('P1', V1, 'P2', V2,...) は、プロパティの名前と値が、
% パラメータと値の組、P1, V1, P2, V2,... で渡されるものと一致するserial
% オブジェクトを配列 OUT に出力します。パラメータと値の組は、1つのセル
% 配列として指定されます。
%
% OUT = INSTRFIND(S) は、serial portオブジェクトのプロパティ値が構造体  
% S で定義されているものと一致し、フィールド名がserialオブジェクトの
% プロパティ名で、フィールドの値が要求されるプロパティ値であるものを、
% 配列 OUT として出力します。
%   
% OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) は、PV 組に対する検索を、
% OBJ の中にリストされたserialオブジェクトに制限します。OBJ は、オブジェ
% クトの配列です。
%
% INSTRFIND への同じコールで、PV 文字列の組、構造体、PV セル配列の組を
% 使用することができることに注意してください。
%
% プロパティ値が指定される場合、GET が出力するものと同じフォーマットを
% 使用しなければなりません。たとえば、GET が'MyObject'と同じ Name を出力
% する場合、INSTRFIND は、'myobject' の Name プロパティ値をもつオブジェ
% クトを検索しません。しかし、計算リストデータタイプをもつプロパティは、
% プロパティ値の検索において、大文字、小文字の区別を行いません。たとえば、
% INSTRFIND は、Parity プロパティ値において、'Even'でも'even'とでも設定
% したオブジェクトを検索できます。
% 
% 例題：
%      s1 = serial('COM1', 'Tag', 'Oscilloscope');
%      s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%      out1 = instrfind('Type', 'serial')
%      out2 = instrfind('Tag', 'Oscilloscope')
%      out3 = instrfind({'Port', 'Tag'}, {'COM2', 'FunctionGenerator'})
%
% 参考： SERIAL/GET.


%    MP 7-13-99
%    Copyright 1999-2002 The MathWorks, Inc. 

% SUPERIORTO   上位クラスの関係
%
% SUPERIORTO('CLASS1','CLASS2',...) が、クラスコンストラクタメソッド
% (myclass.m)に呼び出されると、myclass のオブジェクトや、クラス CLASS1、
% CLASS2 等の1つ以上のオブジェクトと共に関数がコールされた場合には、
% myclass メソッドが呼び出されます。
%
% Aのクラスが'class_a'で、Bのクラスが'class_b'、Cのクラスが'class_c'で
% あると仮定します。また、class_c.mがステートメント
%
%      SUPERIORTO('CLASS_A')
%
% を含む場合、E = FUN(A,C)、または、E = FUN(C,A)は、CLASS_C/FUNを呼び
% 出します。
%
% 指定されていない関係をもつ2つのオブジェクトと共に関数がコールされると、
% 2つのオブジェクトは同等の優先権をもつと考えられ、一番左のオブジェクト
% のメソッドがコールされます。FUN(B,C)は、CLASS_B/FUNを呼び出し、FUN(C,B)
% はCLASS_C/FUNを呼び出します。
%
% 参考：INFERIORTO.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:54 $
%   Built-in function.

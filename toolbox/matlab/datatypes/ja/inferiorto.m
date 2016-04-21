% INFERIORTO   下位クラスの関係
% 
% クラスコンストラクタメソッド(myclass.m)でINFERIORTO('CLASS1',
% 'CLASS2',...)を呼び出すと、クラスmyclassのオブジェクトや、クラス
% CLASS1、CLASS2等の1つ以上のオブジェクトと共に関数コールされる場合
% には、myclass のメソッドは呼び出されません。
%
% Aのクラスが'class_a'で、Bのクラスが'class_b'で、Cのクラスが'class_c'
% であると仮定します。また、クラスclass_c.mが、ステートメントINFERIORTO
% ('CLASS_A')を含むとすると、E = FUN(A,C)、または、E = FUN(C,A)は、CLASS
% _A/FUNを呼び出します。
%
% 指定されていない関係をもつ2つのオブジェクトと共に関数がコールされると、
% 2つのオブジェクトは同じ優先権をもつと考えられ、一番左のオブジェクトの
% メソッドがコールされます。FUN(B,C)はCLASS_B/FUNをコールし、FUN(C,B)は
% CLASS_C/FUNをコールします。
%
% 参考：SUPERIORTO.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:21 $
%   Built-in function.


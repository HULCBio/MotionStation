% NUM2CELL   セル配列内に数値配列を変換
%
% C = NUM2CELL(A) は、個別のセルに、A の各要素を入れることによって
% 配列 A をセル配列に変換します。C は、A と同じ大きさになります。
%
% C = NUM2CELL(A,DIMS) は、個別のセルに DIMS によって指定された次元を
% 入れることにより、配列 A をセル配列に変換します。C は、DIMS と一致
% する次元が1であるという点を除いて、A と同じ大きさになります。例えば、
% NUM2CELL(A,2) は、個別のセルに A の行を入れます。同様に、
% NUM2CELL(A,[1 3]) は、個別のセルに、A の列を入れます。
%
% NUM2CELL は、すべての配列タイプで機能します。
%
% 変換を戻すには、CELL2MAT または、CAT(DIM,C{:}) を使用してください。
%
% 参考:  MAT2CELL, CELL2MAT

%   Clay M. Thompson 3-15-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:44 $

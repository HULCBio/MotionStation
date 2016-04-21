% function out = massign(matin,rowindex,colindex,data)
%
%	out = massign(matin,rowindex,colindex,data)
%
% VARYING行列とSYSTEM行列に演算を行う行列の割り当てを行います。機能的に、
% つぎのステートメントと等価です。
%	matin(rowindex,colindex) = data
%
% ここで、rowindexとcolindexは、変更する行と列(または、matinがSYSTEM行
% 列の場合、出力と入力)を指定するベクトルです。
%
% dataは、CONSTANTかまたはmatintと同じタイプでなければなりません。dataの
% 次元は、rowindexとcolindexの長さと整合性が保たれていなければなりません。
%
% 注意:  SYSTEM行列に適用されるときは、結果はほとんどの場合、最小位相で
% なくなります。
%
% 参考:  SEL
%



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

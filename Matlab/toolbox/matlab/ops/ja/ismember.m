% ISMEMBER   集合内のメンバの検出
% 
% ISMEMBER(A,S) は、配列 A に対して、A の要素が集合 S にある場合に、
% 1を含む A と同じサイズの配列を出力し、そうでなければ0を返します。
% A と S は、文字列のセル配列でも構いません。
%
% ISMEMBER(A,S,'rows') は、A と S が同じ列数をもつ行列のとき、A の行が
% S の行であるとき1を、そうでなければ0を要素にもつベクトルを出力します。
%
% [TF,LOC] = ISMEMBER(...) は、S のメンバが A の各要素に対して S 内の
% 最も高い絶対的なインデックスを含んでいるインデックス配列 LOC も出力し、
% そのようなインデックスがない場合は、0を返します。
%
% 参考：UNIQUE, INTERSECT, SETDIFF, SETXOR, UNION.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:00:42 $

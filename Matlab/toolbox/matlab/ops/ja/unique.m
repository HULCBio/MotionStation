% UNIQUE   集合の一意的な要素
% 
% UNIQUE(A) は、ベクトル A に対して、A の中の値を重複しないで出力します。
% A はソートされます。A は、文字列のセル配列でも構いません。
%
% UNIQUE(A,'rows') は、行列 A に対して、A の一意的な行を出力します。
%
% [B,I,J] = UNIQUE(...) は、B = A(I) かつ A = B(J)(または B = A(I,:) 
% かつ A = B(J,:))であるようなインデックスベクトル I と J も出力します。
%   
% 参考：UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:11 $

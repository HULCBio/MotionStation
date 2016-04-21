% PDEPRTNI   三角形の中点のデータから節点のデータに補間します。
% UN = PDEPRTNI(P,T,UT) は、三角形の中点での値を使って節点で線形補間され
% た値を求めます。
% PDE 問題の形状は、三角形データ P と T によって与えられます。詳細は、
% INITMESH を参照してください。
% PDE システムの次元を N、節点の数を NP、三角形の数を NT とします。UT の
% 三角形データの成分は、長さ NT の N 行としてストアされます。節点データ
% の成分は、長さ NPの N 列として、UNにストアされます。
%
% 参考   ASSEMPDE, INITMESH, PDEINTRP



%       Copyright 1994-2001 The MathWorks, Inc.

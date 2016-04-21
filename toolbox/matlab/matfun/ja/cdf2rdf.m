% CDF2RDF   複素対角型行列を実数ブロック対角型に変換
% 
% [V,D] = CDF2RDF(V,D) は、EIG(X)(Xは実数)の出力を、複素対角型から実対
% 角型に変換します。複素対角型では、D は対角に複素固有値をもちます。実
% 数対角型では、複素固有値は対角上の2行2列のブロックにあります。複素共
% 役固有値の組は、隣接していると仮定されます。
%
% 参考：EIG, RSF2CSF.

%   J.N. Little 4-27-87
%   Based upon M-file from M. Steinbuch, N.V.KEMA & Delft Univ. of Tech.
%   Copyright 1984-2004 The MathWorks, Inc. 

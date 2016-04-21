% PRINTMAT   行列にラベルを付けて印刷
% 
% PRINTMAT(A,NAME,RLAB,CLAB) は、行ラベル RLAB と列ラベル CLAB をもつ
% 行列 A を印刷します。NAME は、行列を名付けるために使用する文字列です。
% RLAB と CLAB は、スペースで区切られた行と列のラベルを含む文字列です。
% たとえば、つぎの文字列
%
%    RLAB = 'alpha beta gamma';
%
% は、最初の行に対するラベルとして'alpha'を、二番目の行のラベルとして、
% 'beta'を、三番目のラベルとして'gamma'を定義します。RLAB と CLAB は、
% 行と列それぞれ、スペースで区切られた同じ数のラベルでなければなりません。
% 
% PRINTMAT(A,NAME) は、行と列を数値でラベル付けした行列 A を印刷します。
% PRINTMAT(A) は、名前なしで行列 A を印刷します。
%
% 参考 : PRINTSYS.


%   Clay M. Thompson  9-24-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:19 $

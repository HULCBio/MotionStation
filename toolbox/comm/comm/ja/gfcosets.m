% GFCOSETS   ガロア体の円周等分剰余類を作成
% 
% CS = GFCOSETS(M) は、円周等分剰余類 mod(2^M - 1) を作成します。出力 
% CS の各行は、1つの円周等分剰余類を含んでいます。
%
% CS = GFCOSETS(M, P) は、円周等分剰余類 mod(2^M - 1) を作成します。
% ここで、P は素数です。
%       
% 剰余類の長さが完全集合(complete set)の中で変化するので、NaN を使って、
% 余分な部分を表し、すべての変数が出力行列 CS の中で同じ長さをもつように
% します。
%
% 参考： GFMINPOL, GFPRIMDF, GFROOTS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $   $Date: 2003/06/23 04:34:33 $     

% /   スラッシュまたは行列の右除算
% 
% A/B は、A と B の行列の右除算を行います。計算方法が異なりますが、
% A*INV(B) とほとんど等価です。正確には、A/B = (B'\A')' です。詳細は、
% MLDIVIDE を参照してください。
%
% C = MRDIVIDE(A,B) は、A または B がオブジェクトのとき、シンタックス 
% 'A / B' に対して呼び出されます。
%
% 参考：MLDIVIDE, RDIVIDE, LDIVIDE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:00:50 $

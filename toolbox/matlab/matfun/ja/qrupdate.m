% QRUPDATE   QR分解のランク1の更新
% 
% [Q,R] = QR(A) が A のオリジナルのQR分解の場合、
% [Q1,R1] = QRUPDATE(Q,R,U,V) は、A + U*V' のQR分解を出力します。U と V
% は、適切な長さの列ベクトルです。
% 
% QRUPDATE は、フル行列に対してのみ機能します。
%
% 参考：QR, QRINSERT, QRDELETE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:00:12 $
%   Built-in function.

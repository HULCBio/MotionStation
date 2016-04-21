% QRDELETE   QR分解から列を削除
% 
% [Q1,R1] = QRDELETE(Q,R,J) は、行列 A1 のQR分解を出力します。
% ここで、A1 は列 A(:,J) が削除された A で、[Q,R] = QR(A) は A のQR分解で
% す。"economy size" の QR 分解の行列 Q と R は、 [Q,R] = QR(A,0) によって
% 生成されます。
%
% QRDELETE(Q,R,J,'col') は、QRDELETE(Q,R,J) と同じです。
%
% [Q1,R1] = QRDELETE(Q,R,J,'row') は、行列 A1のQR分解を出力します。ここ
% で、A1 は行 A(J,:) を削除した Aで、 [Q,R] = QR(A) はA のQR分解です。
%
% 例題:
%      A = magic(5);  [Q,R] = qr(A);
%      j = 3;
%      [Q1,R1] = qrdelete(Q,R,j,'row');
%   は、QR分解を出力しますが、以下とは異なります。
%      A2 = A;  A2(j,:) = [];
%      [Q2,R2] = qr(A2);
%
% 参考 ： QR, QRINSERT, PLANEROT.

%   Copyright 1984-2003 The MathWorks, Inc. 


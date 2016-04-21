% QRINSERT   QR分解に列を挿入
% 
% [Q1,R1] = QRINSERT(Q,R,J,X) は、行列 A1のQR分解を出力します。ここで、
% A1 は列XがA(:,J) の前に挿入されたA=Q*R です。A がN 列で、J = N+1 の
% 場合は、X はA の最後の列の後に挿入されます。
%
% QRINSERT(Q,R,J,X,'col') は、QRINSERT(Q,R,J,X) と同じです。
%
% [Q1,R1] = QRINSERT(Q,R,J,X,'row') は行列 A1のQR分解を出力します。ここ
% で、A1 は A(J,:) の前に行Xが挿入されたA=Q*Rです。
%
% 例題:
%      A = magic(5);  [Q,R] = qr(A);
%      j = 3; x = 1:5;
%      [Q1,R1] = qrinsert(Q,R,j,x,'row');
%   は、QR分解を出力しますが、以下とは異なります。
%      A2 = [A(1:j-1,:); x; A(j:end,:)];
%      [Q2,R2] = qr(A2);
%
% 参考 ： QR, QRINSERT, PLANEROT.

%   Copyright 1984-2003 The MathWorks, Inc.
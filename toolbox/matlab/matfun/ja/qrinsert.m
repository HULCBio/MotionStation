% QRINSERT   QR�����ɗ��}��
% 
% [Q1,R1] = QRINSERT(Q,R,J,X) �́A�s�� A1��QR�������o�͂��܂��B�����ŁA
% A1 �͗�X��A(:,J) �̑O�ɑ}�����ꂽA=Q*R �ł��BA ��N ��ŁAJ = N+1 ��
% �ꍇ�́AX ��A �̍Ō�̗�̌�ɑ}������܂��B
%
% QRINSERT(Q,R,J,X,'col') �́AQRINSERT(Q,R,J,X) �Ɠ����ł��B
%
% [Q1,R1] = QRINSERT(Q,R,J,X,'row') �͍s�� A1��QR�������o�͂��܂��B����
% �ŁAA1 �� A(J,:) �̑O�ɍsX���}�����ꂽA=Q*R�ł��B
%
% ���:
%      A = magic(5);  [Q,R] = qr(A);
%      j = 3; x = 1:5;
%      [Q1,R1] = qrinsert(Q,R,j,x,'row');
%   �́AQR�������o�͂��܂����A�ȉ��Ƃ͈قȂ�܂��B
%      A2 = [A(1:j-1,:); x; A(j:end,:)];
%      [Q2,R2] = qr(A2);
%
% �Q�l �F QR, QRINSERT, PLANEROT.

%   Copyright 1984-2003 The MathWorks, Inc.
% QRDELETE   QR�����������폜
% 
% [Q1,R1] = QRDELETE(Q,R,J) �́A�s�� A1 ��QR�������o�͂��܂��B
% �����ŁAA1 �͗� A(:,J) ���폜���ꂽ A �ŁA[Q,R] = QR(A) �� A ��QR������
% ���B"economy size" �� QR �����̍s�� Q �� R �́A [Q,R] = QR(A,0) �ɂ����
% ��������܂��B
%
% QRDELETE(Q,R,J,'col') �́AQRDELETE(Q,R,J) �Ɠ����ł��B
%
% [Q1,R1] = QRDELETE(Q,R,J,'row') �́A�s�� A1��QR�������o�͂��܂��B����
% �ŁAA1 �͍s A(J,:) ���폜���� A�ŁA [Q,R] = QR(A) ��A ��QR�����ł��B
%
% ���:
%      A = magic(5);  [Q,R] = qr(A);
%      j = 3;
%      [Q1,R1] = qrdelete(Q,R,j,'row');
%   �́AQR�������o�͂��܂����A�ȉ��Ƃ͈قȂ�܂��B
%      A2 = A;  A2(j,:) = [];
%      [Q2,R2] = qr(A2);
%
% �Q�l �F QR, QRINSERT, PLANEROT.

%   Copyright 1984-2003 The MathWorks, Inc. 


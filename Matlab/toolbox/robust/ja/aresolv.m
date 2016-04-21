% ARESOLV   �A���n�㐔Riccati������������(eigen & schur)
%
% [P1,P2,LAMP,PERR,WELLPOSED,P] = ARESOLV(A,Q,R,ARETYPE)�́A���̑㐔
% Riccati�������̉����v�Z���܂��B
%
%                     A'P + PA - PRP + Q = 0
%
% "aretype"�ɂ��A���̂�����1��I�����܂��B
%
%                aretype = 'eigen' ---- �ŗL�\���A�v���[�`
%                aretype = 'schur' ---- Schur�x�N�g���A�v���[�`
%
% �o��:   P = P2/P1 Riccati�������̉�
%         [P1;P2] �n�~���g�j�A�� [A,-R;-Q,-A']�̈���ȌŗL���
%         LAMP ���[�v�ŗL�l
%         PERR �c���덷�s��
%         WELLPOSED = �n�~���g�j�A���������ɌŗL�l�������Ȃ����'TRUE'�A
%         �����łȂ����'FALSE'



% Copyright 1988-2002 The MathWorks, Inc. 

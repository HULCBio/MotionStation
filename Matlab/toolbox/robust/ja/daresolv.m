% DARESOLV   ���U�㐔Riccati������������(eigen & schur) 
%
% [P1,P2,LAMP,PERR,WELLPOSED,P] = DARESOLV(A,B,Q,R,ARETYPE)�́A���̗�
% �U�㐔 Riccati�������̉����v�Z���܂��B
%                                   -1
%            A'PA - P - A'PB(R+B'PB)  B'PA + Q = 0
%
% "aretype"�ɂ���āA���̂�����1��I�����܂��B
%
%                aretype = 'eigen' ---- �ŗL�\���A�v���[�`
%                aretype = 'schur' ---- Schur�x�N�g���A�v���[�`
%                aretype = 'dare'  ---- Control System Toolbox DARE
% 
% �o��:      P = P2/P1 Riccati�������̉�
%             [P1;P2] �n�~���g�j�A���̈���ȌŗL���
%             LAMP ���[�v�ŗL�l
%             PERR �c���덷�֐�
%             WELLPOSED = �n�~���g�j�A���������ɌŗL�l�������Ȃ����
%                         'TRUE '�A�����łȂ����'FALSE'�B



% Copyright 1988-2002 The MathWorks, Inc. 

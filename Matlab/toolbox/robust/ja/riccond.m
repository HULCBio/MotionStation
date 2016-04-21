% RICCOND   �A���n��Riccaci�������̏�����
%
% [TOT] = RICCOND(A,B,QRN,P1,P2)�́AArnold �� Laub �̊T�O(1984)���g���āA
% Riccati�������̏����������߂܂��B
%
%    ����:
%
%      �V�X�e��: (A,B)�s��A�d�ݍs��QRN = [Q N;N' R];
%      Riccati�������̉�: P1,P2 (P = P2/P1)
%
%    �o��:
%
%         TOT = [norAc norQc norRc conr conP1 conArn conBey res]
%     ������		                   -1            -1
%        norAc, norQc, norRc ----- Ac=(A-BR N'), Qc=(Q-NR N'), Rc = B/R*B'
%                                  ��F-�m����
%        conr                ----- R�̏�����
%        conP1               ---- P1�̏�����
%        conArn              ---- Arnold �� Laub �� Riccati�������̏�����
%        conBey              ---- Byers��Riccati�������̏�����
%        res                 ---- Riccati�������̎c��
%



% Copyright 1988-2002 The MathWorks, Inc. 

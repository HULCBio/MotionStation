% [tau,Q0,Q1,...] = pdlstab(pds,options)
%
% �|���g�s�b�N�V�X�e����A�t�B���p�����[�^�ˑ��V�X�e��(P-�V�X�e��)�̃��o
% �X�g���萫
%
% �A�t�B���V�X�e���ɑ΂��āAPDLSTAB�́A���ׂẴp�����[�^�O���ɉ�����
% Lyapunov�֐�
%
%       V(x) = x'*P(p)*x        P(p) = inv(Q(p))
%
% �����萫�𖞑�����悤��Lyapunov�s��Q(p)�����߂܂��B
%
% A�A�܂��́AE���萔�ł��鎞�s�σ|���g�s�b�N�V�X�e���ɑ΂��āAPDLSTAB��
% Lyapunov�֐�
%
%     V(x)=x'*inv(Q)*x     Q = c0*Q0 + ... + cn*Qn
%
% ���A(A,E)=(c0*A0+...+cn*An,E)�A�܂��́A(A,E)=(A,c0*E0+...+cn*En)�̂���
% �Ẵ|���g�[�v�̈��萫�����؂���悤�Ȓ[�_Lyapunov�s��Q0, Q1,...������
% �܂��B
%
% ����:
%  PDS       �|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ��V�X�e��(PSYS��
%            �Q��)�B
%  OPTIONS   �I�v�V������2�v�f�x�N�g���B
%            OPTIONS(1)=0 :  ���o�X�g���萫���e�X�g���܂�(�f�t�H���g)�B
%                      =1 :  ���S�̎��͂Ƀp�����[�^�{�b�N�X���g�傷�邱
%                            �Ƃɂ��A���艻�̈���ő�ɂ��܂�(�A�t�B��
%                            PDS�̂�)�B
%            OPTIONS(2)=0 :  �������[�h(�f�t�H���g)�B
%                      =1 :  �����Ƃ��ێ琫�̂Ȃ����[�h�B
% �o��:
%  TAU       OPTIONS(1)�Ɉˑ����܂��B
%            ���̒l�A�܂��́APV�Őݒ肳���p�����[�^�{�b�N�X�̊����Ƃ�
%            �Ă̈��艻�̈�(TAU=1��100%���Ӗ����܂�)�ƂȂ�܂��B
%  Q0,Q1,..  �A�t�B��PDS�ɑ΂��āA���̂悤�ɂȂ�܂��B
%                    Q(p) = Q0 + p1*Q1 + ... + pn*Qn
%            �|���g�s�b�NPDS�ɑ΂��āAQ0,Q1,...�́A�[�_�V�X�e��(A0,E), 
%            (A1,E),..�ɑ΂���Q�̒l�ł��B
%
% �Q�l�F    MUSTAB, QUADSTAB, PSYS.



% Copyright 1995-2002 The MathWorks, Inc. 

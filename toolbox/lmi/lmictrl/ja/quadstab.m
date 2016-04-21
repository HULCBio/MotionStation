% [tau,P] = quadstab(pds,options)
%
% �|���g�s�b�N�V�X�e����A�t�B���p�����[�^�ˑ��V�X�e����2�����萫�B
%
% QUADSTAB�́A�p�����[�^�x�N�g��p�̒l�͈̔͂ɂ����āA���̂悤��Lyapu-
% nov�s�� Q > 0�����߂܂��B
%
%          A(p)*Q*E(p)' + E(p)*Q*A(p)'  < 0
%
% Lyapunov�֐�
% 
%           V(x) = x'*P*x    P = inv(Q)
% 
% �́A���ׂẴp�����[�^�̈��C�ӂ̑����̃p�����[�^�̕ω��ɂ����Ĉ��萫
% ��B�����܂��B
%
% �ő��2�����萫�{�b�N�X�́AOPTIONS(1)��K�؂ɐݒ肷�邱�Ƃɂ���Čv�Z
% ����܂��B
%
% ����:
%  PDS       �|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ��V�X�e��(PSYS��
%            �Q��)�B
%  OPTIONS   �I�v�V������3�v�f�x�N�g��
%            OPTIONS(1)=0 :  2�����萫���e�X�g���܂�(�f�t�H���g)
%                      =1 :  ���S�̎��͂Ƀp�����[�^�{�b�N�X���g�債�āA
%                            ���艻�̈���ő�ɂ��܂�(�A�t�B��PDS�̂�)�B
%            OPTIONS(2)=0 :  �������[�h(�f�t�H���g)�B
%                      =1 :  �����Ƃ��ێ琫�̂Ȃ����[�h�B
%            OPTIONS(3)   :  P�̏������̋��E(�f�t�H���g = 1e8)�B
% �o��:
%  TAU       OPTIONS(1)�Ɉˑ����܂��B
%            ���̒l�A�܂��́APV�Őݒ肳���p�����[�^�{�b�N�X�̊����Ƃ�
%            �Ă�2�����艻�̈�(TAU=1��100%���Ӗ����܂�)�ƂȂ�܂��B
%  P         Lyapunov�s��P = inv(Q)
%
% �Q�l�F    MUSTAB, PDLSTAB, DECAY, QUADPERF.



% Copyright 1995-2002 The MathWorks, Inc. 

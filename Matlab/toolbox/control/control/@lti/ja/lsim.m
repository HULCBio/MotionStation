% LSIM   �C�ӂ̓��͂ɑ΂���LTI���f���̎��ԉ����̃V�~�����[�V����
%
% LSIM(SYS,U,T) �́AU �� T �ŕ\�����ꂽ���͐M���ɑ΂���LTI���f�� SYS 
% �̎��ԉ������v���b�g���܂��B���ԃx�N�g�� T �́A�莞�ԊԊu�̃T���v��
% ����Ȃ�AU �͓��͂Ɠ����񐔂̍s��ł��BU �� i �Ԗڂ̍s���A���� T(i) 
% �ɑΉ�������͂��w�肵�܂��B
% 
% ���Ƃ��΁A 
% 
%        t = 0:0.01:5;   u = sin(t);   lsim(sys,u,t)  
% 
% �́A�P���̓��f�� SYS �ɁAu(t) = sin(t) �̓��͂�^��������5�b�Ԃ̉�����
% �V�~�����[�V�������܂��B 
%
% ���U���ԃ��f���ł́AU �̓V�X�e���Ƃ��ẴT���v�����[�g�Ɠ����T���v����
% �Ȃ���΂����܂���(���̏ꍇ�AT �͏璷�ł���A�ȗ��������s��ɐݒ肵
% ����ł��܂�)�B�A�����Ԃł́A���� U �𐳊m�ɕ\�����邽�߂ɏ\�������ȃT
% ���v�����O�Ԋu T(2)-T(1) ��I�����܂��BLSIM �́A�T���v�����Ԃ̊Ԃł̐U
% �������؂��A�K�v�Ȃ�΁A�T���v�����O���������܂��B
% 
% LSIM(SYS,U,T,X0) �́A(��ԋ�ԃ��f���ɑ΂��Ă̂�)���� T(1) �ŁA������
% �ԃx�N�g�� X0 ��ݒ肵�܂��BX0���ȗ�����ƁA�[���Ɖ��肵�܂��B
%
% LSIM(SYS1,SYS2,...,U,T,X0) �́A������LTI���f�� SYS1,SYS2,... �̉���
% ���V�~�����[�V��������1�̃v���b�g�ɂ��܂��B������� X0 �́A�I�v�V����
% �ł��Blsim(sys1,'r',sys2,'y--',sys3,'gx',u,t) �̂悤�ɁA�J���[�A���C��
% �X�^�C���A�}�[�J���e�V�X�e�����Ɏw�肷�邱�Ƃ��ł��܂��B
%
% [YS,TS] = LSIM(SYS,U,T) �́A�V�~�����[�V�����o�͗� YS �Ƃ���ɑΉ�����
% �����x�N�g�� TS ���o�͂��܂��B���̏ꍇ�A�X�N���[���Ɍ��ʕ\���͂���܂�
% ��B�s�� YS �́ALENGTH(TS) �s�������ASYS �̒��̏o�͐��Ɠ����񐔂�������
% ���܂��B
% 
% �x��: �T���v���ԂŐU�����������AU �����T���v�����ꂽ���́ATS �� T ���
% �������̓_�����܂݂܂��B�T���v�� T �ł̂݉����𓾂�ɂ́AYS(1:d:end,:)
% �Ƃ��܂��B�����ŁAd = round(length(TS)/length(T)) �ł��B
%
% ��ԋ�ԃ��f���ɑ΂��āA
% 
%   [YS,TS,XS] = LSIM(SYS,U,T,...)
% 
% �́ALENGTH(TS) ���s���A��Ԑ���񐔂Ƃ����Ԃ̋O�Ղ�\���s�� XS ��
% �o�͂��܂��B
% 
% �A���n�ɑ΂��ẮA
% 
%   LSIM(SYS,U,T,X0,'zoh')  �܂���  LSIM(SYS,U,T,X0,'foh') 
% 
% �́A���͒l�̃T���v���Ԃł̓��}�@�𖾎��I�ɐݒ肵�܂��B�f�t�H���g�ł́A
% LSIM �͐M�� U �̕��������x�[�X�Ɏ����I�ɓ��}�@���I�����܂��B
%
% �Q�l : GENSIG, STEP, IMPULSE, INITIAL, LTIMODELS


%	J.N. Little 4-21-85
%	Revised 7-31-90  Clay M. Thompson
%       Revised A.C.W.Grace 8-27-89 (added first order hold)
%	                    1-21-91 (test to see whether to use foh or zoh)
%	Revised 12-5-95 Andy Potvin
%       Revised 5-8-96  P. Gahinet
%       Revised 6-16-00 A. DiVergilio
%	Copyright 1986-2002 The MathWorks, Inc. 

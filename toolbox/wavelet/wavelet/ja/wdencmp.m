% WDENCMP �@�E�F�[�u���b�g���g�����G�������܂��͈��k
% WDENCMP �́A�E�F�[�u���b�g���g���āA�M���܂��̓C���[�W�̎G�������܂��͈��k����
% ���s���܂��B
%
% [XC,CXC,LXC,PERF0,PERFL2] = WDENCMP('gbl',X,'wname',N,THR,SORH,KEEPAPP) �́A�O
% ���[�o���Ȑ��̃X���b�V���z�[���h�l THR ���g���āA�X���b�V���z�[���h���������E
% �F�[�u���b�g�W���ɂ�蓾��ꂽ���͐M��X(1�����܂���2����)�̎G�������܂��͈��k
% ���ꂽ�o�[�W���� XC ���o�͂��܂��B�t���I�ȏo�͈��� [CXC,LXC] �́AXC �̃E�F�[�u
% ���b�g�����\���ł��BPERFO �� PERFL2 �́AL^2 �񕜂∳�k�X�R�A�� % �ŕ\��������
% �̂ł��B[C,L] ���AX �̃E�F�[�u���b�g�����\�����`���Ă���ꍇ�APERFL2 = ...
% 100*(CXC �̃x�N�g���m����/C �̃x�N�g���m����)^2 ���������܂��B
% �E�F�[�u���b�g�����́A���x�� N �Ŏ��s����A'wname' �́A�E�F�[�u���b�g�����܂�
% ������ł��B�܂��ASORH ('s' �܂��� 'h') �́A�\�t�g�X���b�V���z�[���h���A�n�[�h
% �X���b�V���z�[���h���s�����̂ł�(�ڍׂ́AWTHRESH ���Q��)�BKEEPAPP = 1 �̏ꍇ�A
% Approximation �W���ɂ̓X���b�V���z�[���h���K�p���ꂸ�A���̏ꍇ�͓K�p����܂��B
%
% WDENCMP('gbl',C,L,W,N,THR,SORH,KEEPAPP) �́A��q�̂��̂Ɠ����I�v�V�������g���āA
% �����o�͈������o�͂��܂��B�������A�E�F�[�u���b�g 'wname' ���g���āA���x�� N ��
% �G�������܂��͈��k���ꂽ�M���̓��̓E�F�[�u���b�g�����\�� [C,L] ���璼�ړ��邱
% �Ƃ��ł��܂��B
%
% 1�����ŁA'lvd' �I�v�V�����̏ꍇ�F
% WDENCMP('lvd',X�A'wname',N,THR,SORH)�A�܂��́AWDENCMP('lvd',C,L�A'wname',...
% N,THR,SORH) �́A��q�̃I�v�V�������g���āA�����o�͈������o�͂��܂����A�x�N�g��
% THR �Ɋ܂܂�郌�x���Ɉˑ������X���b�V���z�[���h��p���邱�Ƃ��ł��܂�(THR ��
% ������ N �ł�)�B�܂��AApproximation �ɂ͓K�p����܂���B
%
% 2�����ŁA'lvd' �I�v�V�����̏ꍇ:
% WDENCMP('lvd',X�A'wname',N,THR,SORH)�A�܂��́AWDENCMP('lvd',C,L�A'wname',...
% N,THR,SORH) �́ATHR �́A3�����A�����A�Ίp�A�����Ɋւ��郌�x���Ɉˑ�����X���b
% �V���z�[���h�l���܂�3�s N ��̍s��ł��B
%
% �Q�l�F DDENCMP, WAVEDEC, WAVEDEC2, WDEN, WPDENCMP, WTHRESH.



%   Copyright 1995-2002 The MathWorks, Inc.

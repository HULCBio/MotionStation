% WPDENCMP �@�E�F�[�u���b�g�p�P�b�g��p�����G�������܂��͈��k
% [XD,TREED,DATAD,PERF0,PERFL2] = WPDENCMP(X,SORH,N,'wname',CRIT,PAR,KEEPAPP) �́A
% �E�F�[�u���b�g�p�P�b�g�W���̃X���b�V���z�[���h��@�ɂ�蓾������͐M�� X (1
% �����܂���2����)�̎G�������������̂��܂��͈��k�������̂��o�͂��܂��B
% �t���I�ȏo�͈��� [TREED,DATAD] �́AXD �̃E�F�[�u���b�g�p�P�b�g�̍œK�����\����
% ���B����APERFL2 �y�� PERF0 �́AL^2 �񕜂ƈ��k�X�R�A��%�\���Ŏ��������̂ł��B
% PERFL2 = 100*(XD �� WP-cfs �̃x�N�g���m����)^2 /(X �� WP-cfs �̃x�N�g���m����)
% ^2
% SORH ('s' �܂��� 'h') �́A�\�t�g�X���b�V���z�[���h�܂��̓n�[�h�X���b�V���z�[��
% �h(�ڍׂ� WTHRESH ���Q��)�̂����ꂩ�ł��B
% 
% �E�F�[�u���b�g�p�P�b�g�����́A���x�� N �ōs���A'wname' �́A�E�F�[�u���b�g��
% ������������ł��B�œK�����́A������ CRIT �ƃp�����[�^ PAR(�ڍׂ́AWENTROPY �Q
% ��)�ɂ��ݒ肳���G���g���s�[�K�͂��g���Ď�������܂��B�X���b�V���z�[���h�p
% �����[�^�� PAR �ł��BKEEPAPP = 1 �̏ꍇ�AApproximation �W���ɂ̓X���b�V���z�[
% ���h���K�p�ł����A���̏ꍇ�A�X���b�V���z�[���h���K�p�\�ƂȂ�܂��B
%
% [XD,TREED,DATAD,PERF0,PERFL2]  = WPDENCMP(TREE,DATA,SORH,CRIT,PAR,KEEPAPP) �́A
% ��q�̂��̂Ɠ����I�v�V�������g���ē����o�͈������o�͂��܂����A�G�������܂��͈�
% �k�����M���̓��̓E�F�[�u���b�g�p�P�b�g�����\�� [TREE,DATA] ����o�͂����ړ�
% ���܂��B�����āACRIT = 'nobest' �̏ꍇ�A�œK���͓K�p���ꂸ�A�J�����g�̕�����
% �X���b�V���z�[���h���K�p����܂��B
%
% �Q�l�F DDENCMP, WDENCMP, WENTROPY, WPDEC, WPDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.

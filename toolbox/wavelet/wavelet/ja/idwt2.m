% IDWT2  �@�P�ꃌ�x���̋t���U2�����E�F�[�u���b�g�ϊ�
% IDWT2 �́A('wname',WFILTERS ���Q��)�Ŏw�肳�ꂽ����̃E�F�[�u���b�g�܂��͎w��
% ���ꂽ����̃E�F�[�u���b�g�č\���t�B���^(Lo_R �� Hi_R)�̂����ꂩ�Ɋ֘A�����P��
% ���x����2�����E�F�[�u���b�g�č\�����s���܂��B
%
% X = IDWT2(CA,CH,CV,CD,'wname') �́A�E�F�[�u���b�g 'wname' ���g���āAApproxim-
% ation �W���x�N�g�� CA �� Detail �s�� CH, CV, CD(�����A�����A�Ίp)���x�[�X�ɁA
% �P�ꃌ�x���̍č\�� Approximation �W���s�� X ���v�Z���܂��B
%
% X = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R) �́A�ݒ肵���t�B���^���g���ď�q�̏������s��
% �܂��B
%   Lo_R �́A�č\�����[�p�X�t�B���^�ł��B
%   Hi_R �́A�č\���n�C�p�X�t�B���^�ł��B
%   Lo_R �� Hi_R �́A���������łȂ���΂Ȃ�܂���B
%
% SA = size(CA) = size(CH) = size(CV) = size(CD) �ŁALF ���t�B���^�̒����̏ꍇ�A
% size(X) = SX  ���������܂��B�����ŁADWT �g�����[�h�������I�ȃ��[�h�ł���ꍇ�A
% SX = 2*SA �ł��B���̑��̊g�����[�h�̏ꍇ�ASX = 2*SA-LF+2 �ł��B
%
% X = IDWT2(CA,CH,CV,CD,'wname',S)�A�܂��́AX = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R,S) 
% �́AIDWT2(CA,CH,CV,CD,'wname') ���g���ē����錋�ʂ̒��S���̃T�C�Y S �̕�����
% �o�͂��܂��BS �́ASX �����������Ȃ���΂Ȃ�܂���B
%
% X = IDWT2(CA,CH,CV,CD,'wname','mode',mode) 
% X = IDWT2CA,CH,CV,CD,Lo_R,Hi_R,'mode',mode) 
% X = IDWT2(CA,CH,CV,CD,'wname',L,'mode',mode) 
% X = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R,L,'mode',mode) �̂�������A�w��\�Ȋg�����[
% �h�ŁA�E�F�[�u���b�g�č\���̌W�����v�Z���܂��B
%
% X = IDWT2(CA,[],[],[]�A... ) �́AApproximation �W���s�� CA ���x�[�X�ɁA�P�ꃌ
% �x���ɍč\�����ꂽ Approximation �W���s�� X ���o�͂��܂��B
%
% X = IDWT2([],CH,[],[]�A... ) �́A������ Detail �W���s�� CH ���x�[�X�ɁA�P�ꃌ
% �x���ɍč\�����ꂽ Detail �W���s�� X ���o�͂��܂��B
%
% X = IDWT2([],[],CV,[]�A... ) �� X = IDWT2([],[],[],CD�A... )�́A�������ʂ��o��
% ���܂��B
% 
% �Q�l�F DWT2, DWTMODE, UPWLEV2.



%   Copyright 1995-2002 The MathWorks, Inc.

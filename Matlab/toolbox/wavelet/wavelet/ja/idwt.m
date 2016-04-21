% IDWT �@�@�P�ꃌ�x���̋t���U1�����E�F�[�u���b�g�ϊ�
% IDWT�́A('wname',WFILTERS ���Q��)�Ŏw�肳�ꂽ����̃E�F�[�u���b�g�܂��͎w�肳
% �ꂽ����̃E�F�[�u���b�g�č\���t�B���^(Lo_R �� Hi_R)�̂����ꂩ�Ɋ֘A�����P�ꃌ
% �x����1�����E�F�[�u���b�g�č\�����s���܂��B
%
% X = IDWT(CA,CD,'wname') �́A�E�F�[�u���b�g 'wname' ���g���āAApproximation �W
% ���x�N�g�� CA �� Detail �W���x�N�g�� CD ���x�[�X�ɁA�P�ꃌ�x���̍č\�� Appro-
% ximation �W���x�N�g�� X ���v�Z���܂��B
%
% X = IDWT(CA,CD,Lo_R,Hi_R) �́A�ݒ肵���t�B���^���g���ď�q�̏������s���܂��B
%   Lo_R �́A�č\�����[�p�X�t�B���^�ł��B
%   Hi_R �́A�č\���n�C�p�X�t�B���^�ł��B
%   Lo_R �� Hi_R �́A���������łȂ���΂Ȃ�܂���B
%
% LA = length(CA) = length(CD) �ŁALF ���t�B���^���̏ꍇ�Alength(X) = LX �ƂȂ�A
% DWT �̊g�����[�h�������I�ȃ��[�h�ł���ꍇ�� LX = 2*LA �ł��B���̊g�����[�h��
% �́ALX = 2*LA-LF+2 �ɂȂ�܂��B�قȂ�M���g�����[�h�ɂ��ẮADWTMODE ���Q��
% ���Ă��������B
%
% X = IDWT(CA,CD,'wname',L)�A�܂��́AX = IDWT(CA,CD,Lo_R,Hi_R,L) �́AIDWT(...
% CA,CD,'wname') ���g���ē����錋�ʂ̒��S������ L �̒������o�͂��܂��BL �́ALX
% �����������Ȃ���΂Ȃ�܂���B
%
% X = IDWT(CA,CD,'wname','mode',mode) 
% X = IDWT(CA,CD,Lo_R,Hi_R,'mode',mode) 
% X = IDWT(CA,CD,'wname',L,'mode',mode) 
% X = IDWT(CA,CD,Lo_R,Hi_R,L,'mode',mode) 
% �̂�������A�w��\�Ȋg�����[�h�ŁA�E�F�[�u���b�g�č\���̌W�����v�Z���܂��B
%
% X = IDWT(CA,[]�A... ) �́AApproximation �W���x�N�g�� CA ���x�[�X�ɒP�ꃌ�x����
% �č\�����ꂽ Approximation �W���x�N�g�� X ���o�͂��܂��B
%
% X = IDWT([],CD�A... ) �́ADetail �W���x�N�g�� CD ���x�[�X�ɒP�ꃌ�x���̍č\��
% ���ꂽ Detail �W���x�N�g�� X ���o�͂��܂�
% 
% �Q�l�F DWT, DWTMODE, UPWLEV.



%   Copyright 1995-2002 The MathWorks, Inc.

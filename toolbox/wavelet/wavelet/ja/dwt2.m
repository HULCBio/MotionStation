% DWT2 �@�P�ꃌ�x���̗��U2�����E�F�[�u���b�g�ϊ�
% DWT2�́A�w�肳�ꂽ����̃E�F�[�u���b�g('wname',WFILTERS ���Q��)�܂��͎w�肳��
% ������̃E�F�[�u���b�g�t�B���^(Lo_D �� Hi_D)�̂����ꂩ�ɑΉ�����P�ꃌ�x���ł�
% 2�����E�F�[�u���b�g�������o�͂��܂��B
%
% [CA,CH,CV,CD] = DWT2(X,'wname') �́A���͍s�� X �̃E�F�[�u���b�g�����œ���ꂽ 
% Approximation �W���s�� CA �� Detail �W���s�� CH,CV,CD ���v�Z���܂��B'wname' �́A
% �E�F�[�u���b�g�����܂ޕ�����ł��B
%
% [CA,CH,CV,CD] = DWT2(X,Lo_D,Hi_D) �́A���͂Ƃ��Ă��̃t�B���^��^���A��q��2
% �����E�F�[�u���b�g�������v�Z���܂��B
%   Lo_D �́A�������[�p�X�t�B���^�ł��B
%   Hi_D �́A�����n�C�p�X�t�B���^�ł��B
%   Lo_D �� Hi_D �́A���������łȂ���΂Ȃ�܂���B
%
% SX = size(X) �ŁALF ���t�B���^���ł���ꍇ�Asize(CA) = size(CH) = size(CV) = 
% size(CD) = SA �ɂȂ�܂��B�����ŁADWT �g�����[�h�������I�ȃ��[�h�ł������ꍇ�A
% SA = CEIL(SX/2) �ł��B����ȊO�̊g�����[�h�̏ꍇ�ASA = FLOOR((SX+LF-1)/2) �ɂ�
% ��܂��B�قȂ�M���g�����[�h�ɂ��ẮADWTMODE ���Q�Ƃ��Ă��������B
%
% [CA,CH,CV,CD] = DWT2(X,'wname','mode',mode)�A�܂��́A[CA,CH,CV,CD] = DWT2...
% (X,Lo_D,Hi_D,'mode',mode) �́A�w��\�Ȋg�����[�h�ŁA�E�F�[�u���b�g�������v�Z
% �ł��܂��B
%
% �Q�l�F DWTMODE, IDWT2, WAVEDEC2, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.

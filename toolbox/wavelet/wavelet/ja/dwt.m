% DWT�@ �P�ꃌ�x���̗��U1�����E�F�[�u���b�g�ϊ�
% DWT �́A�w�肳�ꂽ����̃E�F�[�u���b�g('wname',WFILTERS ���Q��)�A�܂��́A�w��
% ���ꂽ����̃E�F�[�u���b�g�t�B���^(Lo_D �� Hi_D)�̂����ꂩ�ɑΉ�����P�ꃌ�x��
% �ł�1�����E�F�[�u���b�g�������o�͂��܂��B
%
% [CA,CD] = DWT(X,'wname') �́A�x�N�g�� X �̃E�F�[�u���b�g�����œ���ꂽ Appro-
% ximation �W���x�N�g�� CA �� Detail �W���x�N�g�� CD ���v�Z���܂��B'wname' �́A
% �E�F�[�u���b�g�����܂ޕ�����ł��B
%
% [CA,CD] = DWT(X,Lo_D,Hi_D) �́A���͂Ƃ��āA���̃t�B���^��^���A��q�̃E�F�[
% �u���b�g�������v�Z���܂��B
%   Lo_D �́A�������[�p�X�t�B���^�ł��B
%   Hi_D �́A�����n�C�p�X�t�B���^�ł��B
%   Lo_D �� Hi_D �́A���������łȂ���΂Ȃ�܂���B
%
% LX = length(X) �� LF ���t�B���^���ł���ꍇ�́Alength(CA) = length(CD) = LA ��
% �Ȃ�܂��B�����ŁADWT �̊g�����[�h�������I�ȃ��[�h�ł���ꍇ�ALA = CEIL(LX/2) 
% �ł��B���̊g�����[�h�ł� �ALA = FLOOR((LX+LF-1)/2) �ɂȂ�܂��B�قȂ�M���g��
% ���[�h�ɂ��ẮADWTMODE ���Q�Ƃ��Ă��������B
%
% [CA,CD] = DWT(X,'wname','mode',mode) �܂���
% [CA,CD] = DWT(X,Lo_D,Hi_D,'mode',mode) �́A�w��\�Ȋg�����[�h�ŁA�E�F�[�u��
% �b�g�̕������v�Z���܂��B
%
% �Q�l�F DWTMODE, IDWT, WAVEDEC, WAVEINFO



%   Copyright 1995-2002 The MathWorks, Inc.

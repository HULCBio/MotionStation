% REG   ��ԃt�B�[�h�o�b�N�Ɛ����Q�C���ɂ�郌�M�����[�^�̐݌v
%
% RSYS = REG(SYS,K,L) �́A��ԋ�ԃV�X�e�� SYS �ɑ΂���I�u�U�[�o�Ɋ�Â�
% ���M�����[�^ RSYS ���쐬���܂��B���̂Ƃ��ASYS �̂��ׂĂ̓��͂́A����
% ���͂ŁA���ׂĂ̏o�͂͊ϑ�����Ă���Ɖ��肵�܂��B�s�� K �� L �́A���
% �t�B�[�h�o�b�N�Q�C���ƃI�u�U�[�o�Q�C�����w�肵�Ă��܂��B
%           .
%    SYS:   x = Ax + Bu ,   y = Cx + Du 
%
% �ɑ΂��āA���ʂ̃��M�����[�^�́A
%     .
%    x_e = [A-BK-LC+LDK] x_e + Ly
%      u = -K x_e  
%
% �ƂȂ�܂��B���̃��M�����[�^�́A���̃t�B�[�h�o�b�N��p���āA�v�����g��
% �ڑ�����Ȃ���΂����܂���BREG �́A���U���ԃV�X�e���ł����l�ɓ����܂��B
%
% RSYS = REG(SYS,K,L,SENSORS,KNOWN,CONTROLS) �́A����ʓI�ȃ��M�����[�^
% ���������܂��B�����ŁA
%  * �v�����g���͂́A������� u �A���m���� Ud �A�m���I���� �� ����\��
%    ���܂��B
%  * �v�����g�o�͂̃T�u�Z�b�g y �݂̂����肳��܂��B
%  
% I/O �̃T�u�Z�b�g y, Ud, u �́A�C���f�b�N�X�x�N�g�� SENSORS, KNOWN, 
% CONTROLS �Ŏw�肵�܂��B���ʂ̃��M�����[�^ RSYS �́A�w�ߒl u �𐶐�����
% ���߂̓��͂Ƃ��āA[Ud;y] �𗘗p���܂��B 
%
% �Q�C�� K �� L �����߂邽�߂ɋɔz�u�̎�@( PLACE �Q��)��p���邱�Ƃ�
% �ł��A�܂��́ALQR/DLQR �� KALMAN �ŋ��߂� LQ �Q�C���� Kalman �Q�C����
% ���p�ł��܂��B
%
% �Q�l : PLACE, LQR, DLQR, LQGREG, ESTIM, KALMAN, SS.


%   Clay M. Thompson 6-29-90
%   Revised: P. Gahinet  7-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 

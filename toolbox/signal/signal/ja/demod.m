% DEMOD �ʐM�V�~�����[�V�����̂��߂̕���
%
% X = DEMOD(Y,Fc,Fs,METHOD,OPT)�́A�����g�̎��g��Fc�A�T���v�����O���g��
% Fs���������g�M��Y���A���Ɏ���METHOD�̃I�v�V�����̂����ꂩ1��
% �g���ĕ������܂��BOPT �́A�I�v�V�����ŁA���[�U���I�����镜�����@
% �Ɉ˂�A�K�v�ɂȂ�܂��B
%
% METHOD            �������@�̊T�v
%
% 'am',      �U�������A�����g�сA�}�������g�B
% 'amdsb-sc' OPT �͐ݒ�ł��܂���B
% 'amdsb-tc' �U�������A�����g�сA�`�������g�BOPT��ݒ肵���ꍇ�A
%            �������ꂽ�M��X����X�J��OPT�l�������܂��BOPT��
%            �f�t�H���g�l��0�ł��B
% 'amssb'    �U�������A�Б��g�сB
%            OPT �͐ݒ�ł��܂���B
% 'fm'       ���g������
%            OPT��ݒ肵���ꍇ�A���̎��g������(kf)�Ŏ��s����܂��B
%            OPT�̃f�t�H���g�l��1�ł��B
% 'pm'       �ʑ�����
%            OPT��ݒ肵���ꍇ�A���̈ʑ�����(kp)�Ŏ��s����܂��B
%            OPT�̃f�t�H���g�l��1�ł��B
% 'pwm'      �p���X������
%            OPT�� 'centered'�ɐݒ肷��ƁA���[�ɗ����オ���Ă���p���X
%            �͊e�����g�����̒��S�ɐݒ肳��܂��B
% 'ppm'      �p���X�ʒu����
%            OPT �͐ݒ�ł��܂���B
% 'qam'      ����U�������B
%            QAM �M���ɑ΂��āA�ȉ��̃X�e�[�g�����g���g���܂��B
%          �@�@�@[X1,X2] = DEMOD(Y,Fc,Fs,'qam')
%
% Y���s��̏ꍇ�Ademod�́A���̊e��𕜒����܂��B
%
% �Q�l�F   MODULATE



%   Copyright 1988-2002 The MathWorks, Inc.

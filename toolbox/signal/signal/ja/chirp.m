% CHIRP  ���ԂƋ��ɕω�������g�������R�T�C���g������
%
% Y = CHIRP(T,F0,T1,F1)�́A�z��T�ɒ�`���ꂽ���ԂŁA���`�ɕω�������g��
% �R�T�C���M���𐶐����܂��B�����ŁAF0�͎��� 0�ł̏u�Ԏ��g���ł���AF1��
% ���� T1�ł̏u�Ԏ��g���ł��BF0��F1�͋���Hz�P�ʂł��B�f�t�H���g�́AF0�� 
% 0�AT1��1�AF1��100�ƂȂ�܂��B
%
% Y = CHIRP(T,F0,T1,F1,method)�́A���ԂƎ��g���̊֌W�������I�v�V�������
% �肵�܂��B�����ŁAmethod�ɂ́A���̕�����A'linear','quadratic','lo-
% garithmic'��ݒ肷�邱�Ƃ��ł��A�f�t�H���g�� 'linear'�ł��B'logarith-
% mic'�ł́AF1��F0���傫���Ȃ���΂Ȃ�܂���B
%
% Y = CHIRP(T,F0,T1,F1,'method', PHI)�́A�����ʑ� PHI���p�x�P�ʂŐݒ肷
% �邱�Ƃ��ł��܂��B�f�t�H���g�ł́APHI��0�ł��B
%
% Y = CHIRP(T,FO,T1,F1,'quadratic',PHI,'concave')  �́A2���̑|�����g��
% �����M���𐶐����܂��B���̃X�y�N�g���O�����́A���̎��g�����ɑ΂���
% ���ł���������ł��B
%
% Y = CHIRP(T,FO,T1,F1,'quadratic',PHI,'convex') �́A2���̑|�����g��
% �����M���𐶐����܂��B���̃X�y�N�g���O�����́A���̎��g�����ɑ΂���
% �ʂł���������ł��B
%
% ���͈������󂩂��邢�͏ȗ�����Ă���ꍇ�A�f�t�H���g�l���g���܂��B
%
% ��� 1: ���`Chirp�̃X�y�N�g���O�������v�Z���܂��B
%   t = 0:0.001:2;                 % 1 kHz�̃T���v�����O���[�g�ŁA2�b�܂�
%   y = chirp(t,0,1,150);          % DC����n�܂�At = 1�b��150 Hz
%   specgram(y,256,1E3,256,250);   % �X�y�N�g���O������\��
%
% ��� 2: 2��Chirp�̃X�y�N�g���O�������v�Z���܂��B
%   t = -2:0.001:2;                % 1 kHz�̃T���v�����O���[�g�ŁA�}2�b��
%   y = chirp(t,100,1,200,'q');    % 100 Hz����n�܂�At = 1�b��200 Hz
%   specgram(y,128,1E3,128,120);   % �X�y�N�g���O������\��
%
% ��� 3: "��" 2��Chirp�̃X�y�N�g���O�����̌v�Z
%     t= 0:0.001:1;                % 1kHz �T���v�����O���[�g�ŁA1�b
%     fo=25;f1=100;                % 25Hz����n�܂�A100Hz�܂ő���
%     y=chirp(t,fo,1,f1,'q',[],'convex');
%     specgram(y,256,1000)         % �X�y�N�g���O������\��
%
% ��� 4: "��" 2��Chirp�̃X�y�N�g���O�����̌v�Z
%     t= 0:0.001:1;                % 1kHz �T���v�����O���[�g�ŁA1�b
%     fo=100;f1=25;                % 100Hz����n�܂�A25Hz�܂Ō���
%     y=chirp(t,fo,1,f1,'q',[],'concave');
%     specgram(y,256,1000)         % �X�y�N�g���O������\��
%
% �Q�l�F   GAUSPULS, SAWTOOTH, SINC, SQUARE.



%   Copyright 1988-2002 The MathWorks, Inc.

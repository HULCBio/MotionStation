% MESHGRID   3�����v���b�g�̂��߂̔z��X��Y
% 
% [X,Y] = MESHGRID(x,y)�́A�x�N�g��x��y�Ŏw�肳�ꂽ�̈���A�z��X��Y�ɕ�
% �����܂��B����́A2�ϐ��A3�����̃T�[�t�F�X�v���b�g�֐��̕]���Ɏg����
% ���B�o�͔z��X�̍s�̓x�N�g��x�̃R�s�[�ŁA�o�͔z��Y�̗�̓x�N�g��y��
% �R�s�[�ł��B
%
% [X,Y] = MESHGRID(x)�́A[X,Y] = MESHGRID(x,x)�̏ȗ��`�ł��B
% [X,Y,Z] = MESHGRID(x,y,z)�́A3�ϐ��A3�����̑̐σv���b�g�֐��̕]����
% �g����3�����z����쐬���܂��B
%
% ���Ƃ��΁A-2 < x < 2�A -2 < y < 2�̗̈�Ŋ֐�x*exp(-x^2-y^2)�����s����
% ���߂ɂ́A���̂悤�ɂ��܂��B
%
%     [X,Y] = meshgrid(-2:.2:2�A-2:.2:2);
%     Z = X .* exp(-X.^2 - Y.^2);
%     mesh(Z)
%
% MESHGRID�́A�ŏ���2�̓��͈����Əo�͈����̏���������ւ���Ă��邱��
% �������΁ANDGRID�Ɠ����ł�(���Ƃ��΁A[X,Y,Z] = MESHGRID(x,y,z)�́A[Y,
% X,Z] = NDGRID(y,x,z)�Ɠ������ʂ��o�͂��܂�)�B���̂��߁AMESHGRID�́A
% cartesian��Ԃł̖��ɓK���Ă��āANDGRID�͋�ԂƉ]������N��������
% �΂��ēK���Ă��邱�Ƃ��킩��܂��BMESHGRID�́A2�����܂���3�����Ɍ����
% �܂��B
%
% ���� x, y, z �ɑ΂���N���X�T�|�[�g:
%   float: double, single
%
% �Q�l SURF, SLICE, NDGRID.

%   J.N. Little 1-30-92, CBM 2-11-92.
%   Copyright 1984-2004 The MathWorks, Inc. 

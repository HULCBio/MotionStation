% TETRAMESH �l�ʑ̃��b�V���v���b�g
%
% TETRAMESH(T,X,C) �́A���b�V���Ƃ��āAM �s4��̍s�� T �ɒ�`����Ă���
% �l�ʑ̂�\�����܂��BT �́ADELAUNAYN �̏o�͂ł��BT �̍s�́A�l�ʑ̂�
% ���_�� X �̒��̃C���f�b�N�X���܂񂾂��̂ł��BX �́AN �s3��̍s��ŁA
% 3�����I�� N �_��\�킵�Ă��܂��B�l�ʑ̂̃J���[�́A�x�N�g�� C �Œ�`
% �ł��A�J�����g�̃J���[�̒��̃C���f�b�N�X�Ƃ��Ďg���܂��B
%
% TETRAMESH(T,X) �́Am �̎l�ʑ̂ɑ΂���J���[�Ƃ��� C=1:m ���g���܂��B
% �e�l�ʑ̂́A�قȂ�J���[���g���܂��B
%
% H = TETRAMESH(...) �́A�l�ʑ̂̃n���h����\�킷�x�N�g���ł��BH �̊e�v�f�́A
% 1�̎l�ʑ̂��쐬����p�b�`�̑g�̃n���h���ł��B�����̃n���h�����g���āA
% 'visible' �v���p�e�B��'on'�A�܂��́A'off' ���`���[�j���O���邱�ƂŁA
% ����̎l�ʑ̂����邱�Ƃ��ł��܂��B
%
% TETRAMESH(...,'param','value','param','value'...) �́A�l�ʑ̂�\������
% �Ƃ��Ɏg�p����t���I�ȃp�b�`�̃p�����[�^��/�l�̑g��ݒ肵�܂��B���Ƃ��΁A
% �f�t�H���g�̓����x�p�����[�^�́A0.9�ɐݒ肳��Ă��܂��B���̒l���p�����[�^
% ���ƒl('FaceAlpha', value)���g���āA���������܂��B���̒l�́A0��1�̊Ԃ̐�
% �łȂ���΂Ȃ�܂���B
%
% ���F
%
%   d = [-1 1];
%   [x,y,z] = meshgrid(d,d,d);  % �L���[�u
%   x = [x(:);0];
%   y = [y(:);0];
%   z = [z(:);0];    % [x,y,z] �́A���S���������L���[�u�̃R�[�i
%   Tes = delaunay3(x,y,z)
%   X = [x(:) y(:) z(:)];
%   tetramesh(Tes,X);camorbit(20,0)
%
% �Q�l�FTRIMESH, TRISURF, PATCH, DELAUNAYN.


%   Copyright 1984-2002 The MathWorks, Inc. 

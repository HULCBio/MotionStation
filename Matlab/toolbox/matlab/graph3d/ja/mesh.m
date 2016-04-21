% MESH   3�������b�V���T�[�t�F�X
% 
% MESH(X,Y,Z,C) �́A4�̍s������Œ�`���ꂽ�F�t�����ꂽ�p�����g���b�N
% ���b�V�����v���b�g���܂��B���_�́AVIEW �Ŏw�肳��܂��B���̃��x���́A
% X�AY�AZ �͈̔͂�AAXIS �̃J�����g�̐ݒ�ɂ���Č��肳��܂��B�J���[��
% �X�P�[�����O�́AC�͈̔͂܂��� CAXIS �̃J�����g�̐ݒ�ɂ���Č��肳��
% �܂��B�X�P�[�����O���ꂽ�J���[�l�́A�J�����g�� COLORMAP �̃C���f�b�N�X
% �Ƃ��Ďg�p����܂��B
%
% MESH(X,Y,Z) �� C = Z ���g�p����̂ŁA�J���[�̓��b�V���̍����ɔ�Ⴕ�܂��B
%
% MESH(x,y,Z) �� MESH(x,y,Z,C) �́A�ŏ���2�̈������s�񂩂�x�N�g����
% �u�������A[m,n] = size(Z) �̂Ƃ��Alength(x) = n ���� length(y) = m ��
% �Ȃ���΂Ȃ�܂���B���̏ꍇ�A���b�V�����C���̒��_�́A(x(j)�Ay(i)�AZ(i,j))
% ��3�v�f�ł��B
% x �� Z �̗�ɑΉ����Ay �͍s�ɑΉ����邱�Ƃɒ��ӂ��Ă��������B
% 
% MESH(Z) �� MESH(Z,C) �́Ax = 1:n �� y = 1:m ���g���܂��B���̏ꍇ�A����
% Z �͈ꉿ�֐��ŁA�􉽊w�I�Ȓ����`�O���b�h�ɑ΂��Ē�`����܂��B
%
% MESH(...,'PropertyName',PropertyValue,...) �́A�w�肵���T�[�t�F�X
% �v���p�e�B�̒l��ݒ肵�܂��B�����̃v���p�e�B�l��1�̃X�e�[�g�����g
% �Őݒ�ł��܂��B
%
% MESH(AX,...) �́AGCA �ł͂Ȃ� AX �Ƀv���b�g���܂��B
%
% MESH SURFACE�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��B
%
% AXIS�ACAXIS�ACOLORMAP�AHOLD�ASHADING�AHIDDEN�AVIEW�́A���b�V����
% �\���ɉe����^����figure�Aaxes�Asurface�̃v���p�e�B��ݒ肵�܂��B
%
% ���ʌ݊���
% MESH('v6',...) �́AMATLAB 6.5 ����� �ȑO�� MATLAB �Ƃ̌݊�����
% ���߂ɁAsurface plot �I�u�W�F�N�g�ł͂Ȃ��Asurface �I�u�W�F�N�g
% ���쐬���܂��B
% 
% �Q�l�FSURF, MESHC, MESHZ, WATERFALL.

%-------------------------------
% �ڍגǉ�:
%
% MESH �́A�w�i�F�� FaceColor �v���p�e�B��ݒ肵�AEdgeColor �v���p�e�B��
% 'flat' �ɐݒ肵�܂��B
%
% NextPlot axis �v���p�e�B �� REPLACE (HOLD �� off) �̏ꍇ�AMESH �́A
% Position ���������ׂĂ� axis �v���p�e�B���f�t�H���g�l�Ƀ��Z�b�g���A
% ���ׂĂ� axis children (line, patch, surf, image, ����сAtext 
% �I�u�W�F�N�g) ���폜���܂��B

% Copyright 1984-2004 The MathWorks, Inc. 

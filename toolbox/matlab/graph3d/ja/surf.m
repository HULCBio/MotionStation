% SURF   3�����J���[�T�[�t�F�X
% 
% SURF(X,Y,Z,C) �́A4�̍s������Œ�`���ꂽ�F�t�����ꂽ�p�����g���b�N
% �T�[�t�F�X���v���b�g���܂��B���_�́AVIEW �Ŏw�肳��܂��B���̃��x���́A
% X�AY�AZ �͈̔͂�AAXIS �̃J�����g�̐ݒ�ɂ���Č��肳��܂��B�J���[��
% �X�P�[�����O�́AC �͈̔͂܂��� CAXIS �̃J�����g�̐ݒ�ɂ���Č��肳��
% �܂��B�X�P�[�����O���ꂽ�J���[�l�́A�J�����g�� COLORMAP �̃C���f�b�N�X
% �Ƃ��Ďg�p����܂��B�V�F�[�f�B���O���f���́ASHADING �ɂ��ݒ肳��܂��B
%
% SURF(X,Y,Z)�� C = Z ���g�p����̂ŁA�J���[�̓T�[�t�F�X�̍����ɔ��
% ���܂��B
%
% �ŏ���2�̈������s�񂩂�x�N�g���ɒu��������ꂽ SURF(x,y,Z) ��
% SURF(x,y,Z,C) �́A[m,n] = size(Z) �̂Ƃ��Alength(x) = n ���� 
% length(y) = m �łȂ���΂Ȃ�܂���B���̏ꍇ�A�T�[�t�F�X�̃p�b�`��
% ���_�́A(x(j)�Ay(i)�AZ(i,j)) ��3�v�f�ł��Bx �� Z �̗�ɑΉ����Ay ��
% �s�ɑΉ����邱�Ƃɒ��ӂ��Ă��������B
% 
% SURF(Z) �� SURF(Z,C) �́Ax = 1:n �� y = 1:m ���g���܂��B���̏ꍇ�A
% ���� Z �͈ꉿ�֐��ŁA�􉽊w�I�Ȓ����`�O���b�h�Œ�`����܂��B
%
% SURF(...,'PropertyName',PropertyValue,...) �́A�w�肵���T�[�t�F�X�v���p
% �e�B�̒l��ݒ肵�܂��B�����̃v���p�e�B�l��1�̃X�e�[�g�����g�Őݒ�ł�
% �܂��B
%
% SURF(AX,...) �́AGCA �ł͂Ȃ� AX �Ƀv���b�g���܂��B
%
% SURF �́ASURFACE�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��B
%
% AXIS�ACAXIS�ACOLORMAP�AHOLD�ASHADING�AVIEW �́A�T�[�t�F�X�̕\����
% �e����^����@figure�Aaxes�Asurface�̃v���p�e�B��ݒ肵�܂��B
%
% ���ʌ݊���
% SURF('v6',...) �́AMATLAB 6.5 ����� �ȑO�� MATLAB �Ƃ̌݊�����
% ���߂ɁAsurface plot �I�u�W�F�N�g�ł͂Ȃ��Asurface �I�u�W�F�N�g
% ���쐬���܂��B
%
% �Q�l�FSURFC, SURFL, MESH, SHADING.

%-------------------------------
% �ڍגǉ�:
%
% NextPlot axis �v���p�e�B �� REPLACE (HOLD �� off) �̏ꍇ�ASURF �́A
% Position ���������ׂĂ� axis �v���p�e�B���f�t�H���g�l�Ƀ��Z�b�g���A
% ���ׂĂ� axis children (line, patch, surf, image, ����сAtext 
% �I�u�W�F�N�g) ���폜���܂��B

% Copyright 1984-2002 The MathWorks, Inc. 

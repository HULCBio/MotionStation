%GRIDDATA3 3�����f�[�^�p�̃f�[�^�̃O���b�h���ƃn�C�p�[�T�[�t�F�X
%            �t�B�b�e�B���O
% W = GRIDDATAN(X, Y, Z, V, XI, YI, ZI) �́A��ԓI�ɕs�ώ��ɕ��z����
% �x�N�g�� (X, Y, Z, V) �̃f�[�^�� W = F(X,Y,Z) �̌^�̃n�C�p�[�T�[�t�F�X
% ���t�B�b�e�B���O�����܂��BGRIDDATA3 �́AW ���쐬���邽�߂ɁA(XI,YI,ZI) 
% �Ŏw�肳���_�ł��̃n�C�p�[�T�[�t�F�X���Ԃ��܂��B
%
% (XI,YI,ZI) �́A�ʏ�(�֐� MESHGRID �ō쐬����)��l���z�O���b�h�ŁA����
% ���� GRIDDATA3 �Ɩ��t�����Ă��܂��B
%
% [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD) �́AMETHOD ��
%    'linear'    - �ו������x�[�X�ɐ��`��� (�f�t�H���g)
%    'nearest'   - �ŋߖT���
%
% �̂����ꂩ�̂Ƃ��A�f�[�^�Ƀt�B�b�e�B���O������T�[�t�F�X�̃^�C�v��
% ��`���܂��B
% ���ׂĂ̕��@�́A�f�[�^�� Delaunay �O�p�`���x�[�X�ɂ��Ă��܂��B
% METHOD �� [] �̏ꍇ�A�f�t�H���g�� 'linear' ���\�b�h���g�p����܂��B
%
% [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD,OPTIONS) �́ADELAUNAYN �ɂ�� 
% Qhull �̃I�v�V�����Ƃ��Ďg�p�����悤�ɁA������ OPTIONS �̃Z���z���
% �w�肵�܂��B
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
%
% ���� X,Y,Z,V,XI,YI,ZI �̃T�|�[�g�N���X: double
%
% �Q�l GRIDDATA, GRIDDATAN, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2004 The MathWorks, Inc.

%GRIDDATA �f�[�^�̃O���b�h���ƃT�[�t�F�X�̓K��
% 
% ZI = GRIDDATA(X,Y,Z,XI,YI) �́A(�ʏ�)��l�Ԋu�łȂ��x�N�g�� (X,Y,Z) ��
% �f�[�^�ɁAZ = F(X,Y) �^�̃T�[�t�F�X��K�������܂��BGRIDDATA �́AZI ��
% �쐬���邽�߂ɁA(XI,YI) �Ŏw�肳���_�ł��̃T�[�t�F�X���Ԃ��܂��B
% �T�[�t�F�X�́A�K���f�[�^�_��ʂ�܂��BXI �� YI �́A�ʏ�(MESHGRID�ō쐬
% �����悤��)��l�Ԋu�̃O���b�h�ŁA���̂��߁AGRIDDATA �Ɩ��t������
% ���܂��B
%
% XI �́A�s�x�N�g���ł��\���܂���B���̏ꍇ�A��v�f�����̒l�ł���s���
% �l�����܂��B���l�ɁAYI �͗�x�N�g���ł��\�킸�A�s�v�f�����̒l�ł���
% �s��ƍl�����܂��B
%
% [XI,YI,ZI] = GRIDDATA(X,Y,Z,XI,YI) �́A���̕��@�ō쐬���ꂽ XI �� YI ��
% �o�͂��܂�([XI,YI] = MESHGRID(XI,YI) �̌���)�B
%
% [...] = GRIDDATA(X,Y,Z,XI,YI,METHOD) �́AMETHOD �����̂����̂����ꂩ
% �̂Ƃ��A�f�[�^�ɑ΂���T�[�t�F�X�̋ߎ��̃^�C�v���`���܂��B
% 
%     'linear'    - �O�p�`�x�[�X�̐��`���(�f�t�H���g)
%     'cubic'     - �O�p�`�x�[�X�̃L���[�r�b�N���
%     'nearest'   - �ŋߖT�_�ɂ����
%     'v4'        - MATLAB 4��griddata�̎�@
% 'cubic' �� 'v4' �́A���炩�ȃT�[�t�F�X���쐬���܂��B����A'linear' 
% �� 'nearest' �́A���ꂼ��A1�����֐���0�����֐��ɂ�����s�A����������
% �܂��B'v4' �ȊO�̂��ׂĂ̎�@�́A�f�[�^�� Delaunay �O�p�`�����Ɋ�Â���
% ���܂��B
% METHOD �� [] �̏ꍇ�A�f�t�H���g�� 'linear' ���\�b�h���g�p����܂��B
%
% [...] = GRIDDATA(X,Y,Z,XI,YI,METHOD,OPTIONS) �́ADELAUNAYN �ɂ�� Qhull 
% �̃I�v�V�����Ƃ��Ďg�p�����悤�ɁA������ OPTIONS �̃Z���z����w�肵�܂��B
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�� DELAUNAYN �I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
%
% �Q�l GRIDDATA3, GRIDDATAN, DELAUNAY, INTERP2, MESHGRID, DELAUNAYN.

%   Copyright 1984-2003 The MathWorks, Inc. 

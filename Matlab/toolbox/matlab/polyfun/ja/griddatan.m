%GRIDDATAN 3�����ȏ�̃f�[�^�ɑ΂���O���b�h���ƃn�C�p�[�T�[�t�F�X
%             �t�B�b�e�B���O
%
% YI = GRIDDATAN(X,Y,XI) �́A��ԓI�ɕs�ώ��ɕ��z����x�N�g�� (X, Y) ��
% �f�[�^�ɁAY = F(X) �̌^�̃n�C�p�[�T�[�t�F�X���t�B�b�e�B���O�����܂��B
% GRIDDATAN �́AZ ���쐬���邽�߂ɁAXI �Őݒ肳�ꂽ�_�ł��̃n�C�p�[
% �T�[�t�F�X���Ԃ��܂��BXI �́A���l�ɂȂ邱�Ƃ��ł��܂��B
%
% X �͎��� m �s n ��ŁAn-������Ԃł� m �_��\�킵�܂��BY ��m �s 1 ���
% �����ŁA�n�C�p�[�T�[�t�F�X F(X) ��m �̒l��\�����܂��BXI �́Ap�sn��
% �̃x�N�g���ŁA�t�B�b�e�B���O�����n-������Ԃ̕\�ʂ̒l�� p �̓_��
% �\�킵�܂��BYI �́A�l F(XI)���ߎ����钷�� p �̃x�N�g���ł��B�n�C�p�[
% �T�[�t�F�X�́A��Ƀf�[�^�_ (X,Y) ��ʂ�܂��BXI �́A�ʏ��(MESHGRID 
% �ō쐬����悤��)��l�ȃO���b�h�ł��B
%
% YI = GRIDDATAN(X,Y,XI,METHOD) �́AMETHOD �����̂����ꂩ�ŁA�f�[�^
% �ւ̃T�[�t�F�X�̃t�B�b�e�B���O�̃^�C�v��I���ł��܂��B
%       'linear'    - �ו������x�[�X�ɂ������`���} (�f�t�H���g)
%       'nearest'   - �ŋߖT���
% ���ׂĂ̎�@�́A�f�[�^�� Delaunay �O�p�`���x�[�X�ɂ��Ă��܂��B
% METHOD �� [] �̏ꍇ�A�f�t�H���g�� 'linear' ���\�b�h���g�p����܂��B
%
% YI = GRIDDATAN(X,Y,XI,METHOD,OPTIONS) �́ADELAUNAYN �ɂ�� 
% Qhull �̃I�v�V�����Ƃ��Ďg�p�����悤�ɁA������ OPTIONS �̃Z���z���
% �w�肵�܂��B
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
%
% �Q�l GRIDDATA, GRIDDATA3, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2003 The MathWorks, Inc.

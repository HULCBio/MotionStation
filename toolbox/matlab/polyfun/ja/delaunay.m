%DELAUNAY Delaunay �O�p�`����
% TRI = DELAUNAY(X,Y) �́A�O�p�`�̊O�ډ~�Ƀf�[�^�_���܂܂�Ȃ��悤�ȁA
% �O�p�`�̏W�����o�͂��܂��BM�s3��̍s�� TRI �̊e�s�� 1�̎O�p�`��
% ��`���A�x�N�g�� X �� Y �̃C���f�b�N�X���܂�ł��܂��B �O�p�`���v�Z
% �ł��Ȃ�(�I���W�i���f�[�^���꒼����ɑ��݁A�܂��� X ����Ȃǂ�)�ꍇ�́A
% ��s�񂪖߂���܂��B
%
% DELAUNAY �́AQhull ���g�p���܂��B
%
% TRI = DELAUNAY(X,Y,OPTIONS) �́ADELAUNAYN �ɂ�� Qhull �̃I�v�V�����Ƃ���
% �g�p�����悤�ɁA������ OPTIONS �̃Z���z����w�肵�܂��B�f�t�H���g��
% �I�v�V�����́A{'Qt','Qbb','Qc'} �ł��B
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
% Qhull �Ƃ��̃I�v�V�����ɂ��Ă̏ڍׂ́Ahttp://www.qhull.org. ��
% �Q�Ƃ��Ă��������B
%
% ���:
%   x = [-0.5 -0.5 0.5 0.5];
%   y = [-0.5 0.5 0.5 -0.5];
%   tri = delaunay(x,y,{'Qt','Qbb','Qc','Qz'})
%
% Delaunay�O�p�`�́AGRIDDATA (�U�z���Ă���f�[�^����}), CONVHULL, 
% VORONOI (VORONOI�_�C�A�O�������v�Z)�Ƌ��Ɏg���A�U�z���Ă���f�[�^
% �_�ɑ΂��āA�O�p�O���b�h���쐬���邽�߂ɗL���ł��B
%
% �֐� DSEARCH �� TSEARCH �́A���ꂼ��A�ł��ߖT�̃f�[�^�_��͂񂾎O�p�`
% �����߂邽�߂̎O�p�`�������������܂��B
%   
% �Q�l VORONOI, TRIMESH, TRISURF, TRIPLOT, GRIDDATA, CONVHULL
%      DSEARCH, TSEARCH, DELAUNAY3, DELAUNAYN, QHULL.

%   Copyright 1984-2003 The MathWorks, Inc.

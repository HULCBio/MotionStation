%DELAUNAY3  3������Delaunay����
%
% T = DELAUNAY3(X,Y,Z) �́A�l�ʑ̂̎���̋��ʂɊ܂܂�Ȃ� X �̃f�[�^�_
% ����Ȃ�l�ʑ̂̏W�����o�͂��܂��BT �́Anum �s4��̔z��ł��BT �̊e�s��
% �v�f�́A(X,Y,Z) �̃��U�C�N���Ŏl�ʑ̂��`���_(X,Y,Z)�̓_�̃C���f�b�N�X
% �ł��B�O�p�`���v�Z�ł��Ȃ�(�I���W�i���f�[�^���꒼����ɑ��݁A�܂��� X 
% ����Ȃǂ�)�ꍇ�́A��s�񂪏o�͂���܂��B
%
% DELAUNAY3 �́AQhull ���g�p���܂��B 
%
% T = DELAUNAY3(X,Y,Z,OPTIONS) �́ADELAUNAY3 �ɂ�� Qhull �̃I�v�V�����Ƃ���
% �g�p�����悤�ɁA������ OPTIONS �̃Z���z����w�肵�܂��B�f�t�H���g��
% �I�v�V�����́A{'Qt','Qbb','Qc'} �ł��B
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
% Qhull �̃I�v�V�����ɂ��Ă̏ڍׂ́Ahttp://www.qhull.org. ��
% �Q�Ƃ��Ă��������B
%
% ���:
%   X = [-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5];
%   Y = [-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5];
%   Z = [-0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5];
%   T = delaunay3( X, Y, Z, {'Qt', 'Qbb', 'Qc', 'Qz'} )
%
% �Q�l QHULL, DELAUNAY, DELAUNAYN, GRIDDATA3, GRIDDATAN,
%      VORONOIN, TETRAMESH.

%   Copyright 1984-2003 The MathWorks, Inc.

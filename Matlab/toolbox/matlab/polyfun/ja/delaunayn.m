%DELAUNAYN  N-������ Delaunay ����
% T = DELAUNAYN(X) �́A�V���v���b�N�X�̎���̋��ʂɊ܂܂�Ȃ� X �̃f�[�^
% �_����Ȃ�V���v���b�N�X�̏W�����o�͂��܂��B�V���v���b�N�X�̏W���́A
% Delaunay�������`���܂��BX �� numt �s (n+1)��̔z��ŁA���̍s���Ή�
% ����V���v���b�N�X�̒��_��X �̃C���f�b�N�X�ɂȂ�܂��B�V���v���b�N�X��
% �v�Z�ł��Ȃ��ꍇ(���Ƃ��΁AX���މ�������AX ����̏ꍇ)�́A��s��
% �o�͂���܂��B
%
% DELAUNAYN �́AQhull ���g�p���܂��B  
%
% T = DELAUNAYN(X,OPTIONS) �́AQhull �̃I�v�V�����Ƃ��Ďg�p�����悤�ɁA
% ������ OPTIONS �̃Z���z����w�肵�܂��B�f�t�H���g�̃I�v�V�����́A
%     2D ����� 3D ���͂ɑ΂��āA {'Qt','Qbb','Qc'} ,
%     4D ����� ��荂���̓��͂ɑ΂��āA {'Qt','Qbb','Qc','Qx'} 
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
% Qhull �̃I�v�V�����ɂ��Ă̏ڍׂ́Ahttp://www.qhull.org. ���Q�Ƃ��Ă��������B%
% ���:
%   X = [-0.5 -0.5  -0.5;
%        -0.5 -0.5   0.5;
%        -0.5  0.5  -0.5;
%        -0.5  0.5   0.5;
%         0.5 -0.5  -0.5;
%         0.5 -0.5   0.5;
%         0.5  0.5  -0.5;
%         0.5  0.5   0.5];
%   T = delaunayn(X);
% �̓G���[�ɂȂ�܂����A'Qz' ���f�t�H���g�̃I�v�V�����ւ̒ǉ�
% ���𗧂��Ƃ������܂��B
%      T = delaunayn(X,{'Qt','Qbb','Qc','Qz'});
% ���̉𓚂�\�����邽�߂ɁATETRAMESH �֐����g�p���邱�Ƃ��ł��܂��B
%      tetramesh(T,X)
%
% �Q�l QHULL, VORONOIN, CONVHULLN, DELAUNAY, DELAUNAY3, TETRAMESH.

%   Copyright 1984-2003 The MathWorks, Inc.

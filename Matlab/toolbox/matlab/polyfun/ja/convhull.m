%CONVHULL �ʕ�
% K = CONVHULL(X,Y) �́A�ʕ��̓_�̃x�N�g�� X �� Y �̃C���f�b�N�X��
% �o�͂��܂��B
%
% CONVHULL �́AQhull���g�p���܂��B
%
% K = CONVHULL(X,Y,OPTIONS) �́ACONVHULLN �ɂ�� Qhull �̃I�v�V�����Ƃ���
% �g�p�����悤�ɁA������ OPTIONS �̃Z���z����w�肵�܂��B�f�t�H���g��
% �I�v�V�����́A{'Qt'}�ł��B
% OPTIONS �� [] �̏ꍇ�A�f�t�H���g�̃I�v�V�������g�p����܂��B
% OPTIONS �� {''} �̏ꍇ�A�I�v�V�����͎g�p����܂���B�f�t�H���g�̂���
% ���g�p����܂���B
% Qhull �Ƃ��̃I�v�V�����ɂ��Ă̏ڍׂ́Ahttp://www.qhull.org. ��
% �Q�Ƃ��Ă��������B
%
% [K,A] = CONVHULL(...) �́AA �̒��̓ʕ�̕������o�͂��܂��B
%
% ���:
%   X = [0 0 0 1];
%   Y = [0 1e-10 0 1];
%   K = convhull(X,Y,{'Qt','Pp'}) 
%
% �Q�l CONVHULLN, DELAUNAY, VORONOI, POLYAREA, QHULL.

%   Copyright 1984-2003 The MathWorks, Inc.

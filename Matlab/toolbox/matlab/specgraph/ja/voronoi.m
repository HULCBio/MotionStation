% VORONOI   Voronoi���}
%
% VORONOI(X,Y) �́A�_ X,Y �ɑ΂���Voronoi���}���v���b�g���܂��B
% ������̓_���܂ރZ���́A�L�E�ł͂Ȃ��A�v���b�g����܂���B
%
% VORONOI(X,Y,TRI) �́ADELAUNAY �Ōv�Z�������ɁA�O�p�`���� TRI ��
% �g���܂��B
%
% VORONOI(X,Y,OPTIONS) �́ADELAUNAY��Qhull�̃I�v�V�����Ƃ��ėp������
% ������̃Z���z����w�肵�܂��B
%   OPTIONS��[]�̏ꍇ�́A�f�t�H���g��DELAUNAY�I�v�V�������p�����܂��B
%   OPTIONS��{''}�̏ꍇ�́A�f�t�H���g���܂߁A�I�v�V�����͗p�����܂���B
%
% VORONOI(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = VORONOI(...,'LineSpec') �́A�w�肵���J���[�ƃ��C���X�^�C���ŁA
% Voronoi���}���v���b�g���A�쐬���ꂽline�I�u�W�F�N�g�̃n���h���ԍ��� 
% H �ɏo�͂��܂��B 
%
% [VX,VY] = VORONOI(...) �́AVoronoi���}�̃G�b�W�̒��_�� VX �� VY �ɏo��
% ���܂��B�o�͂��ꂽ���ʂ́Aplot(VX,VY,'-',X,Y,'.') �ɂ��AVoronoi���}��
% �쐬���܂��B
%
% Voronoi���}�̌^�A���Ȃ킿�A�evoronoi�Z���̒��_�ɂ��āA �֐� VORONOIN 
% �����̂悤�Ɏg���܂��B
%
%         [V,C] = VORONOIN([X(:) Y(:)])
%
% �Q�l�FVORONOIN, DELAUNAY, CONVHULL.


%   Copyright 1984-2002 The MathWorks, Inc. 

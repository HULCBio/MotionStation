% TRIMESH   �O�p�`���b�V���v���b�g
% 
% TRIMESH(TRI,X,Y,Z,C) �́AM�s3��̖ʂ̍s�� TRI �Œ�`�����O�p�`���A
% ���b�V���Ƃ��ĕ\�����܂��BTRI �̍s�́A���_ X,Y,Z ���܂ރx�N�g���̃C��
% �f�b�N�X���܂�ł��āA1�̎O�p�`�̖ʂ��`���܂��B�G�b�W�̐F�́A
% �x�N�g�� C �ɂ���Ē�`����܂��B
%
% TRIMESH(TRI,X,Y,Z) �́AC = Z ���g�p����̂ŁA�F�̓T�[�t�F�X�̍�����
% ��Ⴕ�܂��B
%
% TRIMESH(TRI,X,Y) �́A2�����v���b�g���ɎO�p�`��\�����܂��B
%
% H = TRIMESH(...) �́A�p�b�`�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��B
%
% TRIMESH(...,'param','value','param','value'...) �́A�p�b�`�I�u�W�F�N�g��
% �쐬���Ɏg�p����A�p�b�`�̃p�����[�^���ƒl�̑g���킹���g�����Ƃ��ł��܂��B
% 
% ���F
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trimesh(tri,x,y,z)
%
% �Q�l�FPATCH, TRISURF, DELAUNAY.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:30 $

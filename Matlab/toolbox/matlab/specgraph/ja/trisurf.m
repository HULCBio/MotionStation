% TRISURF   �O�p�`�T�[�t�F�X�v���b�g
% 
% TRISURF(TRI,X,Y,Z,C) �́AM�s3��̖ʂ̍s�� TRI �Œ�`�����O�p�`��
% �T�[�t�F�X�Ƃ��ĕ\�����܂��BTRI �̍s�́A���_ X,Y,Z ���܂ރx�N�g����
% �C���f�b�N�X���܂�ł��āA1�̎O�p�`�̖ʂ��`���܂��B�J���[�́A
% �x�N�g�� C �ɂ���Ē�`����܂��B
%
% TRISURF(TRI,X,Y,Z) �́AC = Z ���g�p����̂ŁA�J���[�̓T�[�t�F�X�̍�����
% ��Ⴕ�܂��B
%
% H = TRISURF(...) �́Apatch�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��B
%
% TRISURF(...,'param','value','param','value'...) �́Apatch�I�u�W�F�N�g��
% �쐬���Ɏg�p����A�p�b�`�̃p�����[�^���ƒl�̑g���킹���g�����Ƃ��ł��܂��B
%
% ���F
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trisurf(tri,x,y,z)
%
% �Q�l�FPATCH, TRIMESH, DELAUNAY.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:31 $

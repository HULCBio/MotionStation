% ISOSURFACE   �������T�[�t�F�X�̒��o
% 
% FV = ISOSURFACE(X,Y,Z,V,ISOVALUE) �́A�������T�[�t�F�X�̒lISOVALUE �ŁA
% �f�[�^ V �ɑ΂��铙�����T�[�t�F�X�̌`���v�Z���܂��B�z�� (X,Y,Z) �́A
% �f�[�^ V ���^������_���w�肵�܂��B�\���� FV �́A�������T�[�t�F�X��
% �ʂƒ��_���܂݁APATCH�R�}���h�ɒ��ړn����܂��B
% 
% FV = ISOSURFACE(V,ISOVALUE) �́A[M,N,P] = SIZE(V) �̂Ƃ��A
% [X Y Z] = meshgrid(1:N,1:M,1:P) �Ɖ��肵�܂��B
% 
% FV = ISOSURFACE(X,Y,Z,V) �܂��� FV = ISOSURFACE(V) �́A�f�[�^�̃q�X�g
% �O�������g���āA�������T�[�t�F�X�̒l�������I�ɑI�����܂��B
% 
% FVC = ISOSURFACE(..., COLORS) �́A�z�� COLORS ���X�J����ɓ��}���A
% ���}���ꂽ�l�� FACEVERTEXCDATA �ɕԂ��܂��BCOLORS �z��̃T�C�Y�́A
% V �Ɠ����ł��B
% 
% FV = ISOSURFACE(...�A'noshare') �́A���L����钸�_���쐬���܂���B����
% ���@�́A�������x�͑����ł����A�o�͂���钸�_�̐��͑����Ȃ�܂��B
% 
% FV = ISOSURFACE(...�A'verbose') �́A�v�Z�̐i�s�ɏ]���āA�R�}���h�E�B��
% �h�E�ɐi�s�̃��b�Z�[�W��\�����܂��B
% 
% [F�AV] = ISOSURFACE(...) �܂��� [F, V, C] = ISOSURFACE(...) �́A�ʂ�
% ���_���\���̂̑���ɁA�z��ɏo�͂��܂��B
% 
% ISOSURFACE(...)�́A�o�͈�����ݒ肵�Ȃ��ƁA�v�Z�����ʂⒸ�_���g���āA
% patch���쐬����܂��B
% 
% ��� 1�F
%      [x y z v] = flow;
%      p = patch(isosurface(x, y, z, v, -3));
%      isonormals(x,y,z,v, p)
%      set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
%      daspect([1 1 1])
%      view(3)
%      camlight; lighting phong
%
% ��� 2:
%      [x y z v] = flow;
%      q = z./x.*y.^3;
%      p = patch(isosurface(x, y, z, q, -.08, v));
%      isonormals(x,y,z,q, p)
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none');
%      daspect([1 1 1]); axis tight; 
%      colormap(prism(28))
%      camup([1 0 0 ]); campos([25 -55 5]) 
%      camlight; lighting phong
%       
%
% �Q�l�FISONORMALS, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH, SHRINKFACES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:21 $

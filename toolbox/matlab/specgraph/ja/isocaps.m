% ISOCAPS  �������G���h�L���b�v���v�Z
% 
% FVC = ISOCAPS(X,Y,Z,V,ISOVALUE) �́A�f�[�^ V �ɑ΂��铙�����T�[�t�F�X
% �l ISOVALUE �������T�[�t�F�X�G���h�L���b�v���v�Z���܂��B�z�� X,Y,Z ��
% �^����ꂽ�f�[�^ V �̓_��ݒ肵�܂��B�\���� FVC �́A�G���h�L���b�v��
% �t�F�[�X�A���_�A�J���[���܂݁APATCH �R�}���h�ɒ��ړn�����Ƃ��ł��܂��B
% 
% FVC = ISOCAPS(V,ISOVALUE) �́A���̃X�e�[�g�����g�����肵�Ă��܂��B
% 
%    [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
%        
% �����ŁA[M,N,P] = SIZE(V) �ł��B 
% 
% FVC = ISOCAPS(X,Y,Z,V) �܂��� FVC = ISOCAPS(V) �́A�f�[�^�̃q�X�g�O����
% ���g���āA�����I�ɓ������l��I�����܂��B
% 
% FVC = ISOCAPS(..., ENCLOSE) �ł́AENCLOSE ���G���h�L���b�v���A
% ISOVALUE�̏�('above' �f�t�H���g)�܂��͉�('below')�̃f�[�^���܂ޏꍇ��
% �ݒ肵�܂��B
% 
% FVC = ISOPCAPS(..., WHICHPLANE) �ł́AWHICHPLANE ���A�G���h�L���b�v
% ���`�悳��镽�ʂ܂��͕��ʌQ���w�肵�܂��BWHICHPLANE �́A 'all'(�f�t�H
% ���g), 'xmin', 'xmax', 'ymin', 'ymax', 'zmin', 'zmax' �̂����ꂩ��
% �ݒ肵�܂��B
% 
% [F, V, C] = ISOCAPS(...) �́A�\���̂̑����3�̔z��Ƀt�F�[�X�A���_�A
% �J���[���o�͂��܂��B
% 
% ISOCAPS(...) �́A�o�͈�����ݒ肵�Ȃ��Ŏg�p����ƁA�v�Z�����t�F�[�X�A
% ���_�A�J���[����p�b�`������܂��B
%
% ���F
%      load mri
%      D = squeeze(D);
%      D(:,1:60,:) = [];
%      p = patch(isosurface(D, 5), 'FaceColor', 'red',....
%               'EdgeColor', 'none');
%      p2 = patch(isocaps(D, 5), 'FaceColor', 'interp', ....
%                  'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(D, p);
%
% �Q�l�FISOSURFACE, ISONORMALS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:18 $

% SUBVOLUME   �̐σf�[�^�Z�b�g�̃T�u�Z�b�g�̒��o
% 
% [NX�ANY�ANZ�ANV] = SUBVOLUME(X,Y,Z,V,LIMITS) �́A�w�肵������ LIMITS
% ���g���āA�̐σf�[�^�Z�b�g V �̃T�u�Z�b�g�𒊏o���܂��B
% LIMITS = [xmin xmax ymin ymax zmin zmax] �ł�(limits ���̔C�ӂ�NaN�́A
% �̐ς����ɉ����Đ؂����Ȃ����Ƃ��Ӗ����܂�)�B�z�� X,Y,Z �́A�f�[�^
% V ���^������_���w�肵�܂��B���o���ꂽ�̐ς� NV �ɏo�͂���A���o
% ���ꂽ�̐ς̍��W�� NX�ANY�ANZ �ɏo�͂���܂��B
%
% [NX�ANY�ANZ�ANV] = SUBVOLUME(V,LIMITS) �́A[M,N,P] = SIZE(V) �̂Ƃ��A
% [X YZ] = meshgrid(1:N�A1:M�A1:P) �Ɖ��肵�܂��B
% 
% [NX, NY, NZ, NU, NV, NW] = SUBVOLUME(X,Y,Z,U,V,W,LIMITS) �́A�x�N�g��
% �f�[�^�x�[�X U,V,W ����T�u�Z�b�g�𒊏o���܂��B
%
% [NX, NY, NZ, NU, NV, NW] = SUBVOLUME(U,V,W,LIMITS) �́A
% [M,N,P]=SIZE(U) �̂Ƃ��ɁA[X Y Z] = meshgrid(1:N, 1:M, 1:P) �����肵��
% ���܂��B
% 
% NV = SUBVOLUME(...) �܂��� [NU, NV, NW] = SUBVOLUME(...) �́A���o���ꂽ
% �̐ς݂̂��o�͂��܂��B
%
%   ��� 1:
%      load mri
%      D = squeeze(D);
%      [x y z D] = subvolume(D, [60 80 nan 80 nan nan]);
%      p = patch(isosurface(x,y,z,D, 5), 'FaceColor', 'red', ....
%          'EdgeColor', 'none');
%      p2 = patch(isocaps(x,y,z,D, 5), 'FaceColor', 'interp',...
%         'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(x,y,z,D,p);
%
%   ��� 2:
%      load wind
%      [x y z u v w] = subvolume(x,y,z,u,v,w,[105 120  nan 30  2 6]);
%      streamslice(x,y,z,u,v,w,[],[],[3 4 5], .4);
%      daspect([1 1 .125])
%      h = streamtube(x,y,z,u,v,w,110,22,5.5);
%      set(h, 'FaceColor', 'red', 'EdgeColor', 'none')
%      axis tight
%      view(3)
%      camlight; lighting gouraud
%
% �Q�l�FISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:27 $

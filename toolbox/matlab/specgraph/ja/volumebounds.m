% VOLUMEBOUNDS   ���̃f�[�^�ɑ΂���x,y,z �ƃJ���[�Ɋւ���͈͂��o��
% 
% LIMS = VOLUMEBOUNDS(X,Y,Z,V) �́A�X�J���f�[�^�ɑ΂���J�����g����x,y,z
% �ƃJ���[�͈̔͂��o�͂��܂��BLIMS �́A�x�N�g�� [xmin xmax ymin ymax 
% zmin zmax cmin cmax] �ɂȂ�܂��B���̃x�N�g���́AAXIS �R�}���h�ɓn����
% �܂��B
%
% LIMS = VOLUMEBOUNDS(X,Y,Z,U,V,W) �́A�x�N�g���f�[�^�ɑ΂���J�����g����
% x,y,z �͈̔͂��o�͂��܂��BLIMS �́A�x�N�g�� [xmin xmax ymin ymax zmin zmax]
% �ɂȂ�܂��B
%
% VOLUMEBOUNDS(V)  �܂��� VOLUMEBOUNDS(U,V,W) �́A���̃X�e�[�g�����g
% �����肵�Ă��܂��B
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(V) �ł��B 
%
% ���:
% 
%      [x y z v] = flow;
%      p = patch(isosurface(x, y, z, v, -3));
%      isonormals(x,y,z,v, p)
%      daspect([1 1 1])
%      isocolors(x,y,z,flipdim(v,2),p)
%      shading interp
%      axis(volumebounds(x,y,z,v))
%      view(3)
%      camlight 
%      lighting phong
%
% �Q�l�FISOSURFACE, STREAMSLICE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:06:33 $

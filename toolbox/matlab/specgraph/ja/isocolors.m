% ISOCOLORS �́A�������T�[�t�F�X�ƃp�b�`�J���[���v�Z���܂��B
% 
% NC = ISOCOLORS(X,Y,Z,C,VERTICES) �́A�J���[�x�N�g�� C ���g���āA������
% �T�[�t�F�X(�p�b�`)�̒��_ VERTICES �̃J���[���v�Z���܂��B�z�� X,Y,Z ��
% �f�[�^ C ��^����_��ݒ肵�܂��BX,Y,Z �́AC �ɑ΂�����W�ŁA�P���x�N�g��
% �ł��邩�A3�����i�q�z��ł���K�v������܂��B�J���[�́ANC �ɏo�͂���
% �܂��BC ��3����(�C���f�b�N�X�J���[)�łȂ���΂Ȃ�܂���B
% 
% NC = ISOCOLORS(X,Y,Z,R,G,B,VERTICES) �́AR,G,B �J���[�z����g�p���܂��B
%
% NC = ISOCOLORS(C,VERTICES) �܂��� 
% NC = ISOCOLORS(R,G,B,VERTICES)�́A���̃X�e�[�g�����g�����肵�܂��B
% 
%    [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(C) �ł��B 
% 
% NC = ISOCOLORS(C,P), NC = ISOCOLORS(X,Y,Z,C,P), NC = ISOCOLORS...
% (R,G,B,P), NC = ISOCOLORS(X,Y,Z,R,G,B,P) �́A�p�b�` P ����̒��_��
% �g�p���܂��B
% 
% ISOCOLORS(C,P), ISOCOLORS(X,Y,Z,C,P), ISOCOLORS(R,G,B,P), 
% ISOCOLORS(X,Y,Z,R,G,B,P) �́A�v�Z���ꂽ�J���[���g���āAP �ɐݒ肳�ꂽ
% �p�b�`�� 'FaceVertexCdata' �v���p�e�B��ݒ肵�܂��B
%
% ��� 1:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      cdata = smooth3(rand(size(data)), 'box', 7);
%      p = patch(isosurface(x,y,z,data, 10));
%      isonormals(x,y,z,data,p);
%      isocolors(x,y,z,cdata,p);
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);axis tight
%      camlight; lighting p; 
%
% ��� 2:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      p = patch(isosurface(x,y,z,data, 20));
%      isonormals(x,y,z,data,p);
%      [r g b] = meshgrid(20:-1:1, 1:20, 1:20);
%      isocolors(x,y,z,r/20,g/20,b/20,p);
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);
%      camlight; lighting p; 
%
% ��� 3:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data = sqrt(x.^2 + y.^2 + z.^2);
%      p = patch(isosurface(data, 20));
%      isonormals(data,p);
%      [r g b] = meshgrid(20:-1:1, 1:20, 1:20);
%      c=isocolors(r/20,g/20,b/20,p);
%      set(p, 'FaceVertexCdata', 1-c)
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none')
%      view(150,30); daspect([1 1 1]);
%      camlight; lighting p; 
%
% �Q�l�FISOSURFACE, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH, ISONORMALS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:05:19 $

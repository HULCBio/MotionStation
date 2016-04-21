% REDUCEVOLUME   �̐σf�[�^�Z�b�g�̍팸
% 
% [NX�ANY�ANZ�ANV] = REDUCEVOLUME(X,Y,Z,V,[Rx Ry Rz]) �́Ax������ Rx �v�f�A
% y������ Ry �v�f�Az������ Rz �v�f���Ƀf�[�^��ێ����āA�̐ϓ��̗v�f����
% ���炵�܂��B3�v�f�̃x�N�g���̑���ɁA�팸����\�킷���߂ɃX�J�� R ��
% �g�p�����ꍇ�́A�팸���� [R R R] �Ɖ��肳��܂��B�z�� X�AY�AZ �́A
% �f�[�^ V ���^������_���w�肵�܂��B�팸���ꂽ�̐ς� NV �ɏo�͂���A
% �팸���ꂽ�̐ς̍��W�� NX�ANY�ANZ �ɏo�͂���܂��B
% 
% [NX�ANY�ANZ�ANV] = REDUCEVOLUME(V,[Rx Ry Rz]) �́A[M,N,P] = SIZE(V)
% �̂Ƃ��A[X Y Z] = meshgrid(1:N, 1:M, 1:P) �Ɖ��肵�܂��B
%
% NV = REDUCEVOLUME(...) �́A�팸���ꂽ�̐ς݂̂��o�͂��܂��B
%
% ���:
%      load mri
%      D = squeeze(D);
%      [x y z D] = reducevolume(D, [4 4 1]);
%      D = smooth3(D);
%      p = patch(isosurface(x,y,z,D, 5,'verbose'), ...
%                'FaceColor', 'red', 'EdgeColor', 'none');
%      p2 = patch(isocaps(x,y,z,D, 5), 'FaceColor', 'interp',....
%               'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(x,y,z,D,p);
%
% �Q�l�FISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, SUBVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:35 $

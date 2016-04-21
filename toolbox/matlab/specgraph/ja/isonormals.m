% ISONORMALS   �������T�[�t�F�X�̖@��
% 
% N = ISONORMALS(X,Y,Z,V,VERTICES) �́A�f�[�^ V �̌��z���g���āA������
% �T�[�t�F�X�̒��_ VERTICES �̖@�����v�Z���܂��B�z�� X�AY�AZ �́A�f�[�^ 
% V ���^������_���w�肵�܂��B�@���� N �ɏo�͂���܂��B�f�t�H���g�ł́A
% �@���͂�菬���ȃf�[�^�l�̕����������Ă��܂��B
% 
% N = ISONORMALS(V,VERTICES) �́A[M,N,P] = SIZE(V) �̂Ƃ� 
% [X Y Z] = meshgrid(1:N,1:M,1:P) �Ɖ��肵�܂��B
% 
% N = ISONORMALS(V,P) �܂��� N = ISONORMALS(X,Y,Z,V,P) �́Apatch P ����
% ���_���g�p���܂��B
% 
% N = ISONORMALS(...�A'negate') �́A�v�Z���ꂽ�@���𖳌��ɂ��܂��B
% 
% ISONORMALS(V,P) �܂��� ISONORMALS(X,Y,Z,V,P) �́A�v�Z���ꂽ�@���������A
% P �Ŏw�肳�ꂽpatch�� 'VertexNormals' �v���p�e�B��ݒ肵�܂��B
%
% ���:
%      data = cat(3, [0 .2 0; 0 .3 0; 0 0 0], ...
%                    [.1 .2 0; 0 1 0; .2 .7 0],...
%                    [0 .4 .2; .2 .4 0;.1 .1 0]);
%      data = interp3(data,3, 'cubic');
%      subplot(1,2,1)
%      p = patch(isosurface(data, .5), 'FaceColor', 'red', ....
%                 'EdgeColor', 'none');
%      view(3); daspect([1 1 1]);axis tight
%      camlight;  camlight(-80,-10); lighting p; 
%      title('Triangle Normals')
%      subplot(1,2,2)
%      p = patch(isosurface(data, .5), 'FaceColor', 'red', ....
%                     'EdgeColor', 'none');
%      isonormals(data,p)
%      view(3); daspect([1 1 1]); axis tight
%      camlight;  camlight(-80,-10); lighting phong; 
%      title('Data Normals')
%
% �Q�l�FISOSURFACE, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:05:20 $

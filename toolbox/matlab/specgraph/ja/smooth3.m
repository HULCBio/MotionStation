% SMOOTH3   3�����f�[�^�̕�����
% 
% W = SMOOTH3(V) �́A���̓f�[�^ V �𕽊������܂��B���������ꂽ�f�[�^�́A
% W �ɏo�͂���܂��B
% 
% W = SMOOTH3(V�A'filter') �ŁAFilter�� 'gaussian' �܂��� 'box'(�f�t�H���g)
% �ŁA�R���{�����[�V�����J�[�l�����w�肵�܂��B
% 
% W = SMOOTH3(V�A'filter'�ASIZE) �́A�R���{�����[�V�����J�[�l���̃T�C�Y��
% �ݒ肵�܂�(�f�t�H���g�� [3 3 3] �ł�)�BSIZE ���X�J���̏ꍇ�A�T�C�Y�� 
% [SIZE SIZE SIZE] �Ƃ��ĉ��߂���܂��B
% 
% W = SMOOTH3(V�A'filter'�ASIZE�AARG) �́A�R���{�����[�V�����J�[�l����
% ������ݒ肵�܂��B�t�B���^�� 'gaussian' �̂Ƃ��AARG �͕W���΍��ł�
% (�f�t�H���g��.65�ł�)�B
%
% ���:
% 
%      data = rand(10,10,10);
%      data = smooth3(data,'box',5);
%      p = patch(isosurface(data,.5), ...
%          'FaceColor', 'blue', 'EdgeColor', 'none');
%      p2 = patch(isocaps(data,.5), ...
%          'FaceColor', 'interp', 'EdgeColor', 'none');
%      isonormals(data,p)
%      view(3); axis vis3d tight
%      camlight; lighting phong
%
% �Q�l�FISOSURFACE, ISOCAPS, ISONORMALS, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:14 $

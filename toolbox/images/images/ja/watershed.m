% WATERSHED �@�C���[�W�� watershed �̈�̌��o
%
% L = WATERSHED(A) �́A���͍s�� A �� watershed �̈�����ʂ��郉�x���s��
% ���v�Z���܂��BA �́A�C�ӂ̎����������Ƃ��ł��܂��BL �̗v�f�́A0���
% ���傫�������ł��B���x��0�̗v�f�́A���j�[�N�� watershed �̈�ɑ�����
% ���܂���B�����́A"watershed"�s�N�Z���ƌĂ΂�܂��B���x��1�̗v�f�́A
% �ŏ��� watershed �̈�ɑ����A���x��2�̗v�f�́A2 �Ԗڂ� watershed �̈�
% �ɁA���X�A�����܂��B
%
% �f�t�H���g�ŁAWATERSHED �́A2�������͂�8�A���A3�������͂�26�A���A�������ŁA
% CONNDEF(NDIMS(A),'maximal') ���g���܂��B
%
% L = WATERSHED(A,CONN) �́A�w�肵���A�����g���āAwatershed �ϊ����v�Z��
% �܂��BCONN �́A���̃X�J���l�̂����ꂩ��ݒ�ł��܂��B
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s���
% �g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN �̒�
% �S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂��āA��
% �̂ł���K�v������܂��B
%
% �N���X�T�|�[�g
% -------------
% A �́A�C�ӂ̎����̐��l�܂��� logical �ŁA��X�p�[�X�łȂ���΂Ȃ��
% ����B�o�͔z�� L �́A double �ł��B
%
% ���(2-D)
% -------------
%   1. 2�̉~�̃I�u�W�F�N�g���d�Ȃ����o�C�i���C���[�W���쐬
%
%       center1 = -10;
%       center2 = -center1;
%       dist = sqrt(2*(2*center1)^2);
%       radius = dist/2 * 1.4;
%       lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
%       [x,y] = meshgrid(lims(1):lims(2));
%       bw1 = sqrt((x-center1).^2 + (y-center1).^2) <= radius;
%       bw2 = sqrt((x-center2).^2 + (y-center2).^2) <= radius;
%       bw = bw1 | bw2;
%       figure, imshow(bw,'n'), title('bw')
%
%   2. �o�C�i���C���[�W�̕␔�̋����ϊ����v�Z
%
%       D = bwdist(~bw);
%       figure, imshow(D,[],'n'), title('Distance transform of ~bw')
%
%   3. �����ϊ��̕␔�����A�s�N�Z�����A-Inf �ő��݂���I�u�W�F�N�g��
%      �܂܂��Ȃ��悤�ɂ��܂��B
%
%       D = -D;
%       D(~bw) = -Inf;
%
%   4. Watershed�ϊ����v�Z���ARGB �C���[�W�Ƃ��Č��ʂ̃��x���t���̍s���
%      �\�����܂��B
%
%       L = watershed(D); 
%       rgb = label2rgb(L,'jet',[.5 .5 .5]);
%       figure, imshow(rgb,'n'), title('Watershed transform of D')
%
% ���(3-D)
% -------------
%   1.2�̏d�Ȃ荇���������܂�3�����C���[�W���쐬���܂��B
%
%       center1 = -10;
%       center2 = -center1;
%       dist = sqrt(3*(2*center1)^2);
%       radius = dist/2 * 1.4;
%       lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
%       [x,y,z] = meshgrid(lims(1):lims(2));
%       bw1 = sqrt((x-center1).^2 + (y-center1).^2 + ...
%           (z-center1).^2) <= radius;
%       bw2 = sqrt((x-center2).^2 + (y-center2).^2 + ...
%           (z-center2).^2) <= radius;
%       bw = bw1 | bw2;
%       figure, isosurface(x,y,z,bw,0.5), axis equal, title('BW')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   2. �����ϊ����v�Z
%
%       D = bwdist(~bw);
%       figure, isosurface(x,y,z,D,radius/2), axis equal
%       title('Isosurface of distance transform')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   3. �����ϊ��̕␔�����A�I�u�W�F�N�g�łȂ��s�N�Z���� -Inf �ɐݒ肵�A
%      watershed �ϊ����v�Z���܂��B
%
%       D = -D;
%       D(~bw) = -Inf;
%       L = watershed(D);
%       figure, isosurface(x,y,z,L==2,0.5), axis equal
%       title('Segmented object')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%       figure, isosurface(x,y,z,L==3,0.5), axis equal
%       title('Segmented object')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
% �Q�l�F BWLABEL, BWLABELN, REGIONPROPS.



%   Copyright 1993-2002 The MathWorks, Inc.

% BWULTERODE  �ŏI�I�ȏk��
% BW2 = BWULTERODE(BW) �́A�o�C�i���C���[�W BW �̍ŏI�I�ȏk�ނ��v�Z����
% ���BBW �̍ŏI�I�ȏk�ނƂ́ABW �̕␔�̃��[�N���b�h�����ϊ��̒n��I�ȍ�
% ��l�̏W�܂肩��\������Ă��܂��B�n��I�ȍő�l�̏W�܂�Ɋւ���f�t�H
% ���g�̘A���x��2�����̏ꍇ8�A3�����̏ꍇ26�ŁA�������̏ꍇ�ACONNDEF(ND-
% IMS(BW),'maximal') �ł��B
%
% BW2 = BWULTERODE(BW,METHOD,CONN) �́A�����ϊ���@�ƒn��I�ȍő�l�̏W
% �܂�̘A���x��ݒ肷�邱�Ƃ��ł��܂��BMETHOD �́A������ 'euclidean', 
% 'cityblock', 'chessboard', 'quasi-euclidean' �̂����ꂩ��ݒ肷�邱��
% ���ł��܂��BCONN �́A���̃X�J���l�̂����ꂩ���g�p���܂��B 
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s���
% �g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN ��
% ���S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂��āA
% �Ώ̂ł���K�v������܂��B
%
% �N���X�T�|�[�g
% -------------
% BW �́A���l�� logical �ŁA��X�p�[�X�łȂ���΂Ȃ�܂���B�C�ӂ̎�����
% �g�����Ƃ��ł��܂��BBW2 �́A��� logical �ɂȂ�܂��B
%
% ���
% -------
%       bw = imread('circles.tif');
%       imshow(bw), title('Original')
%       bw2 = bwulterode(bw);
%       figure, imshow(bw2), title('Ultimate erosion')
%
% �Q�l�FBWDIST, CONNDEF, IMREGIONALMAX.



%   Copyright 1993-2002 The MathWorks, Inc.

% IMIMPOSEMIN �@Minima �̊��蓖��
% I2 = IMIMPOSEMIN(I,BW) �́A�`�Ԋw�I�ȍč\���@���g���āA���x�C���[�W I 
% ��ύX���܂��B����ŁABW ����[���̕����̂݁A�n��I�ȍŏ��l�̏W�܂��
% �����܂��B
%
% �f�t�H���g�ł́AIMIMPOSEMIN �́A2�����C���[�W�ŁA8�A���ߖT�A3�����C��
% �[�W�ŁA26�A���ߖT���g���܂��B�������̏ꍇ�́ACONNDEF(NDIMS(I),'maxi-
% mal') ���g���܂��B 
%
% �V���^�b�N�X I2 = IMIMPOSEMIN(I,BW,CONN) �́A�f�t�H���g�̘A���x������
% �����܂��BCONN �́A���̃X�J���l�̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��B
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
% I �́A�C�ӂ̔�X�p�[�X���l�N���X�ŁA�C�ӂ̎����������Ă��܂��BBW �́A
% I �Ɠ����傫���̔�X�p�[�X�z��łȂ���΂Ȃ�܂���BI2 �́AI �Ɠ���
% �T�C�Y�œ����N���X�ɂȂ�܂��B
%
% ���
% -------
% bonemarr �̒��̃C���[�W���C�����܂��B�����āA����ʒu�ŁA�n��I�ȍŏ��l
% �̏W�܂�����܂��B
%
%       I = imread('bonemarr.tif');
%       imshow(I), title('Original image')
%       bw = zeros(size(I));
%       bw(98:102,101:105) = 1;
%       J = I;
%       J(bw ~= 0) = 255;
%       figure, imshow(J)
%       title('Image with desired minima location superimposed')
%       K = imimposemin(I,bw);
%       figure, imshow(K)
%       title('Modified image')
%       bw2 = imregionalmin(K);
%       figure, imshow(bw2)
%       title('Regional minima of modified image')
%
% �Q�l�F CONNDEF, IMRECONSTRUCT, IMREGIONALMIN.



%   Copyright 1993-2002 The MathWorks, Inc.

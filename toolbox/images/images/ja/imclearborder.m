% IMCLEARBORDER  �C���[�W���E�ƘA�����Ă���\���̖��邳��}����
% IM2 = IMCLEARBORDER(IM) �́A�C���[�W���E�ɘA�����Ă�����̂��A����̂�
% �̂�薾�邢�\����ጸ���܂��BIM �́A���x�C���[�W�A�܂��́A�o�C�i���C��
% �[�W�̂ǂ��炩�ł��B�o�̓C���[�W IM2 �́A���x�A�܂��́A�o�C�i���C���[�W
% �ł��B�f�t�H���g�̘A���́A2�����̏ꍇ8�A3�����̏ꍇ26�A�������̏ꍇ�A
% CONNDEF(NDIMS(BW),'maximal') �ł��B
%
% ���x�C���[�W�̏ꍇ�AIMCLEARBORDER �́A���E�\���\����ጸ���邱�Ƃɉ�
% ���A�S�̓I�ȋ��x���x����Ⴍ����X��������܂��B
%
% IM2 = IMCLEARBORDER(IM,CONN) �́A��]����A���x���w�肵�܂��BCONN �́A
% ���̃X�J���l��ݒ肵�܂��B
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
% ����
% ----
% ���̓C���[�W�̃G�b�W��̃s�N�Z���́A�f�t�H���g�łȂ��A����ݒ肵���ꍇ�A
% "���E"��̃s�N�Z���Ƃ͍l���܂���B���Ƃ��΁ACONN = [0 0 0; 1 1 1; 0 0 0]
% �̏ꍇ�A�ŏ��ƍŌ�̍s�̗v�f�́A���̘A���̒�`�ɏ]���āA�C���[�W�̊O��
% �̈�ƌ������Ă��Ȃ��̂ŁA���E�s�N�Z���Ƃ͍l���܂���B
%
% �N���X�T�|�[�g
% -------------
% IM �́A�C�ӂ̎����̐��l�܂��� logical �ŁA��X�p�[�X�Ŏ����łȂ����
% �Ȃ�܂���BIM2 �́AIM �Ɠ����N���X�ɂȂ�܂��B
%
% ���
% --------
% ���̗��́A���x�C���[�W�̋��E��@���ɃN���A�ɂ��邩�������Ă��܂��B
%
%       I = imread('rice.tif');
%       I2 = imclearborder(I);
%       figure, imshow(I)
%       figure, imshow(I2)
%
% ���̗��́A�o�C�i���C���[�W�̋��E��@���ɃN���A�ɂ��邩�������Ă��܂��B
%
%       BW = im2bw(imread('rice.tif'));
%       BW2 = imclearborder(BW);
%       figure, imshow(BW)
%       figure, imshow(BW2)
%
% �Q�l�F IMRECONSTRUCT.



%   Copyright 1993-2002 The MathWorks, Inc.

% BWPERIM �o�C�i���C���[�W�̒��̋��E�������o
% BW2 = BWPERIM(BW1) �́A���̓C���[�W BW1 �̒��̃I�u�W�F�N�g�̋��E���̃s
% �N�Z���݂̂��܂ރo�C�i���C���[�W��߂��܂��B�s�N�Z���́A��[���Ȃ�΋�
% �E���ŁA���Ȃ��Ƃ���[���̒l�����s�N�Z���Ɛڑ����Ă��܂��B�f�t�H��
% �g�̘A���x��2�����̏ꍇ4�A3�����̏ꍇ6�ŁA�����̏ꍇ�ACONNDEF(NDIMS
% (BW),'minimal') �ɂȂ�܂��B
%
% BW2 = BWPERIM(BW1,CONN) �́A��]����A���x���w�肵�܂��BCONN �́A����
% �X�J���l��ݒ肵�܂��B
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
% BW1 �́Alogical �܂��́A���l�z��ŁA��X�p�[�X�łȂ���΂Ȃ�܂���B
% BW2 �́Alogical �ł��B
%
% ���
%   -------
%       BW1 = imread('circbw.tif');
%       BW2 = bwperim(BW1,8);
%       imshow(BW1)
%       figure, imshow(BW2)
%
% �Q�l�FBWAREA, BWEULER, BWFILL, CONNDEF.



%   Copyright 1993-2002 The MathWorks, Inc.  

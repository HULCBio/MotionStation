% BWAREAOPEN �o�C�i���̈�̃I�[�v�������F�������I�u�W�F�N�g���폜
% BW2 = BWAREAOPEN(BW,P) �́AP�̃s�N�Z����菭�Ȃ��s�N�Z���̘A������
% ���o�C�i���C���[�W���珜�����A�o�C�i���C���[�W BW2 ���쐬���܂��B�f
% �t�H���g�̘A���x�́A2������8�A3������26�A�������ŁACONNDEF(NDIMS(BW),
% 'maximal')�ł��B
%
% BW2 = BWAREAOPEN(BW,P,CONN) �́A��]����A���x���w�肵�܂��BCONN �́A
% ���̃X�J���l��ݒ肷�邱�Ƃ��ł��܂��B
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
% BW �́Alogical ���C�ӂ̎����̐��l�z��ŁA��X�p�[�X�łȂ���΂Ȃ��
% ����B
%
% BW2 �́Alogical �ł��B
%
% ���
% -------
% �C���[�W text.tif �̒���40�s�N�Z���ȉ��̃I�u�W�F�N�g���������܂��B
%
%       bw = imread('text.tif');
%       imshow(bw), title('Original')
%       bw2 = bwareaopen(bw,40);
%       figure, imshow(bw2), title('Area open (40 pixels)')
%
% �Q�l�FBWLABEL, BWLABELN, CONNDEF, REGIONPROPS.



%   Copyright 1993-2002 The MathWorks, Inc.

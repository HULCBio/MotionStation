% IMFILL  �C���[�W�̈�̓h��ׂ�
% BW2 = IMFILL(BW1,LOCATIONS) �́ALOCATIONS �Őݒ肵���_����X�^�[�g����
% ���̓o�C�i���C���[�W BW1 �̃o�b�N�O�����h�s�N�Z���ɓh��ׂ����Z��K�p��
% �܂��BLOCATIONS �́AP �s1��̃x�N�g���ŁA�X�^�[�g�̈ʒu�̐��`�C���f�b�N
% �X���܂�ł��܂��BLOCATIONS �́A�X�̍s���A�X�^�[�g�̈ʒu�̈�̔z��
% �C���f�b�N�X���܂ށAP �s NDIMS(IM1) ��̍s��Őݒ肷�邱�Ƃ��ł��܂��B
%
% BW2 = IMFILL(BW1,'holes') �́A���̓C���[�W���̃z�[���̓h��ׂ����s����
% ���B�z�[���́A�C���[�W�̃G�b�W����o�b�N�O�����h�̒��œh��ׂ����Ƃł�
% �c��o�b�N�O�����h�s�N�Z���̏W���ł��B
%
% I2 = IMFILL(I1) �́A���x�C���[�W I1 �̒��̃z�[����h��ׂ��܂��B����
% �ꍇ�A�z�[���́A��薾�邢�s�N�Z���ň͂܂ꂽ�Â��s�N�Z������߂�̈�
% ���Ӗ����܂��B
%
% �Θb�I�Ȏg�p
% ---------------
% BW2 = IMFILL(BW1) �́ABW1 ���X�N���[����ɕ\�����A�}�E�X���g���āA�X�^
% �[�g�_��I�����܂��B�ʏ�̃}�E�X�N���b�N�@���g���āA�_��t�����܂��B�O
% �ɑI�������_���폜����ɂ́A<BACKSPACE>�A�܂��́A<DELETE> �������܂��B
% Shift �L�[�������ăN���b�N���邩�A�E�N���b�N�A�܂��́A�_�u���N���b�N��
% ���A�I���̍ŏI�̓_�̑I�����s���A���̌�ŁA�h��ׂ����n�߂܂��B�_��t
% �����Ȃ��ŁA�I�����I������ɂ́A<RETURN> �������܂��B��b�I�Ȏg�����́A
% 2�����C���[�W�݂̂ŃT�|�[�g����Ă��܂��B
%
% �V���^�b�N�X [BW2,LOCATIONS] = IMFILL(BW1) �́A�}�E�X���g���đI�������X
% �^�[�g�_���o�͂��邱�Ƃ��ł��܂��B�o�� LOCATIONS �́A��ɁA���̓C���[�W
% �̒��̐��`�C���f�b�N�X�̃x�N�g���̌^�����Ă��܂��B
%
% �A���̐ݒ�
% -----------------------
% �f�t�H���g�ŁAIMFILL �́A2 �������͂ɑ΂��āA4-�A���o�b�N�O�����h�ߖT
% ���A3 �������͂ɑ΂��āA6-�A���o�b�N�O�����h�A�����g���܂��B��荂����
% �ɂ��ẮA�f�t�H���g�̃o�b�N�O�����h�A���́ACONNDEF(NUM_DIMS,'mini-
% mal') �ł��B���[�U�́A���̃V���^�b�N�X�̂����ꂩ���g���āA�f�t�H���g
% �̘A�������������邱�Ƃ��ł��܂��B
%
%       BW2 = IMFILL(BW1,LOCATIONS,CONN)
%       BW2 = IMFILL(BW1,CONN,'holes')
%       I2  = IMFILL(I1,CONN)
%
% �f�t�H���g�̘A�������������A�X�^�[�g�̈ʒu����b�I�Ɏw�肷��ɂ́A��
% �̃V���^�b�N�X���g���Ă��������B
%
%       BW2 = IMFILL(BW1,0,CONN)
%
% CONN �́A���̂����ꂩ�̃X�J���l��ݒ肵�܂��B
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s���
% �g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN �̒�
% �S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂��āA�Ώ�
% �ł���K�v������܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�͐��l�܂��� logical �ŁA�����̔�X�p�[�X�łȂ���΂Ȃ��
% ����B����͔C�ӂ̎����������܂��B�o�̓C���[�W�́A���̓C���[�W�Ɠ���
% �N���X�ɂȂ�܂��B
%
% ���
% --------
% �ݒ肵���X�^�[�g�̈ʒu����o�C�i���C���[�W�̃o�b�N�O�����h�̒��̓h���
% �����s���܂��B
%
%       BW1 = logical([1 0 0 0 0 0 0 0
%                      1 1 1 1 1 0 0 0
%                      1 0 0 0 1 0 1 0
%                      1 0 0 0 1 1 1 0
%                      1 1 1 1 0 1 1 1
%                      1 0 0 1 1 0 1 0
%                      1 0 0 0 1 0 1 0
%                      1 0 0 0 1 1 1 0]);
%       BW2 = imfill(BW1,[3 3],8)
%
% �o�C�i���C���[�W�̃z�[���̒���h��ׂ��܂��B
%
%       BW4 = ~im2bw(imread('blood1.tif'));
%       BW5 = imfill(BW4,'holes');
%       imshow(BW4), figure, imshow(BW5)
%
% ���x�C���[�W�̃z�[���̒���h��ׂ��܂��B
%
%       I = imread('enamel.tif');
%       I2 = imcomplement(imfill(imcomplement(I),'holes'));
%       imshow(I), figure, imshow(I2)
%
% �Q�l�F BWSELECT, IMRECONSTRUCT, ROIFILL.



%   Copyright 1993-2002 The MathWorks, Inc.  

% IMADJUST   �C���[�W�̋��x�l�A�܂��́A�J���[�}�b�v�𒲐�
%   J = IMADJUST(I,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA) �́A���x
%   �C���[�W I �� LOW_IN ���� HIGH_IN �܂ł͈̔͂̒l���ALOW_OUT ���� 
%   HIGH_OUT �͈̔͂Ƀ}�b�s���O���邱�Ƃɂ�� J ���쐬���܂��BLOW_IN 
%   ��菬�����l�� LOW_OUT �ɁAHIGH_IN �����傫���l�� HIGH_OUT ��
%   �}�b�s���O���܂��B[LOW_IN HIGH_IN] �� [LOW_OUT HIGH_OUT] ����s��
%   �̏ꍇ�A�f�t�H���g��[0 1]���g���܂��B
%
%   NEWMAP = IMADJUST(MAP,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA)
%   �́A�C���f�b�N�X�t���C���[�W�Ɋ֘A�����J���[�}�b�v��ϊ����܂��B
% 
%   LOW_IN�AHIGH_IN�ALOW_OUT�AHIGH_OUT�AGAMMA ���X�J���̏ꍇ�A�����
%   �}�b�s���O���A�ԁA�΁A�̐����ɓK�p����܂��B�e�J���[�������ɁA��
%   �j�[�N�ȃ}�b�s���O�́A���̏ꍇ�ɗL���ł��B
%   
%   LOW_IN and HIGH_IN ���A1�s3��̃x�N�g���A�܂��́ALOW_OUT �� 
%   HIGH_OUT ��1�s3��̃x�N�g���A�܂��́AGAMMA ��1�s3��̃x�N�g���̂�
%   ���ꂩ�̏ꍇ�A�ăX�P�[�����O���ꂽ�J���[�}�b�v�ANEWMAP �́AMAP ��
%   �����T�C�Y�ł��B
%
%   RGB2 = IMADJUST(RGB1,...) �́ARGB �C���[�W RGB1 �̊e�C���[�W����
%   (�ԁA�΁A��)�𒲐����܂��B�J���[�}�b�v�̒������s���āA�e���ʂɃ�
%   �j�[�N�ȃ}�b�s���O��K�p�ł��܂��B
%
%   HIGH_OUT < LOW_OUT �̏ꍇ�A�o�̓C���[�W�͋t�ɂȂ邱�Ƃɒ��ӂ��Ă�
%   �������B���Ȃ킿�A�ʐ^�̂悤�ȕϊ��̂悤�ɂȂ�܂��B
%
% �@�֐� STRETCHLIM �́AIMADJUST �Ƌ��Ɏg���A�R���g���X�g�̈����L�΂���
%   �����I�Ɍv�Z���܂��B
%
% �N���X�T�|�[�g
% -------------
%   ���̓C���[�W(�J���[�}�b�v�ł͂���܂���)���܂ލ\���ɑ΂��āA���̓C
%   ���[�W�́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X���T�|�[�g
%   ���Ă��܂��B�o�̓C���[�W�́A���̓C���[�W�Ɠ����N���X�ł��B�J���[
%   �}�b�v���܂ލ\���Ɋւ��ẮA���͂Əo�͂̃J���[�}�b�v�́A�N���X 
%   double �ł��B
%
% ���
% ----
%       I = imread('pout.tif');
%       J = imadjust(I,[0.3 0.7],[]);
%       imshow(I), figure, imshow(J)
%
%       RGB1 = imread('flowers.tif');
%       RGB2 = imadjust(RGB1,[.2 .3 0; .6 .7 1],[]);
%       imshow(RGB1), figure, imshow(RGB2)
%
% �Q�l : BRIGHTEN, HISTEQ, STRETCHLIM



%   Copyright 1993-2002 The MathWorks, Inc.  

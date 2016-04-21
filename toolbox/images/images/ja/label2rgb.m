% LABEL2RGB �́A���x���s��� RGB �C���[�W�ɕϊ����܂��B
% RGB = LABEL2RGB(L) �́A�֐� BWLABEL �� WATERSHED �ɂ��o�͂���郉�x
% ���s�� L���A���x�������ꂽ�̈����������ړI�ŁA�J���[ RGB �C���[�W
% �ɕϊ����܂��B
%
% RGB = LABEL2RGB(L, MAP) �́ARGB �C���[�W�Ŏg�p����J���[�}�b�v���`��
% �܂��BMAP �́An �s 3 ��̃J���[�}�b�v�s��A�J���[�}�b�v�֐��̖��O(����
% ���΁A'jet'��'gray')���܂񂾕�����A�J���[�}�b�v�֐���function handle
% (���Ƃ��΁A@jet�A�܂��́A@gray) �̂����ꂩ�Œ�`�ł��܂��BLABEL2RGB �́A
% L �̒��̊e�̈�ɑ΂��āA�قȂ�J���[�ɂȂ�悤�� MAP ���v�Z���܂��B
%
% RGB = LABEL2RGB(L, MAP, ZEROCOLOR) �́A���̓��x���s�� L �̒��ŁA0�ƃ�
% �x�������ꂽ�v�f�� RGB �J���[���`���܂��BZEROCOLOR �́ARGB ��3�v�f�A
% �܂��́A'y' (��), 'm', (�}�[���_), 'c'(�V�A��), 'r'(��), 'g' (��), 'b' 
% (��), 'w' (��), 'k'(��) �̂����ꂩ��ݒ�ł��܂��BZEROCOLOR ��ݒ肵��
% ���ꍇ�A�f�t�H���g�ŁA[1 1 1] ���g���܂��B
%   
% RGB = LABEL2RGB(L, MAP, ZEROCOLOR, ORDER) �́A���x���s��̒��ɗ̈�ɁA
% �J���[�}�b�v�����蓖�Ă��@���R���g���[�����܂��BORDER ���A'noshuffle'
% (�f�t�H���g)�̏ꍇ�A�J���[�}�b�v�J���[���A���l���Ƀ��x���s��̗̈�Ɋ�
% �蓖�Ă܂��BORDER ���A'shuffle' �̏ꍇ�A�J���[�}�b�v�́A�[�������_����
% �V���b�t������܂��B
%   
% �N���X�T�|�[�g
% -------------
%
% ���̓��x���s�� L �́A�C�ӂ̔�X�p�[�X���l�N���X�ł��B����́A�L���̔�
% ���̐�������\������Ă���K�v������܂��BLABEL2RGB �̏o�͂́A�N���X 
% uint8 �ł��B
%
% �Q�l�F BWLABEL, BWLABELN, ISMEMBER, WATERSHED.
%
% ���
% -------
%   I = imread('rice.tif');
%   figure, imshow(I), title('original image')
%   BW = im2bw(I, graythresh(I));
%   L = bwlabel(BW);
%   RGB = label2rgb(L);
%   RGB2 = label2rgb(L, 'spring', 'c', 'shuffle');
%   imshow(RGB), figure, imshow(RGB2)



%   Copyright 1993-2002 The MathWorks, Inc.  

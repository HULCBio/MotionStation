% GETIMAGE    ������C���[�W�f�[�^���擾
%
% A = GETIMAGE(H) �́AHandle Graphics �I�u�W�F�N�g H �Ɋ܂܂��ŏ���
% �C���[�W�f�[�^���o�͂��܂��BH �́AFigure �ł��A���ł��A�C���[�W�ł��A
% �e�N�X�`���}�b�s���O���ꂽ�T�[�t�F�X�ł��\���܂���BA �́A�C���[�W 
% Cdata �Ɠ������̂ł��B���Ȃ킿�A�C���[�W CData �Ɠ����l�ŁA�����N���X
% (�N���X uint8�Auint16, double �Ȃ�)�ł��BH ���C���[�W�łȂ��A�܂��A
% �C���[�W��e�N�X�`���}�b�s���O���ꂽ�T�[�t�F�X�ł��Ȃ��ꍇ�AA �͋��
% �Ȃ�܂��B
%
% [X,Y,A] = GETIMAGE(H) �́A�C���[�W�f�[�^ XData �� X �ɁAYData �� Y 
% �ɏo�͂��܂��BXData �� YData �́Ax ���� y ���͈̔͂�����2�v�f�x�N�g��
% �ł��B
%
% [...,A,FLAG] = GETIMAGE(H) �́A�C���[�W H ���܂ރ^�C�v�����������t���O
% ���o�͂��܂��B���̕\�́AFLAG �̎�蓾��l���܂Ƃ߂����̂ł��B
%   
%       0   �C���[�W�ł͂���܂���BA �́A��s��Ƃ��ďo�͂���܂��B
%
%       1   �C���f�b�N�X�t���C���[�W
%
%       2   �W���I�Ȕ͈͂̋��x�C���[�W(double �z��ɑ΂���[0,1]�Auint8
%           �z��ɑ΂��āA[0,255]�Auint16 �z��ɑ΂���[0,65536])
%
%       3   ���x�C���[�W�A�������A�W���I�Ȕ͈͂ɓ���Ȃ�
%
%       4   RGB �C���[�W
%
% [...] = GETIMAGE �́A�J�����g�̎��ɑ΂�������o�͂��܂��B����́A
% [...] = GETIMAGE(GCA) �Ɠ����ł��B
%
% �N���X�T�|�[�g
% -------------
% �o�͔z�� A �́A�C���[�W CData �Ɠ����N���X�ł��B���̂��ׂĂ̓��͂�
% �o�͂́A�N���X double �ł��B
%
% ���
% ----
% imshow ���g���āA�t�@�C�����璼�ڃC���[�W��\��������AGETIMAGE ��
% �g���āA���[�N�X�y�[�X�ɁA���̃C���[�W�f�[�^����荞�݂܂��B
%
%       imshow rice.tif
%       I = getimage;



%   Copyright 1993-2002 The MathWorks, Inc.  


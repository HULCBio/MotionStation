% BWSELECT   �o�C�i���C���[�W���̃I�u�W�F�N�g�̑I��
% BW2 = BWSELECT(BW1,C,R,N) �́A�s�N�Z��(R,C)�ɏd�Ȃ�I�u�W�F�N�g���܂�
% �o�C�i���C���[�W���o�͂��܂��BR �� C �́A�X�J���ł��A�������������x�N�g
% ���ł��\���܂���BR �� C ���x�N�g���̏ꍇ�ABW2 �̓s�N�Z��(R(k),C(k))��
% �����ꂩ�Əd�Ȃ�I�u�W�F�N�g�̏W�����܂݂܂��BN �ɂ́A4�A�܂��́A8(�f
% �t�H���g)�̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��B�����ŁA4��4�A���I�u�W�F
% �N�g�A8��8�A���I�u�W�F�N�g�ł��B�I�u�W�F�N�g�́Aon �s�N�Z��(�l1������
% �s�N�Z��)�̘A�����ꂽ�W���ł��B
% 
% BW2 = BWSELECT(BW1,N) �́A�C���[�W BW1 ���X�N���[����ɕ\�����A����ɁA
% �}�E�X���g����(R,C)���W��I�����邱�Ƃ��ł��܂��BBW1 ���ȗ�����ƁAB-
% WSELECT �̓J�����g�̎����̃C���[�W�ɋ@�\���܂��B�_��t������ɂ͒ʏ��
% �{�^���N���b�N���g���Ă��������B�O�ɑI�����Ă����_���폜����ɂ́A<B-
% ACKSPACE>�A�܂��́A<DELETE> �������Ă��������BShift-�N���b�N�A�E�{�^��
% �N���b�N�A�_�u���N���b�N�̂����ꂩ�ɂ��A�Ō�̓_��I�����܂��B<RET-
% URN> �������ƁA�_���������ɑI�����I�����܂��B
% 
% [BW2,IDX] = BWSELECT(...) �́A�I�������I�u�W�F�N�g�ɑ�����s�N�Z���̐�
% �`�C���f�b�N�X���o�͂��܂��B
% 
% BW2 = BWSELECT(X,Y,BW1,Xi,Yi,N) �́A�x�N�g�� X �� Y ���g���āA�f�t�H��
% �g�Őݒ肳��Ă��Ȃ� BW1 �̍��W�n���\�����܂��BXi �� Yi �́A�X�J���ł�
% �����̓������x�N�g���ł��\���܂���B�����́A���W�n�̒��̈ʒu���w�肷
% ����̂ł��B
% 
% [X,Y,BW2,IDX,Xi,Yi] = BWSELECT(...) �́AX �� Y �� XData �� YData ���o
% �͂��ABW2�ɏo�̓C���[�W�AIDX �ɑI�������I�u�W�F�N�g�ɑ����邷�ׂẴs
% �N�Z���̐��`�C���f�b�N�X�AXi �� Yi �ɐݒ肵����ԍ��W���o�͂��܂��B
% 
% �o�͈�����ݒ肵�Ȃ��ŁAbwselect ���g���ƁA�o�͂����C���[�W�͐V���� 
% Figure �ɕ\������܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W BW1 �́Alogical ���C�ӂ̐��l�^�C�v�ŁA2�����̔�X�p�[�X
% �łȂ���΂Ȃ�܂���B�o�̓C���[�W BW2 �́Alogical �ł��B
% 
% ���
%       BW1 = imread('text.tif');
%       c = [16 90 144];
%       r = [85 197 247];
%       BW2 = bwselect(BW1,c,r,4);
%       imshow(BW1)
%       figure, imshow(BW2)
%
% �Q�l�FIMFILL, BWLABEL, ROIPOLY, ROIFILL.



%   Copyright 1993-2002 The MathWorks, Inc.  

% ROICOLOR   �J���[���x�[�X�ɁA�Ώۗ̈�̑I��
% ROICOLOR �́A�C���f�b�N�X�t���C���[�W�A�܂��́A���x�C���[�W���̑�
% �ۗ̈��I�����A�o�C�i���C���[�W�Ƃ��ďo�͂��܂�(�o�͂��ꂽ�C���[
% �W�́A�֐� ROIFILT2 ���g���āA�}�X�N���g�����t�B���^�����O�̂��߂�
% �}�X�N�p�Ɏg���܂�)�B
%
% BW = ROICOLOR(A,LOW,HIGH) �́A�J���[�}�b�v�͈̔�[LOW HIGH]���Ɉʒu
% ����s�N�Z����I�����A���̗̈��\���o�C�i���C���[�W�Ƃ��ďo�͂���
% ���B
%
%       BW = (A >= LOW) & (A <= HIGH);
%
% BW �́A�Ώۗ̈�O��0�ŁA�Ώۗ̈��1�ŕ\���܂��B
%
% BW = ROICOLOR(A,V) �́AA �̒��̃s�N�Z�����x�N�g�� V �̒l�Ƀ}�b�`
% ������̂�Ώۗ̈�Ƃ��đI�����܂��BBW �́AA �̒l�� V �̒l�ƃ}�b�`
% ���镔���ł�1�ɂȂ�o�C�i���C���[�W�ł�
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W A �́A�z��łȂ���΂Ȃ�܂���B�o�̓C���[�W BW �́A
% �N���X logical�ł��B
%
% ���
% ----
%       I = imread('rice.tif');
%       BW = roicolor(I,128,255);
%       imshow(I), figure, imshow(BW)
%
% �Q�l�FROIPOLY



%   Copyright 1993-2002 The MathWorks, Inc.

% BWPACK �@�o�C�i���C���[�W�̃p�b�N(���k)
% BWP = BWPACK(BW) �́Auint8 �̃o�C�i���C���[�W BW �� uint32 �̔z�� BWP
% �Ƀp�b�N���܂��B���� uint32 �̔z�ӗ�́A�p�b�N���ꂽ�o�C�i���C���[�W��
% ���ėǂ��m��ꂽ���̂ł��B�o�C�i���C���[�W�̒��̌X�� 8-�r�b�g�s�N�Z��
% �l�́A������2�̒l(1 �� 0)���������Ƃ��ł��Ȃ��̂ŁABWPACK �́A�p�b
% �N���ꂽ�o�̓C���[�W�̒��̒P��r�b�g�Ɋe�s�N�Z�����}�b�s���O�ł��܂��B
%
% BWPACK �́A��P�ʂŁA�C���[�W�s�N�Z�����������A32 �s�N�Z���̃O���[�v�� 
% uint32 �̒l�̃r�b�g�Ƀ}�b�s���O���܂��B�ŏ��̍s�̍ŏ��̃s�N�Z���́A�o��
% �z��̍ŏ��� uint32 �v�f�̍ŏ��̈Ӗ������r�b�g�ɑΉ����܂��B32�Ԗڂ�
% �s�̍ŏ��̃s�N�Z���́A���̓����v�f�̍ł��傫���Ӗ��̂���r�b�g�ɑΉ���
% �܂��B33�Ԗڂ̍s�̍ŏ��̃s�N�Z���́A2�Ԗڂ̏o�͗v�f�̍ŏ��̈Ӗ��̂���r
% �b�g�ɑΉ����܂��B�����悤�ɁA����Ή����܂��BBW ���AM �s N ��̏ꍇ�A
% BWP �́ACEIL(M/32) �s N ��ɂȂ�܂��B 
%
% �o�C�i���C���[�W�̃p�b�N���́A�c����k�ނ̂悤�Ȃ������̃o�C�i���`��
% �w�I���Z�������ɂ��邽�߂Ɏg���܂��BIMDILATE �� IMERODE �ւ̓��͂��A
% �p�b�N���ꂽ�o�C�i���C���[�W�̏ꍇ�A�֐��́A���ʂȊ֐��Ɏg���A���Z��
% �����ɂ��܂��B 
%
% BWUNPACK �́A�o�C�i���C���[�W�̃p�b�N���������邽�߂Ɏg���܂��B
%
% �N���X�T�|�[�g
% -------------
% BW �� logical �����l�ŁA2�����̎����ŁA��X�p�[�X�łȂ���΂Ȃ�܂���B
% BWP �� uint32 �ł��B
%
% ���
% -------
% �o�C�i���C���[�W�̃p�b�N�A�c���A�p�b�N�̉������s���܂��B
%
%       bw = imread('text.tif');
%       bwp = bwpack(bw);
%       bwp_dilated = imdilate(bwp,ones(3,3),'ispacked');
%       bw_dilated = bwunpack(bwp_dilated, size(bw,1));
%
% �Q�l�FBWUNPACK, IMDILATE, IMERODE.



%   Copyright 1993-2002 The MathWorks, Inc.

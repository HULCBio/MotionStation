% BWUNPACK  �o�C�i���C���[�W�̃p�b�N�̉���
% BW = BWUNPACK(BWP,M) �́A�p�b�N���ꂽ�o�C�i���C���[�W BWP �̃p�b�N��
% �Ԃ��������܂��BBWP �́Auint32 �z��ł��BBWP �p�b�N��Ԃ���������ꍇ�A
% BWUNPACK �́ABWP �̍ŏ��̍s�̍ŏ��r�b�g��BW �̍ŏ��̍s�̒��̍ŏ��̃s�N
% �Z���Ƀ}�b�s���O���܂��BBWP �̍ŏ��̗v�f�̍ő�r�b�g�́ABW ��32�Ԗڂ�
% �ŏ��̃s�N�Z���Ƀ}�b�s���O����A���l�ɂ��āA���ׂĂ��}�b�s���O����܂��B
% BW �́AM �s N ��ł��B�����ŁAN �́ABWP �̗񐔂ł��BM ���ȗ�����ƁA
% �f�t�H���g�� 32*SIZE(BWP,1) ���g���܂��B
%
% �o�C�i���C���[�W�̃p�b�N���́A�c����k�ނ̂悤�Ȃ������̃o�C�i���`
% �Ԋw�I���Z�������ɂ��邽�߂Ɏg���܂��BIMDILATE �� IMERODE �ւ̓���
% ���A�p�b�N���ꂽ�o�C�i���C���[�W�̏ꍇ�A�֐��́A���ʂȊ֐��Ɏg���A
% ���Z�������ɂ��܂��B 
%
% BWNPACK �́A�o�C�i���C���[�W���p�b�N���邽�߂Ɏg���܂��B
%
% �N���X�T�|�[�g
% -------------
% BMP �́Auint32 �ŁA�܂�������2�����̔�X�p�[�X�łȂ���΂Ȃ�܂���B
% BW �� logical �ł��B
%
% ���
% -------
% �o�C�i���C���[�W���p�b�N�A�c���A�p�b�N�̉������s���܂��B
%
%       bw = imread('text.tif');
%       bwp = bwpack(bw);
%       bwp_dilated = imdilate(bwp,ones(3,3),'ispacked');
%       bw_dilated = bwunpack(bwp_dilated, size(bw,1));
%
% �Q�l�FBWPACK, IMDILATE, IMERODE.



%   Copyright 1993-2002 The MathWorks, Inc.

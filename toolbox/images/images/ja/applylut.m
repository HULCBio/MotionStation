% APPLYLUT   ���b�N�A�b�v�e�[�u�����g���ċߖT���Z�����s
%
% A = APPLYLUT(BW,LUT) �́A���b�N�A�b�v�e�[�u��(LUT)���g���āA�o�C�i���C
% ���[�W BW��2�s2��A�܂��́A3�s3��̋ߖT���Z�����s���܂��BLUT �́AMAK-
% ELUT ���o�͂���16�v�f�A�܂��́A512�v�f�̃x�N�g���ł��B���̃x�N�g���́A
% �\�Ȃ��ׂĂ�2�s2��A�܂��́A3�s3��̋ߖT�ɑ΂���o�͒l�ō\������܂��B
% 
% �N���X�T�|�[�g
% -------------
% BW �́A���l�� logical �ł��B�܂��A�����̔�X�p�[�X��2�����z��łȂ�
% ��΂Ȃ�܂���B
%
% LUT �́A���l�� logical �ł��B�܂��A16�܂���512�̗v�f���������x�N�g��
% �łȂ���΂Ȃ�܂���B

% LUT �̂��ׂĂ̗v�f��0��1�̏ꍇ�AA �� logical �ŁALUT �̂��ׂĂ̗v�f��
% 0����255�̊Ԃ̐����ł���΁AA �� uint8 �ŁA���̑��̏ꍇ�AA �̃N���X��
% double �ɂȂ�܂��B
%
% ���
% -------
% ���̗��ł́A2�s2��ߖT���g���āA�k�ނ����s���܂��B�o�̓s�N�Z���́A
% 4�̓��̓s�N�Z���̋ߖT�s�N�Z�����A���ׂ�"on"�̏ꍇ�̂݁A"on"�ɂȂ��
% ���B
%
%       lut = makelut('sum(x(:)) == 4', 2);
%       BW1 = imread('text.tif');
%       BW2 = applylut(BW1,lut);
%       imshow(BW1)
%       figure, imshow(BW2)
%
% �Q�l�FMAKELUT.



%   Copyright 1993-2002 The MathWorks, Inc.

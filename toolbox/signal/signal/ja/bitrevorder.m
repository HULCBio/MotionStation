% BITREVORDER   ���͂��r�b�g���]���������ɕ��בւ��܂�
%
% Y = BITREVORDER(X)�́A�r�b�g���]���������ŁA���בւ���ꂽ�ŏ���
% �V���O���g���łȂ������ŁAX �Ɠ����傫���̔z�� Y ���o�͂��܂��B
%
% [Y,I] = BITREVORDER(X) �́A�x�N�g�� Y �ɑ΂��� Y=X(I) �ƂȂ�悤�A
% �r�b�g���]�����C���f�b�N�X�x�N�g�� I ��Ԃ��܂��B
%
% ���̑���́AFFT ����� IFFT �ϊ����A���s���̌��������ǂ��邽�߂ɁA
% �r�b�g���]�̕��ёւ��Ȃ��Ɍv�Z����Ă�����g���̈�̃t�B���^�����O
% �A���S���Y���̎g�p�ɑ΂��āA�t�B���^�W���̃x�N�g�����A�O�����ĕ��ׂ�
% �ۂɗL���ł��B
%
% BITREVORDER(X) �̃R�[���́ADIGITREVORDER(X, 2) ���R�[�����邱�Ƃ�
% �����ł��B
%
% ���:
%       x = [0:15].';
%       y = bitrevorder(x); % 2�̊(�r�b�g���])�ł� x �̕��ёւ�
%       [x y]
%
% �Q�l�F DIGITREVORDER, FFT, IFFT.


% Copyright 1988-2002 The MathWorks, Inc.

% DIGITREVORDER   ���͂��f�W�b�g(digit)���]���������ɕ��בւ��܂�
%
% Y = DIGITREVORDER(X, R) �́A�f�W�b�g(digit)���]���������ŁA���בւ�
% ��ꂽ�ŏ��̃V���O���g���łȂ������ŁAX �Ɠ����傫���̔z�� Y ���o��
% ���܂��B���בւ���ꂽ�����̒����́A����x�[�X�Ƃ��� R �̗ݏ��
% ���肳��܂��B2�̊�ł̓��͂ɑ΂��āA���̗�́A���͗v�f�̃r�b�g
% ���]�ɂȂ�܂��B
%
% [Y,I] = DIGITREVORDER(X, R) �́A�x�N�g�� Y �ɑ΂��� Y=X(I) �ƂȂ�
% �悤�A�f�W�b�g(digit)���]�����C���f�b�N�X�x�N�g�� I ���o�͂��܂��B
%
% ���̑���́AFFT ����� IFFT �ϊ����A���s���̌��������ǂ��邽�߂ɁA
% �f�W�b�g(digit)���]�̕��ёւ��Ȃ��Ɍv�Z����Ă�����g���̈�̃t�B��
% �^�����O�A���S���Y���̎g�p�ɑ΂��āA�t�B���^�W���̃x�N�g�����A
% �O�����ĕ��ׂ�ۂɗL���ł��B
%
% ���:
%       x  = [0:15].';
%       y2 = digitrevorder(x, 2); % 2�̊(�r�b�g���])�ł� x �̕��ёւ�
%       y4 = digitrevorder(x, 4); % 4�̊(�f�W�b�g���])�ł� x �̕��ёւ�
%       [x y2 y4]
%
% �Q�l: BITREVORDER, FFT, IFFT.


% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 17:41:58 $

% DCT2    2�������U�R�T�C���ϊ��̌v�Z
% B = DCT2(A) �́AA �̗��U�R�T�C���ϊ����o�͂��܂��B�s�� B �́AA �Ɠ���
% �傫���ŁA���U�R�T�C���ϊ��W�����܂�ł��܂��B
% 
% B = DCT2(A,[M N])�A�܂��́AB = DCT2(A,M,N) �́A�ϊ�����O��0��t������
% M �s N ��̑傫���ɍs�� A �𐮌`���܂��BM�A�܂��́AN ���AA �̑Ή�����
% �傫�������������ꍇ�ADCT2 �́AA �̗v�f��؂�̂Ă܂��B
% 
% IDCT2 ���g���ƁA���̋t�̕ϊ������邱�Ƃ��ł��܂��B
% 
% �N���X�T�|�[�g
% -------------
% A �́A���l�܂��� logical �ł��B�o�͂����s�� B �́A�N���X double 
% �ł��B
% 
% ���
% -------
%       RGB = imread('autumn.tif');
%       I = rgb2gray(RGB);
%       J = dct2(I);
%       imshow(log(abs(J)),[]), colormap(jet), colorbar
%
% ���̃R�}���h�́ADCT �s��̒��ő傫����10�ȉ��̂��̂�0�ɐݒ肵�A�t 
% DCT �֐� IDCT2 ���g���āA�C���[�W���č\�����܂��B
%
%       J(abs(J)<10) = 0;
%       K = idct2(J);
%       imshow(I), figure, imshow(K,[0 255])
%
% �Q�l�FFFT2, IDCT2, IFFT2.


%   Copyright 1993-2002 The MathWorks, Inc.  

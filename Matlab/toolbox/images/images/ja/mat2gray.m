% MAT2GRAY   �s������x�C���[�W�֕ϊ�
%   I = MAT2GRAY(A,[AMIN AMAX]) �́A�s�� A �����x�C���[�WI�ɕϊ�����
%   ���B���ʋ��܂�s��I�́A0.0(��)����1.0(�t�����x�A�܂��́A��)�͈̔�
%   �̒l���܂�ł��܂��BAMIN �� AMAX �́AI ��0.0��1.0�ɑΉ����� A ��
%   ���̒l�ł��B
%
%   I = MAT2GRAY(A) �́AA �̒��̍ŏ��l�A�ő�l�� AMIN �� AMAX �̒l�ɐ�
%   �肵�܂��B
%
%   �N���X�T�|�[�g
% -------------
%   ���͔z�� A �Əo�̓C���[�W I �́A�N���X double �ł��B
%
%   ���
%   ----
%       I = imread('rice.tif');
%       J = filter2(fspecial('sobel'), I);
%       K = mat2gray(J);
%       imshow(I), figure, imshow(K)
%
%   �Q�l�FGRAY2IND



%   Copyright 1993-2002 The MathWorks, Inc.  

% IMADD ��̃C���[�W�̉��Z�A�܂��́A�C���[�W�ɒ萔�����Z
%
% Z = IMADD(X,Y) �́A�z�� X �̒��̊e�v�f�ɔz�� Y �̒��̑Ή�����v�f����
% ���A�o�͔z�� Z �̒��̑Ή�����v�f�ɏo�͂��܂��BX �� Y �́A�����T�C�Y�A
% �N���X�̎����A��X�p�[�X�A���l�z��ł��B�܂��AY �̓X�J���� double ��
% ���\���܂���BZ �́AX �Ɠ����T�C�Y�A�N���X�ɂȂ�܂��B
%
% Z = IMADD(X,Y,OUTPUT_CLASS) �́AZ �̊�]�̏o�̓N���X���w�肵�܂��B
% OUTPUT_CLASS �́A�ȉ��̕�����̂ЂƂłȂ���΂Ȃ�܂���B:
% 'uint8', 'uint16', 'uint32', 'int8', 'int16', and 'int32', 'single, 
% 'double'.
%
% Z �������z��̏ꍇ�A�����^�C�v�͈̔͂𒴂���o�͗v�f�͑ł��؂��A
% �����_�ȉ��͊ۂ߂��܂��B
%
% X �� Y �� double �z��̏ꍇ�A���̊֐��̑���ɁAX+Y ���g�����Ƃ��ł�
% �܂��B
%
% ��� 1
% -------
% 2�̃C���[�W�����Z���܂��B
%
%       I = imread('rice.tif');
%       J = imread('cameraman.tif');
%       K = imadd(I,J);
%       imshow(K)
%
% ��� 2
% -------
% 2�̃C���[�W�����Z���A�o�̓N���X���w�肵�܂��B
%
%       I = imread('rice.tif');
%       J = imread('cameraman.tif');
%       K = imadd(I,J,'uint16');
%       imshow(K,[])
%
% ��� 3
% -------
% �C���[�W�ɒ萔�������܂��B
%
%       I = imread('rice.tif');
%       J = imadd(I,50);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(J)
%
% �Q�l�FIMABSDIFF, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB
% �@�@�@IMMULTIPLY, IMSUBTRACT.



%   Copyright 1993-2002 The MathWorks, Inc.

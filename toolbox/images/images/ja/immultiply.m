% IMMULTIPLY �@2�̃C���[�W�̏�Z�A�܂��́A�C���[�W�ƒ萔�̏�Z
%
% Z = IMMULTIPLY(X,Y) �́A�z�� X �̒��̊e�v�f���A�z�� Y �̒��̑Ή�����v
% �f�Ə�Z���A���ʂ� Z �̑Ή�����v�f�ɏo�͂��܂��B
%
% X �� Y ���A�����T�C�Y�œ����N���X�̎����̐��l�z��ł���ꍇ�AZ �́A
% X �Ɠ����T�C�Y�œ����N���X�ɂȂ�܂��BX �����l�z��� Y ���X�J���� 
% double �̗v�f�̏ꍇ�AZ �́AX �Ɠ����T�C�Y�ŁA�N���X�ɂȂ�܂��B
%
% X �� logical �ŁAY �����l�̏ꍇ�AZ �� Y �Ɠ����T�C�Y�œ����N���X�ɂȂ�
% �܂��BX �����l�ŁAY �� logical �̏ꍇ�AZ �� X �Ɠ����T�C�Y�œ����N���X
% �ɂȂ�܂��B
%
% IMMULTIPLY �́A�{���x�̕��������_�ŁAZ �̊e�v�f���v�Z���܂��BX �������z
% ��̏ꍇ�A�����^�C�v�͈̔͂𒴂���o�͗v�f�́A�ł��؂��A�����_�ȉ���
% �ۂ߂��܂��B
%
% X �� Y ���Adouble �̔z��̏ꍇ�A���̊֐����g�p�������ɁAX.*Y ���g��
% �܂��B
%
% ���
% -------
% 2�� uint8 �C���[�W����Z���A���ʂ� uint16 �̃C���[�W�ɃX�g�A���܂��B
%
%       I = imread('moon.tif');
%       I16 = uint16(I);
%       J = immultiply(I16,I16);
%       imshow(I), figure, imshow(J)
%
% �萔�t�@�N�^�ŁA�C���[�W���X�P�[�����O���܂��B
%
%       I = imread('moon.tif');
%       J = immultiply(I,0.5);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(J)
%
% �Q�l�F IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.  



%   Copyright 1993-2002 The MathWorks, Inc.

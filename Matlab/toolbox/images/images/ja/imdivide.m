% IMDIVIDE �@2�̃C���[�W�̏��Z�A�܂��́A�C���[�W��萔�ŏ��Z
% Z = IMDIVIDE(X,Y) �́A�z�� X �̒��̊e�v�f���A�z�� Y �̒��̑Ή�����v�f
% �ŏ��Z���A���ʂ� Z �̑Ή�����v�f�ɏo�͂��܂��BX �� Y ���A���ɁA�����A
% ��X�p�[�X�A���l�z��ł��邩�A�܂��́AY ���X�J���� double �̗v�f�̏ꍇ�A
% Z �́AX �Ɠ����T�C�Y�ŁA�N���X�ɂȂ�܂��B
%
% X �������z��̏ꍇ�A�����^�C�v�͈̔͂𒴂���o�͗v�f�́A�ł��؂��A
% �����_�ȉ��͊ۂ߂��܂��B
%
% X �� Y ���Adouble �̔z��̏ꍇ�A���̊֐����g�p�������ɁAX./Y ��
% �g���܂��B
%
% ���
% -------
% rice �C���[�W�̃o�b�N�O�����h���v�Z���A����Ƃ̏��Z���s���܂��B
%
%       I = imread('rice.tif');
%       blocks = blkproc(I,[32 32],'min(x(:))');
%       background = imresize(blocks,[256 256],'bilinear');
%       Ip = imdivide(I,background);
%       imshow(Ip,[])
%
%  �C���[�W��萔�ŏ��Z���܂��B
%
%       I = imread('rice.tif');
%       J = imdivide(I,2);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(J)
%
% �Q�l�F IMADD, IMCOMPLEMENT, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 



%   Copyright 1993-2002 The MathWorks, Inc.

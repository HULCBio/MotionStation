% IMSUBTRACT  2�̃C���[�W�̌��Z�A�܂��́A�C���[�W����萔�����Z
% Z = IMSUBTRACT(X,Y) �́A�z�� X �̒��̊e�v�f�ɔz�� Y �̒��̑Ή�����v
% �f�������A�o�͔z�� Z �̒��̑Ή�����v�f�ɏo�͂��܂��BX �� Y �́A����
% �T�C�Y�A�N���X�̎����A��X�p�[�X�A���l�z��ł��B�܂��AY �̓X�J���� 
% double �ł��\���܂���BZ �́AX �Ɠ����T�C�Y�A�N���X�ɂȂ�܂��B
%
% X �������z��̏ꍇ�A�����^�C�v�͈̔͂𒴂���o�͗v�f�́A�ł��؂��A
% �����_�ȉ��͊ۂ߂��܂��B
%
% X �� Y �� double �z��̏ꍇ�A���̊֐��̑���ɁAX-Y ���g�����Ƃ��ł�
% �܂��B
%
% ���
% -------
% rice �C���[�W�̃o�b�N�O�����h���v�Z���A�����Z���܂��B
%       I = imread('rice.tif');
%       blocks = blkproc(I,[32 32],'min(x(:))');
%       background = imresize(blocks,[256 256],'bilinear');
%       Ip = imsubtract(I,background);
%       imshow(Ip,[])
%
% rice �C���[�W����萔�l�������܂��B
%       I = imread('rice.tif');
%       Iq = imsubtract(I,50);
%       subplot(1,2,1), imshow(I)
%       subplot(1,2,2), imshow(Iq)
%
% �Q�l�F IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMMULTIPLY.



%   Copyright 1993-2002 The MathWorks, Inc. 

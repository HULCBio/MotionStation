% IMABSDIFF 2�̃C���[�W�̍��̐�Βl���v�Z
% Z = IMABSDIFF(X,Y) �́A�z�� X �̒��̊e�v�f����A�Ή�����z�� Y �̗v�f
% �������A���̐�Βl���o�͔z�� Z �ɏo�͂��܂��BX �� Y �́A�����N���X��
% �T�C�Y���������A��X�p�[�X�A���l�z��ł��BZ �́AX �� Y �Ɠ����N���X�A
% �T�C�Y�������Ă��܂��BX �� Y �������z��̏ꍇ�A�����^�C�v�͈̔͂𒴂�
% ���o�͓��̗v�f�́A�ł��؂��܂��B
%
% X �� Y �� double �z��̏ꍇ�A���̊֐��̑���ɁAABS(X-Y) ���g�����Ƃ�
% �ł��܂��B
%
% ���
% -------
% �t�B���^�����O�����C���[�W�ƃI���W�i���C���[�W�̊Ԃ̍��̐�Βl��\����
% �܂��B
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imabsdiff(I,J);
%       imshow(K,[])
%
% �Q�l�FIMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.  



%   Copyright 1993-2002 The MathWorks, Inc.

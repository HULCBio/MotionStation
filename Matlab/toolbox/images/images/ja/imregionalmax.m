% IMREGIONALMAX �@I �̒n��I�ȍő�l�̏W�܂���v�Z
%
% BW = IMREGIONALMAX(I) �́AI �̒n��I�ȍő�l�̏W�܂���v�Z���܂��B
% IMREGIONALMAX �́AI �Ɠ����T�C�Y�̃o�C�i���C���[�W BW ���o�͂��܂��B
% ����́AI �̒��̒n��I�ȍő�l�̏W�܂�̈ʒu�̎��ʂ��������̂ł��B
% BW �̒��ŁA1�ɐݒ肳��Ă���s�N�Z���́A�n��I�ȍő�l�̏W�܂�Ƃ��A
% ���ׂĂ̑��̃s�N�Z���́A0�ɐݒ肳��܂��B
%
% �n��I�ȍő�l�̏W�܂�́A�������x�l t �����s�N�Z���̘A�������ł��B
% ���̎���̃s�N�Z���́At ��菬�����l�ł��B
%
% �f�t�H���g�ŁAIMREGIONALMAX �̎g�p����A���x�́A2�����̏ꍇ8�A3����
% �̏ꍇ26�ŁA�������̏ꍇ�ACONNDEF(NDIMS(I),'maximal') �ł��B
%
% BW = IMREGIONALMIN(I,CONN) �́A�ݒ肵���A�����g���āAI �̒n��I�ȍő�
% �l�̏W�܂���v�Z���܂��BCONN �́A���̒l�̂����ꂩ��ݒ肵�܂��B
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s���
% �g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN �̒�
% �S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂��āA��
% �̂ł���K�v������܂��B
%
% �N���X�T�|�[�g
% -------------
% I �́A�C�ӂ̔�X�p�[�X�Ȑ��l�N���X�A�C�ӂ̎����������Ă��܂��BBW �́A
% logical �ł��B
%
% ���
% -------
%       A = 10*ones(10,10);
%       A(2:4,2:4) = 22;    % �������maxima 12 ����
%       A(6:8,6:8) = 33;    % �������maxima 23 ����
%       A(2,7) = 44;
%       A(3,8) = 45;
%       A(4,9) = 44
%       regmax = imregionalmax(A)
%
% �Q�l�F CONNDEF, IMRECONSTRUCT, IMREGIONALMIN.



%   Copyright 1993-2002 The MathWorks, Inc.

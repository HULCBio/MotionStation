% IMREGIONALMIN I �̒n��I�ȍŏ��l�̏W�܂���v�Z
% BW = IMREGIONALMIN(I) �́AI �̒n��I�ȍŏ��l�̏W�܂���v�Z���܂��B
% �o�͂̃o�C�i���C���[�W BW �́A�n��I�ȍŏ��l�̏W�܂�ɑ�������̂ɂ�1
% �̃s�N�Z�����A���ׂĂ̑��̃s�N�Z���́A0�ɐݒ肳��܂��BBW �� I �Ɠ���
% �T�C�Y�ł��B
%
%�n��I�ȍŏ��l�̏W�܂�́A�������x�l t �����s�N�Z���̘A�������ł��B
% ���̎���̃s�N�Z���́At ���傫���l�ł��B
%
%�f�t�H���g�ŁAIMREGIONALMIN �̎g�p����A���x�́A2�����̏ꍇ8�A3�����̏�
% ��26�ŁA�������̏ꍇ�ACONNDEF(NDIMS(I),'maximal') �ł��B
%
% BW = IMREGIONALMIN(I,CONN) �́A�ݒ肵���A�����g���āAI �̒n��I�ȍŏ�
% �l�̏W�܂���v�Z���܂��BCONN �́A���̒l�̂����ꂩ��ݒ肵�܂��B
%
% BW = IMREGIONALMIN(I,CONN) �́A�ݒ肵���A�����g���āAI �̒n��I�ȍŏ�
% �l�̏W�܂���v�Z���܂��BCONN �́A���̃X�J���l�̂����ꂩ��ݒ肵�܂��B
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s���
% �g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN ��
% ���S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂��āA
% �Ώ̂ł���K�v������܂��B
%
% �N���X�T�|�[�g
% -------------
% I �́A�C�ӂ̔�X�p�[�X�Ȑ��l�N���X�ŁA�C�ӂ̎����ł��BBW �́A��ɁA
% logical �ł��B
%
% ���
% -------
%       A = 10*ones(10,10);
%       A(2:4,2:4) = 3;       % ������ minima 3 ������
%       A(6:8,6:8) = 8        % ������ minima 8 ������
%       regmin = imregionalmin(A)
%
% �Q�l�F CONNDEF, IMRECONSTRUCT, IMREGIONALMIN.



%   Copyright 1993-2002 The MathWorks, Inc.

% SPMAK   B-�^�̃X�v���C���̑g����
%
% SPMAK(KNOTS,COEFS) �́A�ߓ_�ƌW������X�v���C����g���Ă܂��BSIZEC �́A
% size(COEFS) �Ƃ��܂��B�X�v���C���́ASIZEC(1:end-1)�̒l�Ƃ��ē����A
% �䂦�ɁA�S���� n = SIZEC(end) �̌W��������܂��B
% �X�v���C���̎����́Ak := length(KNOTS) - n �Ɛ��肳��܂��B
% �ߓ_���d�x�́A�d�v�łȂ��T�|�[�g������B-�X�v���C���ɑΉ�����W����
% ��������A<= k �ɕۂ���܂��B
%
% SPMAK �́AKNOTS �� COEFS �̓��͂𑣂��܂��B
%
% KNOTS ������ m �̃Z���z��̏ꍇ�ACOEFS �́A���Ȃ��Ƃ�m�����łȂ����
% �Ȃ�܂���B���Ȃ킿�Alength(SIZEC) �͏��Ȃ��Ƃ� m �łȂ���΂Ȃ��
% ����BCOEFS ��m�����̏ꍇ�A�X�v���C���̓X�J���l�Ƃ��ē����A����ȊO
% �́ASIZEC(1:end-m)�̒l�Ƃ��ē����܂��B
%
% SPMAK(KNOTS,COEFS,SIZEC) �́ACOEFS �̈Ӑ}���ꂽ�z��̎������w�肷��
% ���߂� SIZEC ���g�p���܂��B��ɂÂ�������1�ȏオ�v�f��1�̎����ŁA
% ���̂��߂� COEFS �����Ⴂ�����Ō���Ă��܂��ꍇ�ɁACOEFS �̓K�؂�
% ���߂̂��߂ɕK�v�ɂȂ�\��������܂��B
%
% �Ⴆ�΁A���̖ړI���l�p�` [-1 .. 1] x [0 .. 1] ���2�v�f�x�N�g���l��
% 2�ϐ����������쐬���邱�Ƃł���A�ŏ��̕ϐ��͐��`�ŁA2�Ԗڂ͒萔�ŁA
% ����
%      coefs = zeros([2 2 1]); coefs(:,:,1) = [1 0;0 1];
% ���Ƃ���ƁA�P�������ȋL�q
%      sp = spmak({[-1 -1 1 1],[0 1]},coefs);
% �́A(�s����)���� [2 0] �̃X�J���l�֐��𐶐����Ď��s���܂��B
%      sp = spmak({[-1 -1 1 1],[0 1]},coefs,size(coefs));
% �����l�ł��B����A3�Ԗڂ̈�����
%      sp = spmak({[-1 -1 1 1],[0 1]},coefs,[2 2 1]);
% �Ƃ��Đ��m�Ɏg�p����Ɛ������܂��B
%
% �Q�l : SPBRK, RSMAK, PPMAK, RPMAK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

%BITMAX �ő�̕��������_����
% BITMAX �́A�ő�̕����Ȃ��{���x���������_�������o�͂��܂��B 
% ���ׂẴr�b�g���ݒ肳���Ƃ��A���̒l (2^53-1) �ɂȂ�܂��B
%
% �����l�̔{���x�ϐ��ł͂Ȃ��A�r�b�g����ɕ����Ȃ��������g�p���A
% BITMAX �� INTMAX �Œu�������Ă��������B
%
% ���:
% �ő�̕��������_�����ƍő�� 32 �r�b�g�����Ȃ�������
% �قȂ�`���ŕ\�����܂��B
%      >> format long e
%      >> bitmax
%      ans =
%          9.007199254740991e+015
%      >> intmax('uint32')
%      ans =
%        4294967295
%      >> format hex
%      >> bitmax
%      ans =
%         433fffffffffffff
%      >> intmax('uint32')
%      ans =
%         ffffffff
%
% ����: BITMAX �̍Ō�� 13 hex digits �́A�o�C�i���\���̉�����
% 52 �� 1 (���ׂ� 1) �ɑ�������A"f" �ł��B�ŏ��� 3 hex digits �́A
% sign �r�b�g 0 �� 11 �r�b�g�̃o�C�i���Ńo�C�A�X���ꂽ�w�� 10000110011 
% (10�i���� 1075) �ɑ������A���ۂ̎w���́A(1075-1023)=52 �ł��B�������āA
% BITMAX �̃o�C�i���l�́A52 �� 1 ������ 1.111...111x2^52, ���Ȃ킿�A
% 2^53-1 �ł��B
%
% �Q�l INTMAX, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, BITSET, BITGET.

%   Copyright 1984-2004 The MathWorks, Inc. 

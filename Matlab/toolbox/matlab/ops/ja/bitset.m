%BITSET �r�b�g�̐ݒ�
% C = BITSET(A,BIT) �́AA ���̃r�b�g�̈ʒu BIT �� 1(on) �ɐݒ肵�܂��B
% A �́A�����Ȃ������ŁABIT �́A1 �� A�@�̕����Ȃ������N���X�̃r�b�g�̒���
% ( UINT32 �ł� 32 ) �̊Ԃ̒l�łȂ���΂Ȃ�܂���B
%
% C = BITSET(A,BIT,V) �́A�ʒu BIT �ɂ���r�b�g��l V �ɐݒ肵�܂��B 
% V �� 0 �܂��� 1 �̂����ꂩ�łȂ���΂Ȃ�܂���B
%
% ���:
%  �ő�� UINT32 �̒l���� 2 �̗ݏ���J��Ԃ������܂��B
%
%    a = intmax('uint32')
%    for i = 1:32, a = bitset(a,32-i+1,0), end
%
% �Q�l BITGET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 

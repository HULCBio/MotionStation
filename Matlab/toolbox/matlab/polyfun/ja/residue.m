% RESIDUE   ���������W�J(residues)
% 
% [R,P,K] = RESIDUE(B,A) �́A2�̑������̔� B(s)/A(s) �𕔕������W�J
% ���āA�����A�ɁA���ڍ������߂܂��B�d�����Ȃ��ꍇ�́A���̂悤�ɂȂ�
% �܂��B
% 
%    B(s)       R(1)       R(2)             R(n)
%    ----  =  -------- + -------- + ... + -------- + K(s)
%    A(s)     s - P(1)   s - P(2)         s - P(n)
% 
% �x�N�g�� B �� A �́As �̍~�ׂ����ɑ������̕��q�ƕ���̌W�����w�肵�܂��B
% �����͗�x�N�g�� R �ɏo�͂���A�ɂ̈ʒu�͗�x�N�g�� P�ɁA���ڍ���
% �s�x�N�g�� K �ɏo�͂���܂��B�ɂ̌��́A
% n = length(A)-1 = length(R) = length(P)
% �ł��B���ڍ��̌W���x�N�g���́Alength(B) < length(A) �Ȃ�΋�ŁA������
% �Ȃ���� length(K) = length(B)-length(A)+1 �ɂȂ�܂��B
%
% P(j) = ... = P(j+m-1) �����d�x m �̋ɂł���΁A�W�J�͂��̌^�̍���
% �܂ނ��ƂɂȂ�܂��B
%
%               R(j)        R(j+1)                R(j+m-1)
%            -------- + ------------   + ... + ------------
%            s - P(j)   (s - P(j))^2           (s - P(j))^m
%
% 3�̓��͈����ƁA2�̏o�͈��������� [B,A] = RESIDUE(R,P,K) �́AB �� 
% A �̌W�����g���ĕ��������W�J�𑽍����ɕϊ����܂��B
%
% ���[�j���O : ���l�I�ɁA�������̔䂩��̕��������W�J�́A�������̈���
% ���ɂȂ�܂��B���ꑽ���� A(s) ���d�������������ɋ߂��ꍇ�́A�ۂ�
% �덷���܂ރf�[�^�̏����ȕω��ɂ��A�ɂ◯���̌��ʂ͑傫���ω����܂��B
% ��ԋ�Ԃ܂��͗�_-�ɕ\�����g�������̒莮���̕����D�܂����Ƃ����܂��B
%
% ���� B,A,R �̃T�|�[�g�N���X
%   float: double, single
%
% �Q�l POLY, ROOTS, DECONV.

%   Reference:  A.V. Oppenheim and R.W. Schafer, Digital
%   Signal Processing, Prentice-Hall, 1975, p. 56-58.

%   Copyright 1984-2004 The MathWorks, Inc.
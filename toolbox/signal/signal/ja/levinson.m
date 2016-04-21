% LEVINSON  Levinson-Durbin �A�[�@
%
% A = LEVINSON(R,N)�́AYule-Walker AR�������Ƃ��Ēm���� Hermition To-
% eplitz �V�X�e��
%
%     [  R(1)   R(2)* ...  R(N)* ] [  A(2)  ]  = [  -R(2)  ]
%     [  R(2)   R(1)  ... R(N-1)*] [  A(3)  ]  = [  -R(3)  ]
%     [   .        .         .   ] [   .    ]  = [    .    ]
%     [ R(N-1) R(N-2) ...  R(2)* ] [  A(N)  ]  = [  -R(N)  ]
%     [  R(N)  R(N-1) ...  R(1)  ] [ A(N+1) ]  = [ -R(N+1) ]
%
% ���ALevinson-Durbin �A�[�@���g���ĉ����܂��B���� R �́A�ŏ��̗v�f���[
% �����O�������ȑ��֗�W��(�x�N�g��)�ł��B
%
% N �́A���ȉ�A���`�ߒ��̌W���ł��BN ���ȗ�����ƁAN �́AN = LENGTH(R)-1
% �ɐݒ肳��܂��BA �́AA(1) = 1.0�������� N+1 �̍s�x�N�g���ł��B
%
% [A,E] = LEVINSON(...) �́A���� N �̗\���덷E���o�͂��܂��B
%
% [A,E,K] = LEVINSON(...) �́A���� N �̗�x�N�g���������ˌW�� K ���o��
% ���܂��B�W�� A ���v�Z����ԂɁAK �������Ōv�Z�����̂ŁAK �𓯎��ɏo
% �͂���A���̂��߁ATF2LATC ���g���āAA �� K �ɕϊ�������������I�Ɍv
% �Z����܂��B
%
% R ���s��̏ꍇ�ALEVINSON �́AR �̊e��ɑ΂��ČW�������߁AA�̍s�x�N�g��
% �ɏo�͂��܂��B
%
% �Q�l�F   LPC, PRONY, STMCB.



%   Copyright 1988-2002 The MathWorks, Inc.

% NORMHINF   �A���n��H���m����
%
% [NMHINF] = NORMHINF(A,B,C,D,tol)�A�܂��́A[NMHINF] = NORMHINF(SS_,tol)�́A
% �^����ꂽ��ԋ�Ԏ�����HINF�m�������v�Z���܂��B�����ł́A���̃n�~���g
% �j�A���̋�����ŌŗL�l�̓񕪒T���@���̗p���Ă��܂��B
%
%                        -1           -1
%       H(gam) = | A + BR  D'C     -BR  B'        |
%                |       -1                -1     |
%                |C'(I+DR  D')C    -(A + BR  D'C)'|
%
% �����ŁAR = gam^2 I - D'D > 0�ł��BH��������ɌŗL�l�����Ƃ��AHINF�m��
% ����"gam"�Ɠ������Ȃ�܂��B
%
% HINF�m�����̏�E�Ɖ��E�̏�������́A���̂悤�ɂȂ�܂��B
%
%       ��E: max_sigma(D) + 2*sum(Hankel SV(G))
%       ���E: max{max_sigma(D), max_Hankel SV(G)}
%
% �T�[�`�A���S���Y���́A2�̗אڂ���"gam's"�̑��Ό덷��"tol"����������
% �Ƃ��ɏI�����܂��B"tol"���^�����Ȃ���΁Atol = 0.001�ł��B



% Copyright 1988-2002 The MathWorks, Inc. 

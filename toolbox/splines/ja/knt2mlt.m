% KNT2MLT   �ߓ_�̑��d�x
%
% KNT2MLT(T) �́A�ߓ_�̑��d�x�̃x�N�g�� M ���o�͂��܂��B�������́A
%
% i=1:length(T) �Ƃ��āAM(i) = # { j<i : T(j) = T(i) }
%
% �ƂȂ�A���͂����ёւ����Ă��Ȃ��ꍇ�AT �͂����ōŏ��ɕ��ёւ����
% �܂��B
%
% [M,T] = KNT2MLT(T) �́A���ёւ����ߓ_����o�͂��܂��B
%
% ���Ƃ��΁A[m,t] = knt2mlt([ 1 2 3 3 1 3]) �́Am �ɑ΂��� [0 1 0 0 1 2] 
% ���o�͂��At �ɑ΂��� [1 1 2 3 3 3] ���o�͂��܂��B
%
% �Q�l : KNT2BRK, BRK2KNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 

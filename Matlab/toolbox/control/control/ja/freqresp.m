% FREQRESP   LTI ���f���̎��g���������v�Z
%
%
% H = FREQRESP(SYS,W) �́A�x�N�g�� W �Ŏw�肳�����g���ł� LTI ���f�� SYS
% �̎��g������ H ���v�Z���܂��B�����̎��g���́A�����Ń��W�A��/�b�ł��B
%
% SYS �� NU ���� NY �o�͂ŁAW �� NW �̎��g���_�����Ƃ��A�o�� H ��
% NY*NU*NW �̔z��ɂȂ�AH(:,:,k) �͎��g���_ W(k) �ł̉�����^���܂��B
%
% SYS �� Nu ���� NY �o�͂�����LTI���f���� S1*...*Sp �z��̂Ƃ��A
% SIZE(H) = [NY NU NW S1 ... Sp] �ł��B �����ŁANW = LENGTH(W) �ł��B
%
% �Q�l : EVALFR, BODE, SIGMA, NYQUIST, NICHOLS, LTIMODELS


% Copyright 1986-2002 The MathWorks, Inc.

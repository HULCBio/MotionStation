% XCOV �́A���݋����U�֐��𐄒肵�܂��B
% ���݋����U�́A2�̐��񂩂炨�݂��ɕ��ϒl�������������ʂ̑��ݑ��֊֐�
% �ł��BXCOV(A,B) �́A���� 2*M-1 �̑��݋����U������x�N�g���ɏo�͂���
% ���B�����ŁAA �� B �́A���� M �̃x�N�g���ł��B

% XCOV(A) �́AA ���x�N�g���̏ꍇ�A���ȋ����U��ŁAM �s N ��̍s��̏ꍇ�A
% A �̗�̂��ׂĂ̑g�ݍ��킹�ɑ΂��āA���݋����U����܂�2*M-1 �s N^2 ��
% �̑傫���̍s����o�͂��܂��B�o�͋����U�̃[�����O�́A�f�[�^��̒��S�AM �s
% �ڂɂȂ�܂��B
%
% ���݋����U�́A���ς���菜����2�̐���̑��ݑ��֊֐��ł��B
%        C(m) = E[(A(n+m)-MA)*conj(B(n)-MB)] 
% �����ŁAMA��MB�́A���ꂼ��A��B�̕��ςł��B
%
% XCOV(...,MAXLAG) �́A���O-MAXLAG ���� MAXLAG �͈̔͂ŁA���Ȃ킿�A2*M-
% AXLAG+1 ���O��(����)�����U���v�Z���܂��B�f�t�H���g�́AMAXLAG = M-1�ł��B
% 
% [C,LAGS] = XCOV(...)�́A���O�̃C���f�b�N�X�̃x�N�g��(LAGS)���o�͂��܂��B
%
% XCOV(...,SCALEOPT)�́ASCALEOPT�ɏ]���āA���U�𐳋K�����܂��B:
%
%     biased   - 1/M�ő��ݑ��֊֐����X�P�[�����O
%     unbiased - 1/(M-abs(lags))�ő��ݑ��֊֐����X�P�[�����O
%     coeff    - �[���x��ł̎��ȑ��ւ��A1.0�ɂȂ�悤�ɐ��K�����܂��B
%     none     - �X�P�[�����O�Ȃ�(�f�t�H���g).
% 
% �Q�l�F   XCORR, CORRCOEF, CONV, COV ,XCORR2.



%   Copyright 1988-2002 The MathWorks, Inc.

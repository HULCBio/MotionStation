% XCORR   ���ݑ��֊֐��̐���
%
% C = XCORR(A,B) �́A���� 2M-1(M>1)�̑��ݑ��֗� C ���x�N�g���ɏo�͂��܂��B
% �����ŁAA �� B �́A���� M �̃x�N�g���ł��BA �� B �����������łȂ��ꍇ�A
% �Z���ق��̃x�N�g���Ƀ[����t�����A�����ق��̃x�N�g���Ɠ��������ɂ��܂��B
% A ���s�x�N�g���̏ꍇ�AC �͍s�x�N�g���ɂȂ�܂��B�܂��AA ����x�N�g����
% �ꍇ�AC �͗�x�N�g���ɂȂ�܂��B
%
% XCORR�́A2�̃����_���Ȑ���Ԃ̑��ւ̐�����o�͂��܂�:
%          C(m) = E[A(n+m)*conj(B(n))] = E[A(n)*conj(B(n-m))]
% ����́A2�̊m��I�ȐM���Ԃ̊m��I���ւł�����܂��B
%
% XCORR(A)�́AA ���x�N�g���̏ꍇ�A���ȑ��֗���o�͂��܂��BXCORR(A)�́AA 
% �� M �s N ��̍s��̏ꍇ�AN^2�� A �̗�̂��ׂĂ̑g�����ɑ΂��鑊�ݑ�
% �֗���܂� 2M-1 �s�̍s����o�͂��܂��B�o�͂̃[�����O�ɑΉ�������̂́A
% �e�v�f�܂��́AM �s�ɑ΂��ďo�͗�̒����ɂȂ�܂��B
%
% XCORR(...,MAXLAG) �́A���O��[-MAXLAG:MAXLAG]�͈̔͂ɂ��āA���ݑ��֗�
% ���v�Z���A�o�� C �̒����́A2*MAXLAG+1 �ł��B�f�t�H���g�ŁAMAXLAG = M-1 ��
% �Ȃ�܂��B
%
% [C,LAGS] = XCORR(...) �́A���O�̃C���f�b�N�X�x�N�g��(LAGS)���o�͂��܂��B
%
% XCORR(...,SCALEOPT)�́ASCALEOPT�ɏ]���āA���ւ𐳋K�����܂��B:
%
%     biased   - 1/M�ő��ݑ��֊֐����X�P�[�����O
%     unbiased - 1/(M-abs(lags))�ő��ݑ��֊֐����X�P�[�����O
%     coeff    - �[���x��ł̎��ȑ��ւ��A1.0�ɂȂ�悤�ɐ��K�����܂��B
%     none     - �X�P�[�����O�Ȃ�(�f�t�H���g).
%
% �Q�l�F   XCOV, CORRCOEF, CONV, COV, XCORR2.



%   Copyright 1988-2002 The MathWorks, Inc.

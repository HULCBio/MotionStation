% FREQRESP �́AIDMODEL ���f���̎��g���������v�Z���܂��B
%
% H = FREQRESP(M,W) �́A�x�N�g�� W �Ŏw�肵�����g���ŁAIDFRD ���f�� M ��
% ���g������ H ���v�Z���܂��B�����̎��g���́A�����ŁArad/sec�ł��BW ��
% �ȗ������ƁA�f�t�H���g�̎��g���͈͂��I������܂��B
% 
% M ���ANY �o�́ANU ���͂������AW ��NW �̎��g�����܂�ł���ꍇ�AH(:,:
% ,k) ���A���g�� W(k) �̉�����\�킷�ANY-NU-NW �z��ł��� H ���o�͂��܂��B
%
% SISO ���f���ɑ΂��āASQUEEZE(H) ���g���āA���g�������x�N�g���𓾂邱��
% ���ł��܂��B
%
% [H,W,covH] = FREQRESP(M,W) �́A���g�� W �Ɖ����̋����U covH ���o�͂���
% ���BcovH ��5D �z��ŁAcovH(KY,KU,k,:,:)�́A���� KU ����o�� KY �܂ł�
% ���g�� W(k)�ł�2�s2��̋����U�s��ł��B(1,1)�v�f�͎������̕��U�A(2,2)
% �v�f���������̕��U�A(1,2)��(2,1)�v�f�́A�����Ƌ������Ԃ̋����U�ł��B
% SQUEEZE(covH(KY,KU,k,:,:)) �́A�Ή����鉞���̋����U�s���^���܂��B
%
% M �����n��̏ꍇ�AH �́A�o�͂̃X�y�N�g���Ƃ��ďo�͂���܂��B���Ȃ킿�A
% NY-NY-NW �z��ɂȂ�܂��BH(:,:,k) �́A���g�� W(k) �ł̃X�y�N�g���s���
% ���B�v�f H(K1,K2,k) �́A���g�� W(k) �ł̏o�� K1 �� K2 �Ƃ̃N���X�X�y�N
% �g���ł��BK1 = K2 �̏ꍇ�A����́A�o��K1 �̎����l�p���[�X�y�N�g���ɂ�
% ��܂��BcovH �́A�X�y�N�g�� H �̋����U�ɂȂ�A����ŁAcovH(K1,K1,k) ��
% ���g�� W(k) �ł̃p���[�X�y�N�g���o�� K1 �̕��U�ɂȂ�܂��B�N���X�X�y�N
% �g���̕��U�Ɋւ�����́A�ʏ�A�^�����܂���(K1 �� K2 �ɓ������Ȃ���
% ���AcovH(K1,K2,k) = 0 �ɂȂ�܂�)�B
%
% ���f�� M �����n��łȂ��ꍇ�A�m�C�Y(�o�͏)�M���̃X�y�N�g������
% ��ɂ́AFREQRESP(m('n')) ���g���܂��B



%   Copyright 1986-2001 The MathWorks, Inc.
% EVCDF   �ɒl���z�̗ݐϕ��z�֐�(cdf)
%
% P = EVCDF(X,MU,SIGMA) �́A�ʒu�p�����[�^ MU �ƃX�P�[���p�����[�^ SIGMA 
% ������ X �̒l�ŕ]�����ꂽ�^�C�v1�̋ɒl���z�̗ݐϕ��z�֐����o�͂��܂��B
% P �̑傫���́A���͈����Ɠ����傫���ł��B�X�J�����͂́A���̓��͂Ɠ���
% �傫���̒萔�s��Ƃ��ċ@�\���܂��B
%
% MU �� SIGMA �ɑ΂���f�t�H���g�l�́A���ꂼ��0��1�ł��B
%
% [P,PLO,PUP] = EVCDF(X,MU,SIGMA,PCOV,ALPHA) �́A���̓p�����[�^ MU �� 
% SIGMA �����肳���Ƃ��AP �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A����
% ���ꂽ�p�����[�^�̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A0.05��
% �f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BPLO �� PUP �́A
% �M����Ԃ̉����Ə�����܂� P �Ɠ����傫���̔z��ł��B
%
% �^�C�v1�̋ɒl���z�́A�ʖ�Gumbel���z�Ƃ��Ă��m���Ă��܂��BY �� 
% Weibull���z�̏ꍇ�AX=log(Y) �́A�^�C�v1�̋ɒl���z�ɂȂ�܂��B
%
% �Q�l : CDF, EVFIT, EVINV, EVLIKE, EVPDF, EVRND, EVSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/01/08 15:29:35 $

% EVINV   �ɒl���z�̋t�ݐϕ��z�֐�(cdf)
%
% X = EVINV(P,MU,SIGMA) �́A�ʒu�p�����[�^ MU �ƃX�P�[���p�����[�^ SIGMA
% ������ P �̒l�ŕ]�����ꂽ�^�C�v1�̋ɒl���z�ɑ΂���t�ݐϕ��z�֐���
% �o�͂��܂��BX �̑傫���́A���͈����Ɠ����傫���ł��B�X�J���̓��͂́A
% ��������̓��͂Ɠ����傫���̒萔�s��Ƃ��ċ@�\���܂��B
%   
% MU �� SIGMA �ɑ΂���f�t�H���g�l�́A���ꂼ��0��1�ł��B
%
% [X,XLO,XUP] = EVINV(P,MU,SIGMA,PCOV,ALPHA) �́A���̓p�����[�^ MU�� 
% SIGMA �����肳�ꂽ�Ƃ��AX �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A����
% ���ꂽ�p�����[�^�̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A0.05��
% �f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BXLO �� XUP �́A
% �M����Ԃ̉����Ə�����܂� X �Ɠ����傫���̔z��ł��B
%
% �^�C�v1�̋ɒl���z�́A�ʖ�Gumbel���z�Ƃ��Ă��m���Ă��܂��BY �� 
% Weibull���z�̏ꍇ�AX=log(Y) �́A�^�C�v1�̋ɒl���z�ɂȂ�܂��B
%
% �Q�l : EVCDF, EVFIT, EVLIKE, EVPDF, EVRND, EVSTAT, ICDF.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/08 15:29:33 $

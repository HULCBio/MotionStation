% LOGNINV   �ΐ����K���z�̋t�ݐϕ��z�֐�(cdf)
%
% X = LOGNINV(P,MU,SIGMA) �́A�ΐ����� MU �Ƒΐ��W���΍� SIGMA ������
% P �̒l�ŕ]�����ꂽ�ΐ����K���z�ɑ΂���t�ݐϕ��z�֐����o�͂��܂��BX ��
% �傫���́A���͈����Ɠ����傫���ł��B�X�J���̓��͂́A��������̓��͂�
% �����傫���̒萔�s��Ƃ��ċ@�\���܂��B
%
% MU �� SIGMA �ɑ΂���f�t�H���g�l�́A���ꂼ��A0��1�ł��B
%
% [X,XLO,XUP] = LOGNINV(P,MU,SIGMA,PCOV,ALPHA) �́A���̓p�����[�^ MU�� 
% SIGMA �����肳�ꂽ�Ƃ��AX �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A����
% ���ꂽ�p�����[�^�̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A0.05��
% �f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BXLO �� XUP �́A
% �M����Ԃ̉����Ə�����܂� X �Ɠ����傫���̔z��ł��B
%
% �Q�l : ERFINV, ERFCINV, LOGNCDF, LOGNFIT, LOGNLIKE, LOGNPDF,
%        LOGNRND, LOGNSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:46 $

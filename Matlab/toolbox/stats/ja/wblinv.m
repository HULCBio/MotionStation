% WBLINV   Weibull���z�̋t�ݐϕ��z�֐�(cdf)
%
% X = WBLINV(P,A,B) �́A�X�P�[���p�����[�^ A �ƌ`��p�����[�^ B ������
% P �̒l�ŕ]�����ꂽWeibull���z�ɑ΂���t�ݐϕ��z�֐����o�͂��܂��BX ��
% �傫���́A���͈����Ɠ����傫���ł��B�X�J���̓��͂́A��������̓��͂�
% �����傫���̒萔�s��Ƃ��ċ@�\���܂��B
%   
% A �� B �ɑ΂���f�t�H���g�l�́A���ꂼ��1��1�ł��B
%
% [X,XLO,XUP] = WBLINV(P,A,B,PCOV,ALPHA) �́A���̓p�����[�^ A �� B ������
% ���ꂽ�Ƃ��AX �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A���肳�ꂽ�p�����[�^
% �̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A0.05�̃f�t�H���g�l�ŁA
% 100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BXLO �� XUP �́A�M����Ԃ̉�����
% ������܂� X �Ɠ����傫���̔z��ł��B
%
% �Q�l : WBLCDF, WBLFIT, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, ICDF.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/09 21:47:38 $

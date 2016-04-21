% WBLCDF   Weibull���z�̗ݐϕ��z�֐�(cdf)
%
% P = WBLCDF(X,A,B) �́A�X�P�[���p�����[�^ A �ƌ`��p�����[�^ B ������
% X �̒l�ŕ]�����ꂽWeibull���z�̗ݐϕ��z�֐����o�͂��܂��BP �̑傫���́A
% ���͈����Ɠ����傫���ł��B�X�J�����͂́A���̓��͂Ɠ����傫���̒萔
% �s��Ƃ��ċ@�\���܂��B
%
% A �� B �ɑ΂���f�t�H���g�l�́A���ꂼ��0��1�ł��B
%
% [P,PLO,PUP] = WBLCDF(X,A,B,PCOV,ALPHA) �́A���̓p�����[�^ A �� B ��
% ���肳���Ƃ��AP �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A���肳�ꂽ
% �p�����[�^�̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A0.05��
% �f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BPLO �� PUP �́A
% �M����Ԃ̉����Ə�����܂� P �Ɠ����傫���̔z��ł��B
%
% �Q�l : CDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/01/09 21:47:34 $

% NORMCDF   ���K�ݐϕ��z�֐� (cdf)
%
% P = NORMCDF(X,MU,SIGMA) �́A���� MU �ƕW���΍� SIGMA ������ X �̒l��
% �]�����ꂽ���K�ݐϕ��z�֐����o�͂��܂��BP �̑傫���́AX�AMU�ASIGMA ��
% ���ʂ̑傫���ł��B�X�J�����͂́A���̓��͂Ɠ����傫���̒萔�s��Ƃ���
% �@�\���܂�
%
% MU �� SIGMA �̃f�t�H���g�l�́A���ꂼ��A0��1�ł��B
%
% [P,PLO,PUP] = NORMCDF(X,MU,SIGMA,PCOV,ALPHA) �A���̓p�����[�^ MU �� 
% SIGMA �����肳���Ƃ��AP �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A����
% ���ꂽ�p�����[�^�̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A0.05��
% �f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BPLO �� PUP �́A
% �M����Ԃ̉����Ə�����܂� P �Ɠ����傫���̔z��ł��B
%
% �Q�l : ERF, ERFC, NORMFIT, NORMINV, NORMLIKE, NORMPDF, NORMRND, NORMSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:14 $

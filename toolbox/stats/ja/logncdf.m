% LOGNCDF   �ΐ����K�ݐϕ��z�֐�
%
% P = LOGNCDF(X,MU,SIGMA) �́A�ΐ����ϒl MU�A�ΐ��W���΍� SIGMA ������
% X �̒l�ŕ]�����ꂽ�ΐ����K�ݐϕ��z�֐����o�͂��܂��BP �̑傫���́A
% ���͈����Ɠ����傫���ł��B�X�J�����͂́A���̓��͂Ɠ����傫���̒萔
% �s��Ƃ��ċ@�\���܂��B
% 
% MU �� SIGMA �̃f�t�H���g�l�́A���ꂼ��0��1�ł��B
%
% [P,PLO,PUP] = LOGNCDF(X,MU,SIGMA,PCOV,ALPHA) �́A���̓p�����[�^ MU 
% �� SIGMA �����肳���Ƃ��AP �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A
% ���肳�ꂽ�p�����[�^�̋����U�s����܂�2�s2��̍s��ł��BALPHA �́A
% 0.05�̃f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ��w�肵�܂��BPLO �� 
% PUP �́A�M����Ԃ̉����Ə�����܂� P �Ɠ����傫���̔z��ł��B
%
% �Q�l : ERF, ERFC, LOGNFIT, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND, LOGNSTAT


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:43 $

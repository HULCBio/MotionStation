% EXPINV   �w�����z�̋t�ݐϕ��z�֐�
%
% X = EXPINV(P,MU) �́A�ʒu�p�����[�^ MU ������ P �̒l�ŕ]�����ꂽ�w��
% ���z�̋t�ݐϕ��z�֐����o�͂��܂��BX �̑傫���́A���͈����Ɠ���
% �傫���ł��B�X�J���̓��͂́A���̓��͂Ɠ����傫���̒萔�s��Ƃ��ċ@�\
% ���܂��B
%
% MU �ɑ΂���f�t�H���g�l��1�ł��B
%
% [X,XLO,XUP] = EXPINV(P,MU,PCOV,ALPHA) �́A���̓p�����[�^ MU�����肳�ꂽ
% �Ƃ��AX �ɑ΂���M����Ԃ𐶐����܂��BPCOV �́A���肳�ꂽ�p�����[�^��
% ���U�ł��BALPHA �́A0.05�̃f�t�H���g�l�ŁA100*(1-ALPHA)% �̐M����Ԃ�
% �w�肵�܂��BXLO �� XUP �́A�M����Ԃ̉����Ə�����܂� X �Ɠ����傫����
% �z��ł��B���E�́AMU �̐���̑ΐ����z�ɑ΂���ʏ�̋ߎ��Ɋ�Â��܂��B
% MU �ɑ΂���M����Ԃ𓾂邽�߂ɁAEXPFIT ���g�p���A���̋�Ԃ̉�����
% ����̏I�_�� EXPINV ��]�����邱�Ƃɂ���āA�ȒP�ɋ��E�̂�萳�m��
% �ݒ�𓾂邱�Ƃ��ł��܂��B
%
% �Q�l : EXPCDF, EXPFIT, EXPLIKE, EXPPDF, EXPRND, EXPSTAT, ICDF.


%     Copyright 1993-2003 The MathWorks, Inc. 
%     $Revision: 1.6 $  $Date: 2003/02/12 17:07:14 $

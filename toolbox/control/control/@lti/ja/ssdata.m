% SSDATA   ��ԋ�ԃf�[�^�ւ̃N�C�b�N�A�N�Z�X
%
%
% [A,B,C,D] = SSDATA(SYS) �́A��ԋ�ԃ��f��SYS�Ɋւ���s��f�[�^ A,B,C,D��
% �o���܂��BSYS ����ԋ�ԃ��f���łȂ��ꍇ�A���炩���ߏ�ԋ�ԕ\���ɕϊ�����
% ���B
%
% [A,B,C,D,TS] = SSDATA(SYS) �́A�T���v������ TS ���o�͂��܂��B
% SYS �̂��̑��̃v���p�e�B�́AGET ��p���Ē��o���邩�A���ړI�ɍ\���̃��C�N��
% �����ŎQ�Ƃł��܂�(���Ƃ��΁ASYS.Ts)�B
%
% ��������(��Ԃ̐�)�� SS ���f���̔z��̏ꍇ�ASSDATA �́A�������z�� A,B,C,
% D ���o�͂��܂��B �����ŁA A(:,:,k), B(:,:,k), C(:,:,k), D(:,:,k) �́Ak�Ԗڂ�
% ���f�� SYS(:,:,k) �̏�ԋ�ԍs���^���܂��B
%
% �����̈قȂ�LTI���f���ɑ΂��āA�Z���z��̒��̉σT�C�Y�̍s�� A,B,C,D����
% �����߂邽�߂ɂ́A���̏����𗘗p���Ă��������B [A,B,C,D] = SSDATA(SYS,'
% cell')
%
% �Q�l : SS, GET, DSSDATA, TFDATA, ZPKDATA, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.

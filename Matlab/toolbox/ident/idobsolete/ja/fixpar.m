% FIXPAR   ��ԋ�Ԃ� ARX �̃��f���\���ɑ΂��Ĉꕔ�̃p�����[�^���Œ�
%   
%   TH = FIXPAR(TH_OLD,MATRIX,ELEMENTS,PARAMETERVALUES)
%
%   TH       : �X�V���ꂽ theta �s��
%   TH_OLD   : �X�V�O�� theta �s��
%   MATRIX   : �ǂ̍s��𑀍삷�邩�̎w��
%              ('A','B','C','D','K','X0'�̂ǂꂩ)
%   ELEMENTS : �ǂ̗v�f�𑀍삷�邩�̎w��Bn �s2��̍s��B
%              �����ŁA�e�s�͗v�f�̍s�Ɨ�̔ԍ��ł��B
%              ���̈������ȗ����ꂽ�ꍇ�A�s��̂��ׂĂ̗v�f���Œ肵�܂��B
%   PARAMETERVALUES : 
%              �V���ɌŒ肳���p�����[�^�l�B
%              n �v�f�̃x�N�g���B���̈������ȗ͂��ꂽ�ꍇ�A�p�����[�^�́A
%              TH_OLD �̌��݂̐���l�ɌŒ肳��܂��B
%
% MATRIX �� 'A1','A2',...��'B0','B1',...�ƒ�`�����ƁAARX �\���̑Ή���
% ��s�񂪑��삳��A��`���ꂽ TH_OLD ���X�V����܂��B
%
% ��: 
% 
%   th1 = FIXPAR(th,'A',[3,1;2,2;1,3])
%
% ����: 
% FIXPAR �́AMS2TH,ARX2TH,ARX �Œ�`���ꂽ�W���I�ȃ��f���\���ɑ΂��Ă̂�
% �@�\���܂��BTH_OLD �����[�U��`�̍\���Ɋ�Â��ꍇ�APEM ��3�Ԗڂ̈��� 
% INDEX �𗘗p���邱�ƂŁATHINIT �Ɠ������ʂ𓾂邱�Ƃ��ł��܂��B
%
% �Q�l:    ARX, ARX2TH, MS2TH, PEM, UNFIXPAR.

%   Copyright 1986-2001 The MathWorks, Inc.

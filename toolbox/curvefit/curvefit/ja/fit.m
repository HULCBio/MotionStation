% FIT   �f�[�^�� fit type �I�u�W�F�N�g�ɋߎ����܂��B
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE) �́AFITTYPE ���A���̒l�ɏ]���āA
% �f�[�^ XDATA �� YDATA �ɋߎ����镶����̏ꍇ�A�ߎ����ꂽ���f�� FIT-
% TEDMODEL ���A�߂��܂��B
% 
% FITTYPE �́A���̒l����邱�Ƃ��ł��܂��B
%                FITTYPE                �ڍ�       
%   �X�v���C���F     
%                'smoothingspline'      �������X�v���C��
%                'cubicspline'          �L���[�r�b�N(���})�X�v���C��
%   Interpolants:
%                'linearinterp'         ���`���}
%                'nearestinterp'        �ŋߖT���}
%                'splineinterp'         �L���[�r�b�N�X�v���C�����}
%                'pchipinterp'          �^��ۑ������܂�(pchip)�ł̓��}
%
% �܂��́ACFLIBHELP �̒��ɋL�q����郉�C�u�������f���̖��O�̂����ꂩ
% (type CFLIBHELP �ɂ��A���C�u�������f���̖��O�Əڍׂ����邱�Ƃ���
% ���܂�)�BXDATA �� YDATA �́A��x�N�g���ł��B���ӁF'cubicspline' �� 
% 'splineinterp' �́A���� FITTYPE �ł��B
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE) �́AFITTYPE ���A���ꎩ�g�Ɋ܂܂�
% ����ɏ]���āA�f�[�^ XDATA �� YDATA ���ߎ����� FITTYPE �I�u�W�F�N�g
% �̏ꍇ�A�ߎ����ꂽ���f�� FITTEDMODEL ��߂��܂��B�J�X�^�����f���́A
% FITTYPE �֐����g���āA�쐬����܂��B
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,...,PROP1,VAL1,PROP2,VAL2,...) �́A
% �v���p�e�B���ƒl�APROP1, VAL1 ���X�Ŏw�肵���A���S���Y���̃I�v�V������
% ���̃I�v�V�������g���āA�f�[�^ XDATA �� YDATA ���ߎ����܂��BFITOP-
% TIONS �v���p�e�B�ƃf�t�H���g�l�ɂ��ẮAFITOPTIONS(FITTYPE) �Ɠ���
% ���Ă��������B 
% 
%      fitoptions('cubicspline')
%      fitoptions('exp2')
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,OPTIONS) �́AFITOPTIONS �I�u�W�F�N
% �g OPTIONS �Ɏw�肵�����ƃA���S���Y���̃I�v�V�������g���āA�f�[�^ 
% XDATA �� YDATA ���ߎ����܂��B����́A�v���p�e�B�̖��O�ƒl��g�Őݒ肷��
% �ʂ̕\�����@�ł��BOPTIONS �I�u�W�F�N�g�̍쐬�Ɋւ���w���v�́AFITOP-
% TIONS ���Q�Ƃ��Ă��������B
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,...,'problem',VALUES) �́Aproblem 
% �Ɉˑ������萔�� VALUES �Ɋ��蓖�Ă܂��BVALUES �́Aproblem �Ɉˑ�����
% �萔�ɕt����̗v�f�����Z���z��ł��Bproblem �Ɉˑ������萔�Ɋւ���
% ���́AFITTYPE ���Q�Ƃ��Ă��������B
%
% [FITTEDMODEL,GOODNESS] = FIT(XDATA,YDATA,...) �́A�^�������͂ɑ΂��āA
% �K���x�������\���� GOODNESS �ɏo�͂��܂��BGOODNESS �́A���̃t�B�[��
% �h���܂�ł��܂��FSSE (�덷�ɂ����a)�AR2(����W���A�܂��́AR^2)�A
% adjustedR2 (adjustedR^2 �̎��R�x)�ƁAstdError (�ߎ��W���덷�A�܂��́A
% RMS�덷)�B
%
% [FITTEDMODEL,GOODNESS,OUTPUT] = FIT(XDATA,YDATA,...) �́A�^����ꂽ����
% �ɑ΂��āA�K�؂ȏo�͒l������ OUTPUT �\���̂�߂��܂��B���Ƃ��΁A����`
% �ߎ����ɑ΂��āA�J��Ԃ��񐔁A���f���̌v�Z�񐔁A���������� exitflag �A
% �c���AJacobian ���A�\���� OUTPUT �ɖ߂��܂��B
%
% ���F
%      [curve, goodness] = fit(xdata,ydata,'pchipinterp');
% �́Axdata �� ydata ��ʂ��āA�L���[�r�b�N���}�X�v���C�����g���āA�ߎ�
% ���܂��B
% 
%      curve = fit(x,y,'exp1','Startpoint',p0)
% 
% �́A�����l�� p0 �ŏ����������L���^�֐��̃J�[�u�t�B�b�e���O���C�u������
% ����3�Ԗڂ̕������ɋߎ����܂��B
%
% �Q�l�F CFLIBHELP, FITTYPE, FITOPTIONS.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.

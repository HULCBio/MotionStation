% function out = dhfnorm(sys,ttol,h,iiloc)
%
% �o�ꎟ�ϊ���HINFNORM���g���āA����ȗ��U����SYSTEM�s��SYS��H���m������
% �v�Z�A�܂���PKVNORM���g����VARYING�s���H���m�������v�Z���܂��B2�Ԗڂ�
% ����TTOL�́ASYSTEM�s��ɑ΂��Ďg���A�������I�������Ƃ��̖�����m����
% �ɑ΂����E�Ɖ��E�̊Ԃ̑��ΓI�ȋ��e�͈͂ł��BTTOL�̓I�v�V�����ŁA�f�t
% �H���g�l��0.001�ł��B�I�v�V������3�Ԗڂ̈���H�́A�T���v�����Ԃł�(�f�t
% �H���g = 1)�B�I�v�V������4�Ԗڂ̈���IILOC�́A�ň��P�[�X�̎��g���ɑ΂�
% �鏉�����g������l�ł��B
%
% SYSTEM�s��ɑ΂��āAOUT�́A1�s3��̍s�x�N�g���ŁA���E�A��E�A���E�̎�
% �g����v�f�Ƃ��Ă��܂��BCONSTANT�s��ɑ΂��āAOUT�́A1�s3��̍s�x�N�g
% ���ŁA�ŏ���2�̗v�f�͍s��̃m�����ŁA���g����0�ł��BOUT�́ASYS��VA-
% RYING�s��̏ꍇ�ASYS��PKVNORM�ł��B
%
% �Q�l: DHFSYN, HINFNORM, H2SYN, H2NORM, HINFCHK, HINFSYN,
%       HINFFI, NORM, PKVNORM, SDHFNORM, SDHFSYN.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

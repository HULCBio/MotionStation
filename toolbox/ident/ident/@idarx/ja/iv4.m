% IDARX/IV4 �́A���ϐ� ARX ���f���Ɋւ���K�؂�IV-������v�Z���܂��B
%
%   MODEL = IV4(DATA,Mi)
%
%   MODEL: ���肵�������U�ƍ\���Ɋւ���������ARX ���f���̐���
%   A(q) y(t) = B(q) u(t-nk) + v(t)
%   MODEL �̌����ȏ����ɂ��ẮAHELP IDARX ���Q�Ƃ��Ă��������B
%
%   DATA: ���o�̓f�[�^�� IDDATA �I�u�W�F�N�g�BHELP IDDATA ���Q�Ƃ��Ă���
%         �����B 
%
%   Mi  : ������ݒ肷�� IDARX �I�u�W�F�N�g�Bhelp IDARX ���Q�Ƃ��Ă�����
%         ���B
%
% �A���S���Y���Ɋ֘A�����������̃p�����[�^�́A
% 
%   MODEL = IV4(DATA,Mi'MaxSize',MAXSIZE)
% 
% �ŃA�N�Z�X����܂��B�����ŁAMAXSIZE �́A�������ƃX�s�[�h�̃g���[�h�I�t
% ��ݒ肷����̂ł��B�}�j���A�����Q�Ƃ��Ă��������B
% �v���p�e�B�̖��O�ƒl��g�Ƃ��Ďg�p����ꍇ�A�g���ɔC�ӂ̏��ԂŐݒ�ł�
% �܂��B�ȗ��������̂́A�f�t�H���g�l���g���܂��B
% MODEL �v���p�e�B 'FOCUS' �� 'INPUTDELAY' �́A
% 
%   M = IV4(DATA,Mi,'Focus','Simulation','InputDelay',[3 2]);
% 
% �̂悤�Ƀv���p�e�B��/�l�Ƃ��Đݒ�ł��܂��B
% �ڍׂ́AIDPROPS ALGORITHM �� IDPROPS IDMODEL ���Q�Ƃ��Ă��������B
%    
% �Q�l�F ARX, ARMAX, BJ, N4SID, OE, PEM.



%   Copyright 1986-2001 The MathWorks, Inc.

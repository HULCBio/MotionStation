% C2D   C2D �ϊ��ł� LTI �v���p�e�B���Ǘ�
%
% Tustin �� Matched �@�ł́A
% 
%   DSYS.LTI = C2D(CSYS.LTI,TS,TOLINT) 
% 
% �́A���̂悤�ɂ��č쐬����闣�U���f�� DSYS ��LTI�v���p�e�B��ݒ�
% ���܂��B
% 
%   DSYS = C2D(CSYS,TS)
% 
% �A�����Ԃ̒x��́ATS �ŃX�P�[�����O����A�ł��߂������Ɋۂ߂��܂��B
%
% ZOH �܂��� FOH �̎�@
% 
%   DSYS.LTI = C2D(CSYS.LTI,TS,DID,DOD,DIOD) 
% 
% �́ADSYS = C2D(CSYS,TS) �� LTI �v���p�e�B��ݒ肵�܂��B�z�� DID, DOD, 
% DIOD �́AZOH �܂��� FOH �̗��U���̊ԂɌv�Z���ꂽ���U���Ԃ̓��́A�o�́A
% I/O �̒x��������܂��B
%
% �Q�l : TF/C2D.


%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 

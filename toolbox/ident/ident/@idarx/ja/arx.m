% IDARX/ARX �́A(���ϐ�)ARX ���f���̐�����s���܂��B
%    
%   M = ARX(Z,Mi)
%
%   Z: IDDATA �I�u�W�F�N�g�Ɠ��l�ȏo��-���̓f�[�^�B�ڍׂ́AHELP IDDATA ��
%      �Q��
%   Mi: �������`���� IDARX �I�u�W�F�N�g�B�ڍׂ́Ahelp IDARX ���Q��
%
% �A���S���Y���Ɋ֘A�����������̃p�����[�^�́A���̂悤�ɂ��ăA�N�Z�X
% ����܂��B
% 
%   MODEL = ARX(DATA,Mi'MaxSize',MAXSIZE)
% 
% �����ŁAMAXSIZE �́A�������ƃX�s�[�h�̃g���[�h�I�t�ł��B�}�j���A�����Q
% �Ƃ��Ă��������B
%
% ARX �́AE'*inv(LAMBDA)*E �̃m�������ŏ������܂��B�����ŁAE �͗\���덷��
% LAMBDA �� Mi.NoiseVariance �ł��B
%
% �v���p�e�B���ƒl���g�Ƃ��Ďg�p�����ꍇ�A�C�ӂ̏��Ԃɐݒ�ł��܂��B��
% ���������̂́A�f�t�H���g�l���g���܂��B
% MODEL �v���p�e�B 'FOCUS' �� 'INPUTDELAY' �́A
% 
%   M = ARX(DATA,Mi,'Focus','Simulation','InputDelay',[3 2]);
% 
% �̒��Ɠ����悤�Ƀv���p�e�B���ƒl����g�Ƃ��Đݒ肵�܂��BIDPROPS ALGOR-
% ITHM �� IDPROPS IDMODEL ���Q�Ƃ��Ă��������B

%   L. Ljung 10-2-90


%   Copyright 1986-2001 The MathWorks, Inc.

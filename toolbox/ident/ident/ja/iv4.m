% IV4  �œK�� IV ���g���āAARX ���f�����v�Z���܂��B
% 
%   MODEL = IV4(DATA,NN)
%
%   MODEL : ���̌^������ ARX ���f��
%   
%              A(q) y(t) = B(q) u(t-nk) + v(t)
%   
%           �̐��肵�����ʂƁA�����U�ƍ\�������܂񂾂��̂��o�́B
% MODEL �̐��m�ȃt�H�[�}�b�g�Ɋւ��āAHELP IDPOLY �� (���o�̓��f���ɑ΂�
% ��)HELP IDARX ���Q�Ƃ��Ă��������B
%
%   DATA  : �P�o�� IDDATA �I�u�W�F�N�g�Ƃ��ĕ\�����o�� - ���̓f�[�^�B��
%           �ׂ́AHELP IDDATA ���Q�ƁB
%
%   NN    : NN = [na nb nk] �B��̃��f���̎����ƒx��B
%           ���o�̓V�X�e���ɑ΂��āANN �͏o�͂Ɠ����s���������Ă��܂��B
%           ���̂��߁Ana �́Any|ny �s��ŁA���� i �s j ��̗v�f�́Ai ��
%           �ڂ̓��͂� j �Ԗڂ̏o�͂��֘A�t���鑽����(�x�ꉉ�Z�q���܂��
%           )�̎�����\���Ă��܂��B���l�ɁAnb �� nk �� ny|nu �s��ɂȂ�
%           �܂�(ny:# �͏o�͂��Anu:# �͓���)�B
%
% �ʂ̕\���́AMODEL = IV4(DATA,'na',na,'nb',nb,'nk',nk) �ł��B
%
% �A���S���Y���ɢ�֘A�����������̃p�����[�^���A�N�Z�X�ł��܂��B
% 
%   MODEL = IV4(DATA,ORDERS,'MaxSize',MAXSIZE)
%
% �����ŁAMAXSIZE �́A�������ƃX�s�[�h�̃g���[�h�I�t���R���g���[�����܂��B
% �}�j���A�����Q�Ƃ��Ă��������B�v���p�e�B���ƒl��g�Őݒ肷����@���g��
% �ꍇ�A�X�̑g��ݒ肷�鏇�Ԃ͔C�ӂł��B�ȗ��������̂́A�f�t�H���g�l��
% �g���܂��BMODEL �v���p�e�B'FOCUS' ��'INPUTDELAY' �́A���̂悤��
% 
%   M = IV4(DATA,[na nb nk],'Focus','Simulation','InputDelay',[3 2]);
% 
% �v���p�e�B��/�l�̑g�Őݒ肳��܂��BIDPROPS ALGORITHM �� IDPROPS IDMO-
% DEL ���Q�Ƃ��Ă��������B
%    
% �Q�l�F ARX, ARMAX, BJ, N4SID, OE, PEM.

%   L. Ljung 10-1-86,4-15-90


%   Copyright 1986-2001 The MathWorks, Inc.

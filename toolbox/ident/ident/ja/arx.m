% ARX   ARX ���f�����ŏ����@���g���Čv�Z���܂��B
% 
%   M = ARX(DATA,ORDERS)
%
%   M: ���̌^�ŕ\����� ARX ���f��
% 
%   A(q) y(t) = B(q) u(t-nk) + e(t)
% 
% �̐���p�����[�^�ŁA�����U��\�������܂�ł��܂��B
% �P�o�̓V�X�e���ɑ΂��āAM �� IDPOLY ���f���I�u�W�F�N�g�ɂȂ�A���o�̓V
% �X�e���ɑ΂��āAIDARX �I�u�W�F�N�g�ɂȂ�܂��B
% 
% �ڍׂ́AIDPROPS, IDPROPS IDPOLY, IDPROPS IDARX �̂����ꂩ����͂��Ă�
% �������B
%
%   DATA: IDDATA �I�u�W�F�N�g�̌^����������Ɏg�p����f�[�^�ŁA�ڍׂ� HE
%         LP IDDATA ���Q�Ƃ��Ă��������B
%   
%   ORDERS = [na nb nk] �́A��̃��f���̎����ƒx��ł��B
%   
% ���o�̓V�X�e���̏ꍇ�AORDERS �͏o�͐��Ɠ����̍s�������Ana �� ny|ny �s
% ��ŁA���� i �s j ��̗v�f�� i �Ԗڂ̓��͂� j �Ԗڂ̏o�͂��֘A�t���鑽
% ����(�x�ꉉ�Z�q���܂��)�̎�����\���Ă��܂��B���l�ɁAnb �� nk �� ny-
% |nu �s��ɂȂ�܂�(ny:# �͏o�͂��Anu:# �͓���)�B���n��̏ꍇ�AORDER = 
% na �݂̂ɂȂ�܂��B
% 
% �ʂ̕\���Ƃ��āAm = ARX(DATA,'na',na,'nb',nb,'nk',nk) ���g�����Ƃ��ł�
% �܂��B
%
% ���o�͂̏ꍇ�AARX �� E'*inv(LAMBDA)*E �̃m�������ŏ������܂��B�����ŁA
% E �͗\���덷�ŁALAMBDA�̓C�j�V�������f��(�f�t�H���g�͒P�ʍs��)�̃m�C�Y
% ���U�ł��B
%
% �A���S���Y���Ɋ֘A�����������̃p�����[�^�ƃI�v�V�����́A�C�ӂ̏��Ԃ�
% �v���p�e�B�ƃv���p�e�B�l�̑g���킹�ƂȂ�܂��B�ȗ������v���p�e�B�́A�f
% �t�H���g�̒l�ɐݒ肳��܂��B���p�����T�^�I�ȃI�v�V�����Ƃ��āA����
% ���̂�����܂��B
%   
%   FOCUS ('Prediction', 'simulation', 'stability' �܂��́A�v���t�B���^)
%   INPUTDELAY
%   FIXEDPARAMETER (�m�~�i�����f���̌Œ肵�����p�����[�^)
%   NOISEVARIANCE (���o�͂ł̏o�̓m�����̎w��)
%   MAXSIZE  (�\�������s��̍ő�T�C�Y�̎w��)
%
% �Q�l: �ڍׂ́AIDPROPS ALGORITHM�A�܂��́AIDPROPS IDMODEL
%       �p�����[�^�����̐���@�Ɋւ��ẮAARXSTRUC, SELSTRUC
%       ���̐��胋�[�`���Ɋւ��ẮAAR, ARMAX, BJ, IV4, N4SID, OE, PEM

%   L. Ljung 10-1-86,12-8-91


%   Copyright 1986-2001 The MathWorks, Inc.

% EVLIKE   �ɒl���z�ɑ΂��镉�̑ΐ��ޓx
%
% NLOGL = EVLIKE(PARAMS,DATA) �́ADATA ��^���āA�p�����[�^ PARAMS(1) = MU 
% �� PARAMS(2) = SIGMA �ŕ]�����ꂽ�^�C�v1�̋ɒl���z�ɑ΂���ΐ��ޓx��
% ���̒l���o�͂��܂��BNLOGL �́A�X�J���ł��B
%
% [NLOGL, AVAR] = EVLIKE(PARAMS,DATA) �́AFisher ���s�� AVAR �̋t��
% �o�͂��܂��BPARAMS �̓��̓p�����[�^���Ŗސ���ł���ꍇ�AAVAR �̑Ίp
% �v�f�́A�����̑Q�ߓI�ȕ��U�l�ł��BAVAR �́A���҂��ꂽ���ł͂Ȃ��A
% �ϑ����ꂽ Fisher ���Ɋ�Â��܂��B
%
% [...] = EVLIKE(PARAMS,DATA,CENSORING) �́A���m�Ɋϑ����ꂽ�ϑ��l��
% [...] = EVLIKE(PARAMS,DATA,CENSORING,FREQ) �́ADATA �Ɠ����傫����% [...] = EVLIKE(PARAMS,DATA,CENSORING,FREQ) �́ADATA �Ɠ����T�C�Y��
% �p�x�x�N�g�����󂯓���܂��BFREQ �́A�ʏ�́ADATA �̗v�f�ɑΉ�����
% ���߂̐����̕p�x���܂݂܂����A�C�ӂ̐����łȂ��񕉒l���܂ނ��Ƃ�
% �ł��܂��B�����̃f�t�H���g�l���g�p����ɂ́ACENSORING �ɑ΂��� [] ��
% �n���Ă��������B
%
% �^�C�v1�̋ɒl���z�́A�ʖ�Gumbel���z�Ƃ��Ă��m���Ă��܂��BY �� 
% Weibull���z�̏ꍇ�AX=log(Y) �́A�^�C�v1�̋ɒl���z�ɂȂ�܂��B
%
% �Q�l : EVCDF, EVFIT, EVINV, EVPDF, EVRND, EVSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2003/01/08 15:29:31 $

% NORMLIKE   ���K���z�ɑ΂��镉�̑ΐ��ޓx
%
% NLOGL = NORMLIKE(PARAMS,DATA) �́ADATA ��^���āA�p�����[�^ PARAMS(1) = MU 
% �� PARAMS(2) = SIGMA �ŕ]�����ꂽ���K���z�ɑ΂���ΐ��ޓx�̕��̒l���o��
% ���܂��BNLOGL �́A�X�J���ł��B
% 
% [NLOGL, AVAR] = NORMLIKE(PARAMS,DATA) �́AFisher ���s�� AVAR �̋t��
% �o�͂��܂��BPARAMS �̓��̓p�����[�^���Ŗސ���ł���ꍇ�AAVAR �̑Ίp
% �v�f�́A�����̑Q�ߓI�ȕ��U�l�ł��BAVAR �́A���҂��ꂽ���ł͂Ȃ��A
% �ϑ����ꂽ Fisher ���Ɋ�Â��܂��B
% 
% [...] = NORMLIKE(PARAMS,DATA,CENSORING) �́A���m�Ɋϑ����ꂽ�ϑ��l��
% �΂���0���A�E���ł��؂�̊ϑ��l�ɑ΂���1�ƂȂ�ADATA �Ɠ����傫����
% �_���x�N�g�����󂯓���܂��B
%
% [...] = NORMLIKE(PARAMS,DATA,CENSORING,FREQ) �́ADATA �Ɠ����傫����% [...] = NORMLIKE(PARAMS,DATA,CENSORING,FREQ) �́ADATA �Ɠ����T�C�Y��
% �p�x�x�N�g�����󂯓���܂��BFREQ �́A�ʏ�́ADATA �̗v�f�ɑΉ�����
% ���߂̐����̕p�x���܂݂܂����A�C�ӂ̐����łȂ��񕉒l���܂ނ��Ƃ�
% �\�ł��BCENSORING �ɑ΂��ăf�t�H���g�l���g�p����ꍇ�́A [] ��n����
% ���������B
%
% �Q�l : NORMCDF, NORMFIT, NORMINV, NORMPDF, NORMRND, NORMSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:22 $

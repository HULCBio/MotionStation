% LOGNLIKE   �ΐ����K���z�ɑ΂��镉�̑ΐ��ޓx
%
% NLOGL = LOGNLIKE(PARAMS,DATA) �́ADATA ��^���āA�p�����[�^ 
% PARAMS(1) = MU �� PARAMS(2) = SIGMA �ŕ]�����ꂽ�ΐ����K���z�ɑ΂���
% �ΐ��ޓx�̕��̒l���o�͂��܂��BNLOGL �́A�X�J���ł��B
%
% [NLOGL, AVAR] = LOGNLIKE(PARAMS,DATA) �́AFisher ���s�� AVAR �̋t��
% �o�͂��܂��BPARAMS �̓��̓p�����[�^���Ŗސ���ł���ꍇ�AAVAR �̑Ίp
% �v�f�́A�����̑Q�ߓI�ȕ��U�l�ł��BAVAR �́A���҂��ꂽ���ł͂Ȃ��A
% �ϑ����ꂽ Fisher ���Ɋ�Â��܂��B
%
% [...] = LOGNLIKE(PARAMS,DATA,CENSORING) �́A���m�Ɋϑ����ꂽ�ϑ��l��
% �΂���0���A�E���ł��؂�̊ϑ��l�ɑ΂���1�ƂȂ�ADATA �Ɠ����傫����
% �_���x�N�g�����󂯓���܂��B
%
% [...] = LOGNLIKE(PARAMS,DATA,CENSORING,FREQ) �́ADATA �Ɠ����傫����
% �p�x�x�N�g�����󂯓���܂��BFREQ �́A�ʏ�́ADATA �̗v�f�ɑΉ�����
% ���߂̐����̕p�x���܂݂܂����A�C�ӂ̐����łȂ��񕉒l���܂ނ��Ƃ�
% �ł��܂��B�����̃f�t�H���g�l���g�p����ɂ́ACENSORING �ɑ΂��� [] ��
% �n���Ă��������B
%
% �Q�l : LOGNCDF, LOGNFIT, LOGNINV, LOGNPDF, LOGNRND, LOGNSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2003/01/09 21:26:37 $

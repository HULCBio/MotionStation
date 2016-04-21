% LOGNFIT   �ΐ����K�̃f�[�^�ɑ΂���p�����[�^����ƐM�����
%
% PARMHAT = LOGNFIT(X) �́A�^����ꂽ X �̃f�[�^�ŁA�ΐ����K���z��
% �p�����[�^�̍Ŗސ���l���o�͂��܂��B
% PARMHAT(1) �� PARMHAT(2) �́A���ꂼ��A���鐳�K���z�Ɋ�Â����ς�
% �W���΍��p�����[�^�ł��� MU �� SIGMA �ł��B
%
% [PARMHAT,PARMCI] = LOGNFIT(X) �́A�p�����[�^����ɑ΂���95%�̐M����Ԃ�
% �o�͂��܂��B
%
% [PARMHAT,PARMCI] = LOGNFIT(X,ALPHA) �́A�p�����[�^����ɑ΂��� 
% 100(1-ALPHA)% �̐M����Ԃ��o�͂��܂��B
%
% [...] = LOGNFIT(X,ALPHA,CENSORING) �́A���m�Ɋϑ����ꂽ�ϑ��l�ɑ΂���0�A
% �E���ł��؂�̊ϑ��l�ɑ΂���1�ƂȂ�AX �Ɠ����傫���̘_���x�N�g������
% ����܂��B
%
% [...] = LOGNFIT(X,ALPHA,CENSORING,FREQ) �́AX �Ɠ����傫���̕p�x�x�N�g��
% ���󂯓���܂��BFREQ �́A�ʏ�́AX �̗v�f�ɑΉ����邽�߂̐����̕p�x��
% �܂݂܂����A�C�ӂ̐����łȂ��񕉒l���܂ނ��Ƃ��ł��܂��B
%
% [...] = LOGNFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) �́A�Ŗ�(ML)����̌v�Z��
% �g�p����锽���A���S���Y���ɑ΂���R���g���[���p�����[�^���w�肵�܂��B
% ���̈����́ASTATSET ���R�[�����邱�Ƃō쐬����܂��B�p�����[�^����
% �f�t�H���g�l�ɂ��ẮASTATSET('lognfit') ���Q�Ƃ��Ă��������B
%
% �����̃f�t�H���g�l���g�p����ɂ́AALPHA, CENSORING, FREQ �ɑ΂��āA
% [] ��n���Ă��������B
%
% �Q�l : LOGNCDF, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND, LOGNSTAT, MLE,
%        STATSET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/02/11 19:41:34 $

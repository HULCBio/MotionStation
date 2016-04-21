% WBLFIT   Weibull�f�[�^�ɑ΂���p�����[�^����ƐM�����
%
% PARMHAT = WBLFIT(X) �́A�^����ꂽ X �̃f�[�^�ŁAWeibull���z�̃p�����[�^
% �̍Ŗސ���l���o�͂��܂��BPARMHAT(1) �́A�X�P�[���p�����[�^ A �ŁA
% PARMHAT(2) �́A�`��p�����[�^ B �ł��B
%
% [PARMHAT,PARMCI] = WBLFIT(X) �́A�p�����[�^����ɑ΂���95%�̐M����Ԃ�
% �o�͂��܂��B
%
% [PARMHAT,PARMCI] = WBLFIT(X,ALPHA) �́A�p�����[�^����ɑ΂��� 
% 100(1-ALPHA)% �̐M����Ԃ��o�͂��܂��B
%
% [...] = WBLFIT(X,ALPHA,CENSORING) �́A���m�Ɋϑ����ꂽ�ϑ��l�ɑ΂���0�A
% �E���ł��؂�̊ϑ��l�ɑ΂���1�ƂȂ�AX �Ɠ����傫���̘_���x�N�g������
% ����܂��B
%
% [...] = WBLFIT(X,ALPHA,CENSORING,FREQ) �́AX �Ɠ����傫���̕p�x�x�N�g��
% ���󂯓���܂��BFREQ �́A�ʏ�́AX �̗v�f�ɑΉ����邽�߂̐����̕p�x��
% �܂݂܂����A�C�ӂ̐����łȂ��񕉒l���܂ނ��Ƃ��ł��܂��B
%
% [...] = WBLFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) �́A�Ŗ�(ML)����̌v�Z��
% �g�p����锽���A���S���Y���ɑ΂���R���g���[���p�����[�^���w�肵�܂��B
% ���̈����́ASTATSET ���R�[�����邱�Ƃō쐬����܂��B�p�����[�^����
% �f�t�H���g�l�ɂ��ẮASTATSET('wblfit') ���Q�Ƃ��Ă��������B
%
% �����̃f�t�H���g�l���g�p����ɂ́AALPHA, CENSORING, FREQ �ɑ΂��āA
% [] ��n���Ă��������B
%
% �Q�l : WBLCDF, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, MLE,
%        STATSET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/02/11 19:41:33 $

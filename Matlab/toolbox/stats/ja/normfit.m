% NORMFIT   ���K���z�f�[�^�̃p�����[�^�ƐM����Ԃ̐���
%
% [MUHAT,SIGMAHAT] = NORMFIT(X) �́A�^����ꂽ X �̃f�[�^�ŁA���K���z��
% �p�����[�^�̍Ŗސ�����o�͂��܂��BMUHAT �́A���ς̐���ŁASIGMAHAT �́A
% �W���΍��̐���ł��B
%
% [MUHAT,SIGMAHAT,MUCI,SIGMACI] = NORMFIT(X) �́A�p�����[�^����ɑ΂���
% 95%�̐M����Ԃ��o�͂��܂��B
% 
% [MUHAT,SIGMAHAT,MUCI,SIGMACI] = NORMFIT(X,ALPHA) �́A�p�����[�^����� 
% �΂��� 100(1-ALPHA)% �̐M����Ԃ��o�͂��܂��B
% 
% [...] = NORMFIT(X,ALPHA,CENSORING) �́A���m�Ɋϑ����ꂽ�ϑ��l�ɑ΂���
% 0�A�E���ł��؂�̊ϑ��l�ɑ΂���1�ƂȂ�AX �Ɠ����傫���̘_���x�N�g����
% �󂯓���܂��B
%
% [...] = NORMFIT(X,ALPHA,CENSORING,FREQ) �́AX �Ɠ����傫���̕p�x
% �x�N�g�����󂯓���܂��BFREQ �́A�ʏ�́AX �̗v�f�ɑΉ����邽�߂�
% �����̕p�x���܂݂܂����A�C�ӂ̐����łȂ��񕉒l���܂ނ��Ƃ��ł��܂��B
%
% [...] = NORMFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) �́A�Ŗ�(ML)����̌v�Z��
% �g�p����锽���A���S���Y���ɑ΂���R���g���[���p�����[�^���w�肵�܂��B
% ���̈����́ASTATSET ���R�[�����邱�Ƃō쐬����܂��B�p�����[�^����
% �f�t�H���g�l�ɂ��ẮASTATSET('normfit') ���Q�Ƃ��Ă��������B
%
% �����̃f�t�H���g�l���g�p����ɂ́AALPHA, CENSORING, FREQ �ɑ΂��āA
% [] ��n���Ă��������B
%
% �Q�l : NORMCDF, NORMINV, NORMLIKE, NORMPDF, NORMRND, NORMSTAT, MLE, 
%        STATSET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/04/21 19:42:41 $

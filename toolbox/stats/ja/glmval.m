% GLMVAL   ��ʉ����`���f���ɑ΂���t�B�b�e�B���O�l���v�Z
%
% YHAT=GLMVAL(BETA,X,LINK) �́A�����N�֐� LINK �� �\���q X���g�p����
% ��ʉ����`���f���ɑ΂��ăt�B�b�e�B���O�l���v�Z���܂��BBETA �́A�֐�
% GLMFIT�ɂ��o�͂����W������̃x�N�g���ł��BLINK �́A�֐�GLMFIT��
% �g�p�ł���v�f�\������Ȃ�s��̌^�ł��ݒ�ł��܂��B
%
% [YHAT,DYLO,DYHI] = GLMVAL(BETA,X,LINK,STATS,CLEV) �́A�܂��A���������
% Y�̒l�ɂ��Ă̐M����Ԃ��v�Z���܂��BSTATS �́AGLMFIT�ɂ��o�͂����
% stats�\���̂ł��BDYLO ��DYHI �́A���ꂼ��YHAT-DYLO �̐M����Ԃ̉��E�ƁA
% YHAT+DYHI�̐M����Ԃ̏�E���`���܂��BCLEV �́A(�f�t�H���g�ł́A95%��
% �M����Ԃɑ΂��āA0.95�ł���)�M�����x���ł��B�M�����E�́A�񓯊��ł���A
% �����́A�t�B�b�e�B���O���ꂽ�Ȑ��ɓK�p����A�V�����ϑ��ɂ́A�K�p����
% �܂���B
%
% [YHAT,DYLO,DYHI] = GLMVAL(BETA,X,LINK,STATS,CLEV,N,OFFSET,CONST) �́A
% �I�v�V�����������g���āA�ǉ��̃I�v�V�������w�肵�܂��BN �́AGLMFIT ��
% ���Ɏg�����z���A�񍀕��z�̏ꍇ�A�񍀕��z��N �̒l�ɂȂ�A���̕��z�̏ꍇ�A
% ��̔z��ɂȂ�܂��B
% OFFSET �́AGLMFIT�ɁA�I�t�Z�b�g������񋟂���ꍇ�A�I�t�Z�b�g�l��
% �x�N�g���ŁA�I�t�Z�b�g���g�p����Ȃ��ꍇ�A��̔z��ł��B
% CONST �́Afit���萔�����܂ޏꍇ�A'on'�ŁA�܂܂Ȃ��ꍇ�A'off'�ł��B
%
% �Q�l : GLMFIT.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:12:12 $

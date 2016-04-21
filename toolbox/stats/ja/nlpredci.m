% NLPREDCI   ����`�ŏ����\���̐M�����
%
% [YPRED, DELTA] = NLPREDCI(FUN,X,BETA,RESID,J) �́A�\���l(YPRED)�ƁA
% ���͒l X �̊֐� F �ɑ΂���95%�̐M����Ԃ̔��l��(half-widths)(DELTA)��
% �o�͂��܂��B���̊֐����g�p����O�ɁA���肳�ꂽ�W���l BETA �ƁA�c�� 
% RESID�A���R�r�A�� J ���擾���A����`�ŏ����ɂ���� FUN �ɋߎ�����
% ���߂ɁANLINFIT ���g�p���Ă��������B
%
% [YPRED, DELTA] = NLPREDCI(FUN,X,BETA,RESID,J,ALPHA,SIMOPT,PREDOPT) �́A
% �M�����E���R���g���[�����܂��BALPHA �́A�M�����x���� 100(1-ALPHA)% 
% �Ƃ��Ē�`����A0.05���f�t�H���g�ł��BSIMOPT �́A�����ł���M�����E
% �ɑ΂��� 'on'�A�񓯊��ȐM�����E�ɑ΂��� 'off'(�f�t�H���g) �ł��B
% PREDOPT �́AX �Ő��肳�ꂽ�J�[�u(�֐��l)�ɑ΂���M����Ԃɂ� 'curve'
% (�f�t�H���g)�A�܂��́AX �̐V���Ȋϑ��ɑ΂���M����Ԃɂ́A'observation'
% ��ݒ肵�܂��B
%
% �M����Ԃ̌v�Z�́ARESID �̒����� BETA �̒������������AJ ���t����
% �����N�̏ꍇ�A�V�X�e���ɑ΂���M����Ԃ̌v�Z�͗L���ł��B
% 
% ���:
%      [beta,resid,J]  = nlinfit(input,output,@f,betainit);
%      [yp, ci] = nlpredci(@f,newx,beta,resid,J);
%
% �Q�l : NLINFIT, NLPARCI, NLINTOOL.


%   Bradley Jones 1-28-94
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:14:12 $

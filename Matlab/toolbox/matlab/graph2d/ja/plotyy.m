%PLOTYY ���E������y�������O���t
% PLOTYY(X1,Y1,X2,Y2) �́AX1 �� Y1 �������Ƀ��x�����O����y�����g����
% �v���b�g���AX2 �� Y2 ���E���Ƀ��x�����O����y�����g���ăv���b�g���܂��B
%
%   PLOTYY(X1,Y1,X2,Y2,FUN) �́A�e�O���t���쐬���邽�߂ɁAPLOT �ł͂Ȃ�
%�@ �v���b�g�֐� FUN ���g�p���܂��BFUN �́A�v���b�e�B���O�֐��̖��O
%�@ �ł���֐��n���h���A�܂��́A������ɂȂ�܂��B
%�@ ���Ƃ��΁Aplot, semilogx, semilogy, loglog, stem, 
%   �ȂǁB�܂��́A�V���^�b�N�X H = FUN(X,Y) ���󂯎��C�ӂ̊֐��ł��B
% ���Ƃ��΁A���̂悤�ɂ��܂��B
%      PLOTYY(X1,Y1,X2,Y2,@loglog)  % �֐��n���h��
%      PLOTYY(X1,Y1,X2,Y2,'loglog') % ������
%   
% PLOTYY(X1,Y1,X2,Y2,FUN1,FUN2) �́A���̎��ɑ΂��āA�f�[�^���v���b�g����
% ���߂� FUN1(X1,Y1) ���g�p���A�E�̎��ɑ΂��āA�f�[�^���v���b�g���邽�߂�
% FUN2(X2,Y2) ���g�p���܂��B
%
% PLOTYY(AX,...) �́AGCA �ł͂Ȃ��AAX�Ƀ��C�� axes �Ƃ��ăv���b�g���܂��B
% AX �� PLOTYY �ɑ΂���O�̃R�[���ɂ��o�͂���� axes �n���h���̏ꍇ�A
% ���̎��͖�������܂��B
%
% [AX,H1,H2] = PLOTYY(...) �́A�쐬����2�̎��̃n���h���ԍ��� AX �ɁA�e�v
% ���b�g����̃O���t�B�b�N�X�I�u�W�F�N�g�̃n���h���ԍ��� H1 �� H2 �ɏo�͂���
% ���BAX(1) �͍����̎��ŁAAX(2) �͉E���̎��ł��B
%
% �Q�l PLOT, @
% �ڍׂ�m�邽�߂ɂ́A"doc plotyy" �Ɠ��͂��Ă��������B

%   Copyright 1984-2002 The MathWorks, Inc.

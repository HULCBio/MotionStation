% FPLOT   �֐��̃v���b�g
% 
% FPLOT(FUN,LIMS) �́ALIMS = [XMIN XMAX] �Ŏw�肳�ꂽx���͈̔͂ɁA������ 
% FUN �Ŏw�肵���֐����v���b�g���܂��BLIMS = [XMIN XMAX YMIN YMAX] ��
% �g���ƁAy���͈̔͂�ݒ�ł��܂��B�֐� FUN(x)�́A�x�N�g�� x �̊e�v�f��
% �΂���s�x�N�g�����o�͂��Ȃ���΂Ȃ�܂���B���Ƃ��΁AFUN ��
% [f1(x),f2(x),f3(x)] ���o�͂���ƁA���� [x1;x2] �ɑ΂��āA�֐��͂���
% �s����o�͂��܂��B
%
%     f1(x1) f2(x1) f3(x1)
%     f1(x2) f2(x2) f3(x2)
% 
% FPLOT(FUN,LIMS,TOL) �́ATOL < 1 �̂Ƃ��A���΋��e�덷���w�肵�܂��B
% �f�t�H���g�� TOL �́A2e-3�A���Ȃ킿�A0.2%�̐��x�ł��BFPLOT(FUN,LIMS,N)
% �́AN > =  1 �̂Ƃ��AN+1 �_�̍ŏ��l�����֐����v���b�g���܂��B�f�t�H���g
% �� N ��1�ł��B�ő�X�e�b�v�T�C�Y�́A(1/N)*(XMAX-XMIN) �ɐ�������܂��B
% FPLOT(FUN,LIMS,'LineSpec') �́A�w�肵��line�̎d�l���g���ăv���b�g���܂��B
% FPLOT(FUN,LIMS,...) �́A�I�v�V�����̈��� TOL�AN�A'LineSpec' ��C�ӂ̏���
% �őg�ݍ��킹�Ďg�p���܂��B
% 
% [X,Y] = FPLOT(FUN,LIMS,...) �́AY = FUN(X) �ł���悤�� X �� Y ���o��
% ���܂��B�X�N���[����ɂ́A�����v���b�g����܂���B
%
% [...] = FPLOT(FUN,LIMITS,TOL,N,'LineSpec',P1,P2,...) �́A�p�����[�^ 
% P1,P2,...�����֐� FUN �ɓn���܂��B
% 
%     Y = FUN(X,P1,P2,...)
% 
% TOL,N,'LineSpec' �ɑ΂���f�t�H���g�l���g�����߂ɂ́A��s�� [] ��ݒ�
% ���Ă��������B
%
% ���:
% FUN �́A@ �܂��̓C�����C���I�u�W�F�N�g�A�������\�����g���Ďw�肷��
% ���Ƃ��ł��܂��B
%       subplot(2,2,1), fplot(@humps,[0 1])
%
%       f = inline('abs(exp(-j*x*(0:9))*ones(10,1))');
%       subplot(2,2,2), fplot(f,[0 2*pi])
%
%       subplot(2,2,3), fplot('[tan(x),sin(x),cos(x)]',2*pi*[-1 1 -1 1])
%       subplot(2,2,4), fplot('sin(1 ./ x)', [0.01 0.1],1e-3)


%   Mark W. Reichelt 6-2-93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:09 $

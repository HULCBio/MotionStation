%FZERO  1�ϐ��֐��̃[���_�̌��o
% 
% X = FZERO(FUN,X0)�́AX0�̋ߖT��FUN�̃[���_�����߂܂��BFUN�́A����
% �X�J������ X ���󂯓���AX �ł̎����X�J���֐��l F ���o�͂��܂��BFZERO
% �ɂ��o�͂����lX�́A(FUN���A���̏ꍇ��)FUN�̕������ς��ߖT�_
% ���A�܂��͉������܂�Ȃ��ꍇ�́ANaN���o�͂��܂��B
%
% X = FZERO(FUN,X0)�ɂ��āAX������2�̃x�N�g���ł���Ƃ��AX0�� FUN(X0
% (1))�̕�����FUN(X0(2))�̕����ƈقȂ�悤�ȋ�Ԃł���Ɖ��肵�܂��B����
% �łȂ��ꍇ�́A�G���[�������܂��B��ԂɊւ���ۏ؂�^����FZERO���R�[��
% ����ƁAFZERO��FUN�̕������ω�����ߖT�_�̒l���o�͂��܂��B
%
% X = FZERO(FUN,X0)�ɂ��āAX0���X�J���l�ł���Ƃ��AX0����������l�Ƃ�
% �Ďg���܂��BFZERO�́AFUN�ɑ΂��镄���̕ω��ƁAX0���܂񂾋�Ԃ�T��
% �܂��B���̂悤�ȋ�Ԃ�������Ȃ���΁ANaN���o�͂���܂��B���̏ꍇ�A
% Inf�ANaN�܂��͕��f���l�����߂���܂ŃT�[�`��Ԃ��g�������ƁA�T�[�`
% �͏I�����܂��B
%
% X = FZERO(FUN,X0,OPTIONS)�́A�f�t�H���g�̍œK�p�����[�^�̑���ɁA
% OPTIMSET�֐��ō쐬���ꂽOPTIONS�\���̂̒l���g���čŏ������s���܂��B
% �ڂ����́AOPTIMSET���Q�Ƃ��Ă��������B�g�p����I�v�V�����́ADisplay�A
% TolX�ł��B�I�v�V������ݒ肵�Ȃ��ꍇ�́AOPTIONS = [] �𗘗p���Ă�����
% ���B
%
% X = FZERO(FUN,X0,OPTIONS,P1,P2,...)�́A�֐�F = feval(FUN,X,P1,P2,...)
% �ɓn���t���I�Ȉ������w�肵�܂��BOPTIONS�̃f�t�H���g�l�𗘗p����ɂ́A
% ��s����w�肵�Ă��������B
%
% [X,FVAL] = FZERO(FUN,...)�́A�lX�ł̖ړI�֐�FUN�̒lFVAL���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FZERO(...)�́AFZERO�̏I����Ԃ��L�q���镶����
% EXITFLAG���o�͂��܂��B
% 
% EXITFLAG�́A���̂悤�ɂȂ�܂��B
%    >0 : FZERO�̓[���_X�����߂܂����B
%    <0 : ��ԓ��Ŋ֐��̕������ω����镔�����Ȃ��A�܂��͕������ω������
%         �ԂŁA�T�[�`����NaN�܂���Inf�����o���ꂽ�A�܂��͕������ω�����
%         ��ԂŁA�T�[�`���ɕ��f���֐��l�����o���ꂽ�B
%
% [X,FVAL,EXITFLAG,OUTPUT] = FZERO(...)�́AOUTPUT.iterations�ɌJ���
% ���񐔂����\����OUTPUT���o�͂��܂��B
%
% ���
%     FUN �́A@:���g���Đݒ肷�邱�Ƃ��ł��܂��B
%        X = fzero(@sin,3)
%     �́A�΂��o�͂��܂��B
%        X = fzero(@sin,3,optimset('disp','iter')) 
% �́A�f�t�H���g�̃g�������X���g���ă΂��o�͂��A�J��Ԃ��v�Z�̏���\
% �����܂��B
%
%     FUN �́Aanonymous function �ł��ݒ�ł��܂��B
%        X = fzero(@(x) sin(3*x),2)
%
% ����
%        X = fzero(@(x) abs(x)+1, 1) 
% �́A�������̂ǂ�Ȉʒu�ł��������ω����Ȃ�(�[���ɂȂ�Ȃ�)�̂ŁA NaN 
% ���o�͂��܂��B
%        X = fzero(@tan,2)
% �́A�_ X �̋ߖT�ł��̊֐����s�A���Ȃ̂ŁAX �Ŋ֐��̕������ω������
% ���Ɍ����邽�߁A1.5708 �ߖT�� X ���o�͂��܂��B
%
% �Q�l ROOTS, FMINBND, FUNCTION_HANDLE.

%   Copyright 1984-2004 The MathWorks, Inc. 

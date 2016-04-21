%FMINBND �X�J���Ŕ͈͂̐����t��������`�֐��̍ŏ���
% X = FMINBND(FUN,x1,x2)�́Ax0����n�߁Ax1 < X < x2�͈̔͂ŁA(�ʏ�A
% M-�t�@�C���ŋL�q���ꂽ)FUN�ɋL�q���ꂽ�֐��̋Ǐ��I�ȍŏ��l�ɑΉ�����
% X���o�͂��܂��BFUN�́A�X�J������ X ���󂯓���AX �ł̃X�J���֐��l F 
% ���o�͂��܂��B
%
%   X = FMINBND(FUN,x1,x2,OPTIONS) �́A�f�t�H���g�̍œK�p�����[�^�̑���
% �ɁAOPTIMSET�֐��ō쐬���ꂽOPTIONS�\���̂̒l���g���čŏ������s���܂��B
% �ڂ����́AOPTIMSET���Q�Ƃ��Ă��������BFMINBND�́A���̃I�v�V�����A
% Display, TolX, MaxFunEval, MaxIter, FunValCheck, OutputFcn ���g���܂��B
%
% X = FMINBND(FUN,x1,x2,OPTIONS,P1,P2,...) �́A�ړI�֐� FUN(X,P1,P2,...)
% �ɓn���t���I�Ȉ������w�肵�܂�(�I�v�V������ݒ肵�Ȃ��ꍇ�́A
% �v���C�X�z���_�Ƃ��āAOPTIONS = [] �𗘗p���Ă�������)�B
%
% [X,FVAL] = FMINBND(...)�́A�l X �ł̖ړI�֐� FUN �̒l FVAL ���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FMINBND(...) �́A�܂��AFMINBND �̏I����Ԃ��L�q���� 
% EXITFLAG ���o�͂��܂��B
%   EXITFLAG ���A
%     1 �̏ꍇ�AFMINBND�́AOPTIONS.TolFun���x�[�X�ɂ����� X �Ɏ������܂����B
%     0 �̏ꍇ�A�֐��]���A�܂��́A�J��Ԃ��̍ő吔�ɓ��B���܂����B
%    -1 �̏ꍇ�A�œK���́A���[�U�ɂ��I������܂��B
%    -2 �̏ꍇ�A���E�� inconsistent (���Ȃ킿�Aax > bx) �ł��B
%
% [X,FVAL,EXITFLAG,OUTPUT] = FMINBND(...) �́AOUTPUT.iterations �̒��̌J��
% �Ԃ��񐔁AOUTPUT.funcCount �̒��̊֐��]���̐��AOUTPUT.algorithm �̒���
% �A���S���Y�����AOUTPUT.message �̒��̏I�����b�Z�[�W���܂񂾍\����
% OUTPUT ���o�͂��܂��B
%
% ���
% FUN �́A@:���g���Đݒ肷�邱�Ƃ��ł��܂��B
%        X = fminbnd(@cos,3,4)
% �́A�����܂Ń΂��v�Z���A�I�����Ƀ��b�Z�[�W��\�����܂��B

%  [X,FVAL,EXITFLAG] = fminbnd(@cos,3,4,optimset('TolX',1e-12,'Display','off'))
% �́A�΂�12���܂Ōv�Z���A�o�͂�\�����Ȃ��ŁAx �ł̊֐��l���o�͂��A
% EXITFLAG ��1���o�͂��܂��B
%
% FUN �́Aanonymous function �ł��ݒ肷�邱�Ƃ��ł��܂��B
%        f = @(x) sin(x)+3;
%        x = fminbnd(f,2,5)
%
% �Q�l OPTIMSET, FMINSEARCH, FZERO, FUNCTION_HANDLE.

%   Reference: "Computer Methods for Mathematical Computations",
%   Forsythe, Malcolm, and Moler, Prentice-Hall, 1976.

%   Original coding by Duane Hanselman, University of Maine.
%   Copyright 1984-2004 The MathWorks, Inc.

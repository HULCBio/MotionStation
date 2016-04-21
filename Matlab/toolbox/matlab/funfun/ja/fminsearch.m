%FMINSEARCH �������̐���Ȃ��̔���`�ŏ���(Nelder-Mead�@�j
% X = FMINSEARCH(FUN,X0)�́A�����ݒ�x�N�g��X0�̋ߖT��FUN�ɋL�q���ꂽ
% �֐��̋ɏ��l�̈ʒu�������x�N�g��X���o�͂��܂��BFUN�́A���� X ��
% �󂯓���AX �Ōv�Z�����X�J���֐��l F ���o�͂��܂��BX0 �́A�X�J���A
% �x�N�g���A�s��̂�����ł��\���܂���B
%
% X = FMINSEARCH(FUN,X0,OPTIONS)  �́A�f�t�H���g�̍œK�p�����[�^�̑�
% ���ɁAOPTIMESET �֐��ō쐬���ꂽ OPTIONS �\���̂̒l���g���čŏ�
% �����s���܂��B�ڂ����́AOPTIMSET ���Q�Ƃ��Ă��������BFMINSEARCH �́A
% �I�v�V���� Display, TolX, TolFun, MaxFunEvals, MaxIter, FunValCheck,
% OutputFcn ���g�p���܂��B 
%
% X = FMINSEARCH(FUN,X0,OPTIONS,P1,P2,...)  �́A�ړI�֐� 
% F=FUN(X,P1,P2,...) �ɓn���t���I�Ȉ������w�肵�܂��B
% �f�t�H���g�l�𗘗p����ɂ�OPTIONS�ɋ�s����w�肵�Ă�������
% (�I�v�V������ݒ肵�Ȃ��ꍇ�́A�v���C�X�z���_�Ƃ��� OPTION = [] 
% �𗘗p���Ă�������)�B
%
% [X,FVAL] =  FMINSEARCH(...) �́A�l X �ł̖ړI�֐� FUN �̒l FVAL ��
% �o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FMINSEARCH(...) �́AFMINSEARCH�̏I����Ԃ��L�q����
% ������EXITFLAG���o�͂��܂��B
%   EXITFLAG ���A
%     1�̏ꍇ�AFMINSEARCH �͉� X �Ŏ������Ă��܂��B
%   �@0�̏ꍇ�A�֐��]���v�Z�̍ő吔�܂��͌J��Ԃ����ɒB���Ă��܂��B
%    -1�̏ꍇ�A�œK���̓��[�U�ɂ��I������܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT] = FMINSEARCH(...) �́AOUTPUT.iterations �̒��̌J��
% �Ԃ��񐔁AOUTPUT.funcCount �̒��̊֐��]���̐��AOUTPUT.algorithm �̒���
% �A���S���Y�����AOUTPUT.message �̒��̏I�����b�Z�[�W���܂񂾍\����
% OUTPUT ���o�͂��܂��B
%
% ���
% FUN �́A@ ���g���āA�ݒ肷�邱�Ƃ��ł��܂��B
%        X = fminsearch(@sin,3)
% �́A�l3�̋ߖT�ŁASIN �̍ŏ��l�����߂܂��B���̏ꍇ�ASIN �́AX �ł̃X�J
% ���֐��l SIN ���o�͂��܂��B
%
% FUN �́Aanonymous function���g���āA�ݒ肷�邱�Ƃ��ł��܂��B
%        X = fminsearch(@(x) norm(x),[1;2;3])
% �́A [0;0;0] �̋ߖT�ōŏ��l���o�͂��܂��B
%
% FMINSEARCH �́ANelder-Mead �V���v���b�N�X(����)�@���g���Ă��܂��B
%
% �Q�l OPTIMSET, FMINBND, FUNCTION_HANDLE.

% Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
% Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
% Method in Low Dimensions", SIAM Journal of Optimization, 9(1):
% p.112-147, 1998.

%   Copyright 1984-2004 The MathWorks, Inc.

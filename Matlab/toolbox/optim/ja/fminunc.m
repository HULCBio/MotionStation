% FMINUNC   ���ϐ��֐��̍ŏ���
%
% X = FMINUNC(FUN,X0) �́A�����l�� X0 �Ƃ��āAFUN �ɂ��\�����֐���
% �ŏ�������X �����߂܂��BFUN �́AX ����͂Ƃ��āAX �ł̊֐��l F ���o��
% ���܂��BX0 �́A�X�J���A�x�N�g���A�܂��́A�s��ł��B
% 
% X = FMINUNC(FUN,X0,OPTIONS) �́AOPTIMSET �֐��ɂ���āA�������쐬���ꂽ
% OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^��u�������܂��B�ڍׂ́A
% OPTIMSET ���Q�Ƃ��Ă��������B�����ł́ADisplay, TolX, TolFun, 
% DerivativeCheck, Diagnostics, GradObj,HessPattern, LineSearchType, 
% Hessian, HessMult, HessUpdate, MaxFunEvals, MaxIter, DiffMinChange, 
% DiffMaxChange, LargeScale, MaxPCGIter, PrecondBandWidth, TolPCG, TypicalX 
% �p�����[�^���g���܂��B�I�v�V���� GradObj ���g���āA2�̏o�͈�����
% �������֐� FUN ���R�[�����A2�Ԗڂ̏o�͈��� G �ɁA�_ X �ł̊֐��̕Δ���
% �W�� df/dX ��ݒ肷�邱�Ƃ��ł��܂��B[F,G] = feval(FUN,X) �̌^�ŃR�[��
% ���܂��B�I�v�V���� Hessian ���g���āA3�̏o�͈��������� FUN ���R�[��
% ���邱�Ƃ��ł��܂��B2�Ԗڂ̈��� G �́A�� X �ł̊֐� df/dX �̕Δ����W��
% �ŁA3�Ԗڂ̈��� H �́A2�K����(Hessian)�ɂȂ�܂��B[F,G,H] = feval(FUN,X) 
% �̌^�ŃR�[�����܂��BHessian �́A��K�̓X�P�[�����ł̂ݎg���A���C��
% �T�[�`�@�ł́A�g���܂���B
%
% X = FMINUNC(FUN,X0,OPTIONS,P1,P2,...)  �́A���Ɋ֘A�����p�����[�^ 
% P1,P2,... ���A���ځA�֐� FUN �ɓn���܂��B���Ƃ��΁Afeval(FUN,X,P1,P2,...) 
% �̌^�Ŏg���܂��B���� OPTIONS �Ƀf�t�H���g�l���g�p����ꍇ�́A��s���
% �n���Ă��������B
%
% [X,FVAL] = FMINUNC(FUN,X0,...) �́A�� X �ł̖ړI�֐��l���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FMINUNC(FUN,X0,...) �́AFMINUNC �̏I���󋵂�����
% ������  EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AFMINUNC �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AFMINUNC �́A���Ɏ������܂���ł����B
%
% [X,FVAL,EXITFLAG,OUTPUT] = FMINUNC(FUN,X0,...) �́A�J��Ԃ��� 
% OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p�����A���S���Y�� 
% OUTPUT.algorithm�A(�g�p�����ꍇ)CG �J��Ԃ��̉� OUTPUT.cgiterations
% (�g�p�����ꍇ)�ꎟ�̍œK�l OUTPUT.firstorderopt ���\���� OUTPUT ��
% �o�͂��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,GRAD] = FMINUNC(FUN,X0,...) �́A�� X �ł̊֐� 
% FUN �̌��z�l���o�͂��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,GRAD,HESSIAN] = FMINUNC(FUN,X0,...) �́A�� X 
% �ł̖ړI�֐� FUN ��Hessian�l���o�͂��܂��B
% 
% ��� 
% FUN �́A@ ���g���āA�ݒ肷�邱�Ƃ��ł��܂��B
%
%        X = fminunc(@myfun,2)
%
% �����ŁAMYFUN �́A���̂悤�ɕ\�킳��� MATLAB �֐��ł��B
% 
%        function f = myfun(x)
%         f = sin(x)+3;
%
% �^����ꂽ���z���g���āA�֐����ŏ������邽�߂ɁA���z��2�Ԗڂ̈�����
% ����悤�� MYFUN ��ύX���܂��B
% 
%        function [f,g] =  myfun(x)
%         f = sin(x) + 3;
%         g = cos(x);
% 
% �����āA(OPTIMSET ���g����)OPTIONS.GradObj �� 'on' �ɐݒ肵�A���z�l��
% �g�p�ł���悤�ɂ��܂��B
% 
%        options = optimset('GradObj','on');
%        x = fminunc('myfun',4,options);
%
% FUN ���C�����C���I�u�W�F�N�g���g���Đݒ肷�邱�Ƃ��ł��܂��B
% 
%        x = fminunc(inline('sin(x)+3'),4);
% 
% �Q�l : OPTIMSET, FMINSEARCH, FMINBND, FMINCON, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:05 $
%   Andy Grace 7-9-90.

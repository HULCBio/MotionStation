% FSEMINF   ����������t���œK�����������܂��B
%
% FSEMINF �́A���̌^�̖��������܂��B��ԓ��ɑ��݂��邷�ׂĂ� w ��
% �΂��āAx ��ω������āA{ F(x) | C(x)< = 0 , Ceq(X) = 0 , PHI(x,w)< = 0 } 
% �� F(x) ���ŏ������܂��B
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON) �́A�����l�� X0 �Ƃ��āASEMINFCOM 
% (�ʏ�AM-�t�@�C��)�Ő������ꂽNTHETA ����������̂��ƂŁA�֐� FUN ��
% ���\�����֐����ŏ������� X �����߂܂��B�֐� FUN �́Afeval ���g���āA
% F = feval(FUN,X) �̌^�ŃR�[�����ꂽ�Ƃ��AX �Ɋւ���X�J���֐��l F ��
% �o�͂��܂��B�֐� SEMINFCON �́A����`�s�������� C�A����`�������� Ceq�A
% �e��ԂŐ��肳��� NTHETA �������s�������� PHI_1, PHI_2, ..., PHI_NTHETA 
% �Ɋւ���x�N�g�����o�͂��܂��B���̌^�ŁA�g�p���܂��B
% [C,Ceq,PHI_1,PHI_2,...,PHI_NTHETA,S] = feval(SEMINFCON,X,S)�FS �́A
% ��������T���v���Ԋu�ŁA�g�p���Ă��A���Ȃ��Ă��\���܂���B
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B) �́A���`�s���� A*X < =  B ��
% �������悤�Ƃ��܂��B
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq) �́A���`���� Aeq*X = Beq 
% ���������悤�Ƃ��܂�(�s���������݂��Ȃ��ꍇ�AA = [] �� B = [] ��ݒ肵��
% ��������)�B
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB) �́A�݌v�ϐ� X 
% �̏㉺���͈̔͂�^���܂��B���̏ꍇ�A���́ALB <= X <= UB �͈̔͂ɓ���܂��B
% �͈͂ɂ�鐧�񂪂Ȃ��ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) ��
% �������Ȃ��ꍇ�ALB(i) = -Inf �Ɛݒ肵�AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf 
% �Ɛݒ肵�܂��B
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB,OPTIONS) �́A
% OPTIMSET �֐��ɂ���āA�������쐬���ꂽ OPTIONS �\���̂��f�t�H���g
% �I�v�V�����p�����[�^�ƒu�������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B
% �����ł́ADisplay, TolX, TolFun, TolCon, DerivativeCheck, Diagnostics,
% GradObj,  MaxFunEvals, MaxIter, DiffMinChange and DiffMaxChange �p�����[�^
% ���g���܂��B�I�v�V���� GradObj ���g���āA2�̏o�͈������������֐� 
% FUN ���R�[�����A2�Ԗڂ̏o�͈��� G �ɁA�_ X �ł̊֐��̕Δ����W�� df/dX 
% ��ݒ肷�邱�Ƃ��ł��܂��B[F,G] = feval(FUN,X) �̌^�ŃR�[�����܂�
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB,OPTIONS,P1,P2,.)
% �́A���Ɋ֘A�����p�����[�^ P1,P2,... ���A���ځA�֐� FUN �� SEMINFCON ��
% �n���܂��B���Ƃ��΁Afeval(FUN,X,P1,P2,...) �� feval(SEMINFCON,X,P1,P2,...)
% �̌^�Ŏg���܂��B�I�v�V������ݒ肵�Ȃ��ꍇ�AOPTIONS ��ݒ肷��ʒu�ɁA
% [] ��ݒ肵�Ă��������B
%
% [X,FVAL] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) �́A�� X �ł̖ړI�֐��l 
% FUN ���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) �́AFSEMINF ��
% �I���󋵂����������� EXITFLAG ���o�͂��܂��B
% 
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AFSEMINF �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AFSEMINF �́A���Ɏ������܂���ł����B
% 
% [X,FVAL,EXITFLAG,OUTPUT] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) �́A
% �J��Ԃ��� OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p
% �����A���S���Y�� OUTPUT.algorithm ���\���� OUTPUT �ɏo�͂��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...)
% �́A�� X �ł� Lagrange �搔���o�͂��܂��BLAMBDA �\���̂́ALAMBDA.lower
% �� LB ���ALAMBDA.upper �� UB ���ALAMBDA.ineqnonlin �ɔ���`�s�������A
% LAMBDA.eqnonlin �ɔ���`������ݒ肵�Ă��܂��B
% 
% ���
% FUN �� SEMINFCOM �́A@ ���g���āA�ݒ肷�邱�Ƃ��ł��܂��B
%
%        x = fseminf(@myfun,[2 3 4],3,@myseminfcon)
%
% �����ŁAMYFUN �́A���̂悤�ɕ\�킹�� MATLAB �֐��ł��B
% 
%    function F = myfun(x)
%    F = x(1)*cos(x(2))+x(3)^3:
% 
% �܂��AMYSEMINFCON ���A���̂悤�ɕ\�킹�� MATLAB �֐��ł��B
% 
%       function [C,Ceq,PHI1,PHI2,S] = myseminfcon(X,S)
%       C = ... ;     % C �� Ceq ���v�Z����R�[�h�F��s��ł��\�ł��B
%       Ceq = ... ;
%       if isnan(S(1,1))
%          S = ... ; % S �� ntheta �s2��̍s��ł��B
%       end
%       PHI1 = ... ;       % PHI ���v�Z����R�[�h
%       PHI2 = ... ;
% �@�@�@�@�@
% �Q�l : OPTIMSET, @, FGOALATTAIN, LSQNONLIN.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:07 $

% FMINCON   ����t�����ϐ��֐��̍ŏ���
%
% FMINCON �́A���̌`���̖��������܂��B
% F(X) ���A���̐���̂��ƂŁA
% �@�@�@�@�@�@A*X  <= B, Aeq*X  = Beq (���`����)
%       �@�@�@C(X) <= 0, Ceq(X) = 0   (����`����)
%       �@�@�@LB <= X <= UB            
% �ŁAX ��ω������āA�ŏ������܂��B
% 
% X = FMINCON(FUN,X0,A,B) �́A�����l�� X0 �Ƃ��āA���`�s�������� A*X <= B 
% �̐���̂��ƂŁAFUN �ɂ��\�����֐����ŏ������� X �����߂܂��BX0 �́A
% �X�J���A�x�N�g���A�܂��́A�s��ł��B
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq) �́AA*X <= B �Ɠ��l�ɐ��`�������� 
% Aeq*X = Beq �̐���̂��Ƃ� FUN ���ŏ������܂�(�s�������񂪂Ȃ��ꍇ�́A
% A=[] �� B=[] �Ƃ��Đݒ肵�܂�)�B
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB) �́A�݌v�ϐ� X �̏㉺���͈̔͂�
% �^���܂��B���̏ꍇ�́A���́ALB <= X <= UB �͈̔͂ɓ���܂��B�͈͂ɂ��
% ���񂪂Ȃ��ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) �ɉ������Ȃ�
% �ꍇ�ALB(i) = -Inf �Ɛݒ肵�AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf �Ɛݒ�
% ���܂��B
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) �́ANONLCON �Œ�`���ꂽ
% ����̂��Ƃōŏ������܂��B�֐� NONLCON �́A�x�N�g�� C �� Ceq �ɂ����
% �\��������`�s�����Ɣ���`�����̒l���o�͂��܂��BFMINCON �́AC(X) <= 0 
% �� Ceq(X) = 0 �ƂȂ�  FUN ���ŏ������܂�(�͈͂̐��񂪂Ȃ��ꍇ�ALB=[] �� 
% UB=[] �Ƃ��Đݒ肵�܂�)�B
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) �́AOPTIMSET ��
% ���ɂ���āA�쐬���������� OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^
% �̑���ɗ^���܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł́A
% Display, TolX, TolFun, TolCon, DerivativeCheck, Diagnostics, GradObj, 
% GradConstr, Hessian, MaxFunEvals, MaxIter, DiffMinChange and DiffMaxChange,
% LargeScale, MaxPCGIter, PrecondBandWidth, TolPCG, TypicalX, Hessian, 
% HessMult, HessPattern �p�����[�^���g���܂��B
% 
% �I�v�V���� GradObj ���g���āA�Q�Ԗڂ̏o�͈��� G �ɓ_ X �ł̊֐��̕Δ���
% �W�� df/dX ���o�͂��� FUN ��ݒ肵�܂��B�I�v�V���� Hessian ���g���āA
% 3�Ԗڂ̏o�͈��� H �ɁA�_ X �ł̊֐���2�K����(�w�V�A��)���o�͂��� FUN 
% ��ݒ肵�܂��B�w�V�A���́A��K�͖��݂̂Ɏg�p����A���C���T�[�`�@�ł�
% �g�p����܂���B�I�v�V���� GradConstr ���g���āANONLCON ���A3�Ԗڂ�
% �o�͈����� GC �A4�Ԗڂ̈����� GCeq �����悤�ɐݒ肵�܂��B�����ŁAGC ��
% �s��������x�N�g�� C �̕Δ����W���AGCeq �́A��������x�N�g�� Ceq �̕Δ���
% �W���ł��B�I�v�V������ݒ肵�Ȃ��ꍇ�́AOPTIONS = [] ���g�p���Ă��������B
% 
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS,P1,P2,...)  �́A
% ���Ɋ֘A�����p�����[�^ P1,P2,... ���A���ځA�֐� FUN �� NONLCON ��
% �n���܂��B���Ƃ��΁Afeval(FUN,X,P1,P2,...) �� feval(NONLCON,X,P1,P2,...)
% �̌^�Ŏg���܂��B���� A, B, Aeq, Beq, OPTIONS, LB, UB, NONLCON �Ƀf�t�H���g
% �l���g�p����ꍇ�́A��s���n���Ă��������B
%
% [X,FVAL] = FMINCON(FUN,X0,...) �́A�� X �ł̖ړI�֐��l FUN ���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FMINCON(FUN,X0,...) �́AFMINCON �̏I���󋵂�����
% �t���O EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AFMINCON �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AFMINCON �́A���Ɏ������܂���ł����B
% 
% [X,FVAL,EXITFLAG,OUTPUT] = FMINCON(FUN,X0,...) �́A�J��Ԃ��� 
% OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p�����A���S���Y�� 
% OUTPUT.algorithm(�g�p�����ꍇ)CG �J��Ԃ��̉񐔂� OUTPUT.cgiterations 
% (�g�p�����ꍇ)�ꎟ�̍œK�l OUTPUT.firstorderopt ���\���� OUTPUT �ɏo��
% ���܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = FMINCON(FUN,X0,...)  �́A�� X �ł� 
% Lagrange �搔 LAMBDA ���o�͂��܂��BLAMBDA �\���̂́ALAMBDA.lower �� LB
% ���ALAMBDA.upper �� UB ���ALAMBDA.ineqnonlin �ɔ���`�s�������A
% LAMBDA.eqnonlin �ɂ͔���`������ݒ肵�Ă��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD] = FMINCON(FUN,X0,...) �́A�� X ��
% �̊֐� FUN �̌��z�l���o�͂��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = FMINCON(FUN,X0,...) ��
% �� X �ł̊֐� FUN �� HESSIAN �l���o�͂��܂��B
%�@
% ���F
% FUN �́A@:X = fmincon(@hump,...) ���g���Đݒ�ł��܂��B���̏ꍇ�A
% F = humps(x) �́Ax �ł� HUMPS �֐��̃X�J���֐��l F ���o�͂��܂��B
% 
% FUN �́A�C�����C���I�u�W�F�N�g�Ƃ��Ă��\���ł��܂��B
% 
% X = fmincon(inline('3*sin(x(1))+exp(x(2)'),[1;1],[],[],[],[],[0 0])
% 
% �́AX = [0;0] ���o�͂��܂��B
% 
% �Q�l : OPTIMSET, FMINUNC, FMINBND, FMINSEARCH, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/05/01 12:59:59 $

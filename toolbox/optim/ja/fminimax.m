% FMINIMAX   ���ϐ��֐��̃~�j�}�b�N�X���������܂��B
%
% FMINMAX �́A���̖��������܂��B
% (max {FUN(X} )   �����ŁAFUN �� X �́A�x�N�g���A�܂��́A�s��ł��B
%   X
%
% X = MINIMAX(FUN,X0) �́AX0 �������l�Ƃ��āAFUN(�ʏ��M-�t�@�C�� FUN.M)
% �Œ�`�����֐��̃~�j�}�b�N�X�� X �����߂܂��BFUN �́AX �Ōv�Z����
% �֐��l F �̃x�N�g�����o�͂��܂��BX0 �́A�X�J���A�x�N�g���A�܂��́A
% �s��ł��B
%
% X = FMINIMAX(FUN,X0,A,B) �́A���`�s�������� A*X <= B �̂��ƂŃ~�j�}�b�N�X
% ���������܂��B
%
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq) �́A���`�������� Aeq*X = Beq �̂��Ƃ�
% �~�j�}�b�N�X���������܂�(�s�������񂪂Ȃ��ꍇ�ɂ́AA=[],B=[] �Ɛݒ�
% ���܂�)�B
% 
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB) �́A�݌v�ϐ� X �̏㉺���͈̔͂�
% ��`���܂��B�����ŁA���́ALB <= X <= UB �͈̔͂ɓ���܂��B�͈͂̐���
% �Ȃ��ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) �ɉ������Ȃ��ꍇ�A
% LB(i) = -Inf �Ƃ��AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf �Ɛݒ肵�܂��B
% 
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) �́ANONLCON �Œ�`���ꂽ
% ����̂��ƂŁA�~�j�}�b�N�X���������܂��B�֐� NONLCON �́Afeval ��
% ����āA[C,Ceq] = feval(NONLCON,X) �̂悤�ɃR�[�������Ƃ��A�x�N�g�� 
% C �� Ceq �ɂ���ĕ\��������`�s�����Ɣ���`�����̒l���o�͂��܂��B
% FMINMAX �́AC(X)< = 0 �� Ceq(X) = 0 �ƂȂ�悤�ɍœK�����܂��B
%
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)  �́AOPTIMSET 
% �֐��ɂ���āA�������쐬���ꂽ OPTIONS �\���̂��f�t�H���g�I�v�V����
% �p�����[�^�ƒu�������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł�
% Display, TolX, TolFun, TolCon, DerivativeCheck, GradObj, GradConstr, 
% MaxFunEvals, MaxIter, MeritFunction, MinAbsMax, Diagnostics, 
% DiffMinChange and DiffMaxChange�p�����[�^���g���܂��B�I�v�V���� 
% GradObj ���g���āA2�̏o�͈������������֐� FUN ���R�[�����A2�Ԗڂ�
% �o�͈��� G �ɓ_ X �ł̊֐��̕Δ����W�� df/dX ��ݒ肷�邱�Ƃ��ł��܂��B
% [F,G] = feval(FUN,X) �̌^�ŃR�[�����܂��BGradConstr �I�v�V�������g���āA
% NONLCON ��4�̏o�͈��������� [C,Ceq,GC,GCeq] = feval(NONLCON,X) ��
% �R�[�����邱�Ƃ��ł��܂��B�����ŁAGC �́A�s��������x�N�g�� C �̕Δ���
% �W���AGCeq �́A��������x�N�g�� Ceq �̕Δ����W���ł��B�I�v�V������ݒ�
% ���Ȃ��ꍇ�́AOPTIONS = [] ���g�p���Ă��������B
% 
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS,P1,P2,...)  �́A
% ���Ɋ֘A�����p�����[�^ P1,P2,... ���A���ځA�֐� FUN �� NONLCON ��
% �n���܂��B���Ƃ��΁Afeval(FUN,X,P1,P2,...) �� feval(NONLCON,X,P1,P2,...) 
% �̌^�Ŏg���܂��B���� A, B, Aeq, Beq, LB, UB, NONLCON, OPTIONS �Ƀf�t�H���g
% �l���g�p����ꍇ�́A��s���n���Ă��������B
%
% [X,FVAL] = FMINIMAX(FUN,X0,...) �́A�� X �ł̖ړI�֐��l FUN ���o�͂��܂��B
% ���̌^ FVAL = feval(FUN,X) �Ōv�Z���܂��B
%
% [X,FVAL,MAXFVAL] = FMINIMAX(FUN,X0,...) �́A�� X �ŁA
% MAXFVAL = max { FUN(X) } ���o�͂��܂��B
%
% [X,FVAL,MAXFVAL,EXITFLAG] = FMINIMAX(FUN,X0,...) �́AFMINIMAX �̏I��
% �󋵂����������� EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AFMINIMAX �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AFMINIMAX �́A���Ɏ������܂���ł����B
%   
% [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT] = FMINIMAX(FUN,X0,...) �́A�J��Ԃ�
% �� OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p����
% �A���S���Y�� OUTPUT.algorithm ���o�͂��܂��B
%
% [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT,LAMBDA] = FMINIMAX(FUN,X0,...)  �́A
% �� X �ł� Lagrange �搔 LAMBDA ���o�͂��܂��BLAMBDA �\���̂́ALB �� 
% LAMBDA.lower�@���AUB �� LAMBDA.upper ���A����`�s������ LAMBDA.ineqnonlin
% ���A����`������ LAMBDA.eqnonlin ��ݒ肵�Ă��܂��B
%
% ���
% FUN �́A@ ���g���Đݒ�ł��܂��B:
%
%        x = fminimax(@myfun,[2 3 4])
%
% �����ŁAMYFUN �́A���̂悤�� MATLAB �֐��ł��B:
% 
%   function F = myfun(x)
%   F = cos(x);
% 
% FUN �́A�C�����C���I�u�W�F�N�g�ł��ݒ�ł��܂��B
% 
%   fun = inline('sin(3*x)')
%   x = fminimax(fun,[2 5]);
% 
% �Q�l : OPTIMSET, @, INLINE, FGOALATTAIN, LSQNONLIN.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:01 $

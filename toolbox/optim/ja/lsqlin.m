% LSQLIN   ����t���ŏ������������܂��B
%
% X = LSQLIN(C,d,A,b) �́A���̌^�������ŏ������������܂��B
%
% A*x < =  b �̐���̂��ƂŁA0.5*(NORM(C*x-d)).^2 �� x �Ɋւ��čŏ�����
% �܂��B�����ŁAC �́Am�sn��̍s��ł��B
%
% X = LSQLIN(C,d,A,b,Aeq,beq) �́A(�����̐������������)�����ŏ����I
% �ɉ����܂��B
%
% A*x < =  b �� Aeq*x = beq �̐���̂��ƂŁA0.5*(NORM(C*x-d)).^2 ��x ��
% ���āA�ŏ������܂��B
%
% X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB) �́A�݌v�ϐ� X �̏㉺���͈̔͂�^��
% �܂��B���̏ꍇ�́A���́ALB <= X <= UB �͈̔͂ɓ���܂��B�͈͂ɂ�鐧��
% ���Ȃ��ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) �ɉ������Ȃ��ꍇ
% LB(i) = -Inf �Ɛݒ肵�AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf �Ɛݒ肵�܂��B
%
% X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0) �́A�����l�� X0 �Ƃ��܂��B
%
% X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0,OPTIONS) �́AOPTIMSET �֐��ɂ����
% �������쐬���ꂽ OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^�ƒu��
% �����āA�ŏ������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł́A
% Display, Diagnostics, TolFun, LargeScale, MaxIter, JacobMult, 
% PrecondBandWidth, TypicalX, TolPCG, MaxPCGIter �p�����[�^���g���܂��B
% �J�����g�ŁA'final' �� 'off' �݂̂��A�p�����[�^ Display �ɑ΂��Ďg���
% �܂�('iter' �́A�g���܂���)�B
%
% X=LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0,OPTIONS,P1,P2,...) �́A
% OPTIMSET('JacobMult',JMFUN) ���ݒ肳���Ƃ��A���Ɉˑ�����p�����[�^ 
% P1,P2,... �𒼐� JMFUN �֐��ɓn���܂��BJMFUN �́A���[�U�ɂ���ė^��
% ���܂��B�f�t�H���g�l���g�����߂ɁAA, b, Aeq, beq, LB, UB, XO, OPTIONS 
% �ɋ�s���n���Ă��������B
%
% [X,RESNORM] = LSQLIN(C,d,A,b) �́AX �ł̎c���̓�� 2 �m�����l 
% norm(C*X-d)^2 ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL] = LSQLIN(C,d,A,b) �́A�c�� C*X-d ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQLIN(C,d,A,b) �́ALSQLIN �̏I����
% ������������ EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B:
%    > 0 �̏ꍇ�ALSQLIN �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂�(��K�͖@�ł̂ݐ����܂�)�B
%    < 0 �̏ꍇ�A���ɐ��񂪂Ȃ��A���̈�A�܂��́ALSQLIN �́A���Ɏ�
%                �����܂���ł����B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQLIN(C,d,A,b) �́A�J��Ԃ�
% �� OUTPUT.iterations�A�g�p�����A���S���Y�� OUTPUT.algorithm�A(�g�p����
% �ꍇ)CG �J��Ԃ��̉�  OUTPUT.cgiterations �A(�g�p�����ꍇ)�ꎟ�̍œK�l
% OUTPUT.firstorderopt ���\���� OUTPUT �ɏo�͂��܂��B
%
% [x,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQLIN(C,d,A,b)  �́A�� 
% X �ł̃��O�����W��(Lagrangian)�搔 LAMBDA ���o�͂��܂��B: 
% LAMBDA.ineqyalities �ɐ��`�s���� C ���ALAMBDA.eqlin �ɐ��`���� Ceq ���A
% LAMBDA.lower �� LB ���ALAMBDA.upper �� UB ��ݒ肵�Ă��܂��B


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:02:07 $
%   Mary Ann Branch 9-30-96.

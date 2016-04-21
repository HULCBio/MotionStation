% QUADPROG �́A�񎟌v��@
%
% X = QUADPROG(H,f,A,b) �́A���̌^�ŁA�񎟌v��@�������܂��B
%
% A*x < =  b �̐���̂��ƂŁA0.5*x'*H*x + f'*x �� x �ɂ��čŏ������܂��B
% 
% X = QUADPROG(H,f,A,b,Aeq,beq) �́A�������� Aeq*x = beq �̂��ƂŁA���
% ���������܂��B
%
% X = QUADPROG(H,f,A,b,Aeq,beq,LB,UB) �́A�݌v�ϐ� X �̏㉺���͈̔͂��`
% ���܂��B�����ŁA���́ALB <= X <= UB �͈̔͂ɓ���܂��B�͈͂̐��񂪂Ȃ�
% �ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) �ɉ������Ȃ��ꍇ�A
% LB(i) = -Inf �Ƃ��AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf �Ɛݒ肵�܂��B
%
% X = QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0) �́A�����l X0 ���g�p���܂��B
%
% X = QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0,OPTIONS)  �́AOPTIMSET �֐���
% ����āA�������쐬���ꂽ OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^
% ��u�������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł́ADisplay, 
% Diagnostics, TolX, TolFun, HessMult, LargeScale,   MaxIter, 
% PrecondBandWidth, TypicalX, TolPCG, MaxPCGIter �p�����[�^���g���܂��B
% �p�����[�^ Display �ɑ΂��āA'final' �� 'off' ���g�p�ł��A'iter'��
% �g�p�ł��܂���B
%
% [X,FVAL] = QUADPROG(H,f,A,b) �́AX �ł̖ړI�֐��l FVAL = 0.5*X'*H*X + 
% f'*X ���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = QUADPROG(H,f,A,b) �́AQUADPROG �̏I���󋵂�����
% ������ EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AQUADPROG �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AQUADPROG �́A�L���łȂ��A����A�܂��́A���Ɏ�������
%                ����ł����B
%
% [X,FVAL,EXITFLAG,OUTPUT] = QUADPROG(H,f,A,b) �́A�J��Ԃ��� 
% OUTPUT.iterations�A�g�p�����A���S���Y�� OUTPUT.algorithm�A(�g�p����
% �ꍇ)CG �J��Ԃ��̉� OUTPUT.cgiterations �A(�g�p�����ꍇ)�ꎟ�̍œK�l 
% OUTPUT.firstorderopt ���\���� OUTPUT �ɏo�͂��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = QUADPROG(H,f,A,b) �́A���ɂ�����
% ���O�����W��(Lagrangian)�搔 LAMBDA ���o�͂��܂��B: LAMBDA.ineqlin ��
% ���`�s���� A ���ALAMBDA.eqlin �ɐ��`���� Aeq ���ALAMBDA.lower �� 
% LB ���ALAMBDA.upper �� UB ��ݒ肵�Ă��܂��B


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/05/01 13:02:44 $

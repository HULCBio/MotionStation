% LINPROG   ���`�v����
%
% X = LINPROG(f,A,b) �́A���̌`���̐��`�v����������܂��B:
%        
% �������:  A*x <= b �̐���̂��ƂŁAmin f'*x �� x �ɂ��āA�ŏ������܂��B
%  
% X = LINPROG(f,A,b,Aeq,beq) �́A�������� Aeq*x = beq �̂��ƂŁA��̖��
% �������܂��B
% 
% X = LINPROG(f,A,b,Aeq,beq,LB,UB) �́A�݌v�ϐ� X �̏㉺���͈̔͂�^���܂��B
% ���̏ꍇ�́A���́ALB <= X <= UB �͈̔͂ɓ���܂��B�͈͂ɂ�鐧�񂪂Ȃ�
% �ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) �ɉ������Ȃ��ꍇ�A
% LB(i) = -Inf �Ɛݒ肵�AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf �Ɛݒ肵�܂��B
%
% X = LINPROG(f,A,b,Aeq,beq,LB,UB,X0) �́A�����_ X0 �Ƃ��܂��B���̃I�v�V����
% �́Aactive-set �A���S���Y�����g�p����Ƃ��̂ݗ��p�ł��܂��B�f�t�H���g��
% ���_�A���S���Y���́A�������̋�łȂ������l�𖳎����܂��B
%
% X = LINPROG(f,A,b,Aeq,Beq,LB,UB,X0,OPTIONS) �́AOPTIMSET �֐��ɂ����
% �������쐬���ꂽ OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^�ƒu��
% �����邱�Ƃ��ł��܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł́A
% Display, Diagnostics, TolFun, LargeScale, MaxIter �p�����[�^���g���܂��B
% �J�����g�ŁALargeScale ���A'off' �̏ꍇ�A�p�����[�^ Display �ɂ́A
% 'final' �� 'off' �݂̂��g�p�ł��܂�(LargeScale �� 'on' �̂Ƃ��́A'iter' 
% �݂̂��g�p�ł��܂�)�B
%
% [X,FVAL] = LINPROG(f,A,b) �́AX �ŖړI�֐��l FVAL = f'*X ���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = LINPROG(f,A,b)  �́ALINPROG �̏I���󋵂�����������
% EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B:
%    > 0 �̏ꍇ�ALINPROG  �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�ALINPROG �́A���Ɏ������܂���ł����B
%
% [X,FVAL,EXITFLAG,OUTPUT] = LINPROG(f,A,b) �́A�J��Ԃ��� 
% OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p�����A���S���Y�� 
% OUTPUT.algorithm�A(�g�p�����ꍇ)CG �J��Ԃ��̉�  OUTPUT.cgiterations ��
% �\���� OUTPUT �ɏo�͂��܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = LINPROG(f,A,b) �́A���ɂ�����
% ���O�����W��(Lagrangian)�搔 LAMBDA ���o�͂��܂��B: LAMBDA.ineqlin ��
% ���`�s���� A ���ALAMBDA.eqlin �ɐ��`���� Aeq ���ALAMBDA.lower �� 
% LB ���ALAMBDA.upper �� UB ��ݒ肵�Ă��܂��B
%   
% ���ӁF
% LINPROG �̑�K�͖@(�f�t�H���g)�́Aprimal-dual �@���g���܂��B�����
% �o�Ζ��́A���Ɏ����\�ł��B����A�o�Ζ��A�܂��́A�����̂����ꂩ��
% ���s�\�ł���Ƃ������b�Z�[�W�́A�K�X�^�����܂��B����̕W���I��
% �`���́A�ȉ��̒ʂ�ł��B
% 
%              min f'*x    ������� A*x = b, x >= 0
% 
% �o�Ζ��́A�ȉ��̌`���ł��B
% 
%              max b'*y    ������� A'*y + s = f, s >= 0


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:02:00 $

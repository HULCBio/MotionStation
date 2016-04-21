% FGOALATTAIN   ���ړI�S�[�����B�œK�����������܂��B
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT) �́AFUN�i�ʏ��M-�t�@�C�� FUN.M)��
% �ݒ肳���ړI�֐�(F)���AX��ω������邱�Ƃɂ��A�S�[���iGOAL�j�ɓ��B
% �����܂��B
%
% �S�[���́AWEIGHT �ɏ]���āA�d�ݕt�����܂��B
% 
%            min     { LAMBDA :  F(X)-WEIGHT.*LAMBDA< = GOAL } 
%          X,LAMBDA  
%
% �֐� 'FUN' �́A�ړI�l F ��l X �Ōv�Z�����l�A�܂�AF = feval(FUN,X) 
% ���o�͂��܂��BX0 �́A�X�J���A�x�N�g���A�s��̂�����ł��\���܂���B
% 
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B) �́A���`�s���� A*X <= B �̐���
% �̂��ƂŁA�S�[�����B���������܂��B
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq) �́A���`������ Aeq*X =
% Beq �̐���̂��ƂŁA�S�[�����B���������܂��B
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB)  �́A�݌v�ϐ� X 
% �̏㉺����ݒ肵�܂��B����ɂ��AVLB < =  X < =  VUB �͈̔͂̉�������
% �邱�ƂɂȂ�܂��B�͈͂̐ݒ���s�Ȃ�Ȃ��ꍇ�́ALB �� UB �ɋ�s���
% �ݒ肵�Ă��������B�܂��A X(i) �ɉ�����ݒ肵�Ȃ��ꍇ�́ALB(i) = -Inf ��
% �����ݒ肵�Ȃ��ꍇ�́AUB(i) = Inf �Ɛݒ肵�Ă��������B
% 
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON) �́A
% NONLCON(�ʏ�́ANONLCON.M �Ɩ��t���� M-�t�@�C��)�Œ�`��������̂��ƂŁA
% �S�[�����B���������܂��B�֐� NONLCON �́Afeval: 
% [C, Ceq] = feval(NONLCON,X) �̌^�ŁA�R�[������A���ꂼ��A����`��
% �s��������Ɠ��������\�킷 C �� Ceq �x�N�g�����o�͂��܂��BFGOALATTAIN 
% �́AC(X)< = 0 �� Ceq(X) = 0 �ɂȂ�悤�ɍœK�����܂��B
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) 
% �́A�f�t�H���g�̍œK���p�����[�^���֐� OPTIMSET ���g���āA�\���� OPTIONS 
% �̒��̒l�ƒu�������āA�ŏ������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B
% �g�p�\�ȃI�v�V�����́ADisplay, TolX, TolFun, TolCon, DerivativeCheck, 
% GradObj, GradConstr, MaxFunEvals, MaxIter, MeritFunction, 
% GoalsExactAchieve, Diagnostics, DiffMinChange, DiffMaxChange�ł��B
% �I�v�V���� GradObj ���g���āA2�̏o�͈������������֐� FUN ���R�[�����A
% 2�Ԗڂ̏o�͈��� G �ɁA�_ X �ł̊֐��̕Δ����W�� df/dX ��ݒ肷�邱�Ƃ�
% �ł��܂��B[F,G] = feval(FUN,X) �̌^�ŃR�[�����܂��BGradConstr �I�v�V����
% ���g���āANONLCON ��4�̏o�͈��������� [C,Ceq,GC,GCeq] = feval(NONLCON,X)
% ���R�[�����邱�Ƃ��ł��܂��B�����ŁAGC �́A�s��������x�N�g�� C �̕Δ���
% �W���AGCeq �́A��������x�N�g�� Ceq �̕Δ����W���ł��B�I�v�V������ݒ�
% ���Ȃ��ꍇ�́AOPTIONS = [] ���g�p���Ă��������B
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS,P1,P2,...) 
% �́A���Ɋ֘A�����p�����[�^ P1,P2,... ���A���ځA�֐� FUN �� NONLCON ��
% �n���܂��B���Ƃ��΁Afeval(FUN,X,P1,P2,...) �� feval(NONLCON,X,P1,P2,...) 
% �̌^�Ŏg���܂��B���� A, B, Aeq, Beq, LB, UB, NONLCON, OPTIONS �Ƀf�t�H���g
% �l���g�p����ꍇ�́A��s���n���Ă��������B
%
% [X,FVAL] = FGOALATTAIN(FUN,X0,...) �́A�� X �ł̖ړI�֐��l FUN ���o��
% ���܂��B
%
% [X,FVAL,ATTAINFACTOR] = FGOALATTAIN(FUN,X0,...) �́A�� X �ł̓��B�t�@�N�^
% ���o�͂��܂��BATTAINFACTOR �����̏ꍇ�A�S�[���́A�ߓ��B�ɂȂ�܂��B
% �܂��A���̏ꍇ�A�����B�ɂȂ�܂��B
%
% [X,FVAL,ATTAINFACTOR,EXITFLAG] = FGOALATTAIN(FUN,X0,...) �́AFGOALATTAIN 
% �̏I���󋵂����������� EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AFGOALATTAIN �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AFGOALATTAIN �́A���Ɏ������܂���ł����B
%   
% [X,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT] = FGOALATTAIN(FUN,X0,...) �́A
% �J��Ԃ��� OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p
% �����A���S���Y�� OUTPUT.algorithm ���܂񂾍\���� OPTPUT ���o�͂��܂��B
% 
% [X,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT,LAMBDA] = FGOALATTAIN(FUN,X0,...)
% �́A�� X �ł� Lagrange �搔 LAMBDA ���o�͂��܂��BLAMBDA �\���̂́ALB 
% �� LAMBDA.lower ���AUB �� LAMBDA.upper ���A����`�s������ 
% LAMBDA.ineqnonlin ���A����`������ LAMBDA.eqnonlin ��ݒ肵�Ă��܂��B
%
% �ڍׂ́AM-�t�@�C�� FGOALATTAIN.M�@���Q�Ƃ��Ă��������B
%
% �Q�l : OPTIMSET, OPTIMGET.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/05/01 13:01:27 $

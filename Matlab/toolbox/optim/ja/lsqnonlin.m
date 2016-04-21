% LSQNONLIN   ����`�ŏ������������܂��B
%
% LSQNONLIN �́A���̌^�̖��������܂��B
% sum {FUN(X).^2} ���AX �Ɋւ��čŏ������܂��B�����ŁAX �� FUN �ŏo��
% �����l�́A�x�N�g���ł��A�s��ł��\���܂���B
%
% X = LSQNONLIN(FUN,X0) �́A�s�� X0 �������l�Ƃ��āAFUN �ɋL�q�����֐�
% �̓��a���ŏ��ɂ��܂��BFUN �́A�ʏ�AM-�t�@�C���ŋL�q����AF = FUN(X) 
% �̌`�ŁA�ړI�֐��̃x�N�g�����o�͂��܂��B���ӁFFUN �́AFUN(X) ���o�͂�
% ���a sum(FUN(X).^2))���o�͂�����̂ł͂���܂���(FUN(X) �́A�A���S
% ���Y���̒��ŁA�C���v���V�b�g�ɓ�悳��A�a���v�Z����Ă��܂�)�B
%
% X = LSQNONLIN(FUN,X0,LB,UB) �́A�݌v�ϐ� X �̏㉺���͈̔͂�^���܂��B
% ���̏ꍇ�́A���́ALB <= X <= UB �͈̔͂ɓ���܂��B�͈͂ɂ�鐧�񂪂Ȃ�
% �ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) �ɉ������Ȃ��ꍇ�A
% LB(i) = -Inf �Ɛݒ肵�AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf �Ɛݒ肵�܂��B
% 
% X = LSQNONLIN(FUN,X0,LB,UB,OPTIONS) �́AOPTIMSET �֐��ɂ���āA������
% �쐬���ꂽ OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^�ƒu��������
% �ŏ������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł́A �p�����[�^
% ���g���܂��B�I�v�V���� Jacobian ���g���āA2�̏o�͈������������֐� 
% FUN ���R�[�����A2�Ԗڂ̏o�͈��� J �ɁAJacobian �s���ݒ肷�邱�Ƃ�
% �ł��܂��B[F,J] = feval(FUN,X) �̌^�ŃR�[�����܂��BFUN ���AX ������  
% n �̂Ƃ��Am �v�f�̃x�N�g��(�s��)���o�͂���ꍇ�AJ �́Am�sn��̍s���
% �Ȃ�܂��B�����ŁAJ(i,j) �́AF(i) �� x(j) �ɂ��Δ����W���ł�(Jacobian 
% J �́AF �̌��z��]�u�������̂ł�)�B
%
% X = LSQNONLIN(FUN,X0,LB,UB,OPTIONS,P1,P2,..)  �́A���Ɋ֘A�����p�����[�^ 
% P1,P2,... ���A���ځA�֐� FUN �ɓn���܂��B���Ƃ��΁AFUN(X,P1,P2,...) ��
% �^�Ŏg���܂��B���� OPTIONS �Ƀf�t�H���g�l���g�p����ꍇ�́A��s���
% �n���Ă��������B
%
% [X,RESNORM] = LSQNONLIN(FUN,X0,...) �́AX �ł̎c����2�m���� sum(FUN(X).^2) 
% ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL] = LSQNONLIN(FUN,X0,...) �́AX �ł̎c���l 
% RESIDUAL = FUN(X) ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONLIN(FUN,X0,...) �́ALSQNONLIN ��
% �I���󋵂����������� EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B:
%    > 0 �̏ꍇ�ALSQNONLIN �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�ALSQNONLIN �́A���Ɏ������܂���ł����B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONLIN(FUN,X0,...) �́A�J��
% �Ԃ��� OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p����
% �A���S���Y�� OUTPUT.algorithm�A(�g�p�����ꍇ)CG �J��Ԃ��̉� 
% OUTPUT.cgiterations �A(�g�p�����ꍇ)�ꎟ�̍œK�l OUTPUT.firstorderopt 
% ���\���� OUTPUT �ɏo�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONLIN(FUN,X0,...) �́A
% �� X �ł̃��O�����W��(Lagrangian)�搔 LAMBDA ���o�͂��܂��B:
% LAMBDA.lower ��LB ���ALAMBDA.upper ��UB ��ݒ肵�Ă��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = LSQNONLIN(FUN,X0,...)
% �́A�� X �ł̊֐� FUN �� Jacobian �l���o�͂��܂��B
%
% ���
% FUN �́A@ ���g���Đݒ肷�邱�Ƃ��ł��܂��B:
%        x = lsqnonlin(@myfun,[2 3 4])
%
% �����ŁAMYFUN �́A���̂悤�ɋL�q���ꂽ MATLAB �֐��ł��B
%
%       function F = myfun(x)
%       F = sin(x);
%
% FUN �́A�C�����C���I�u�W�F�N�g�ł��ݒ肷�邱�Ƃ��ł��܂��B
%
%       fun = inline('sin(3*x)')
%       x = lsqnonlin(fun,[1 4]);
%
% �Q�l : OPTIMSET, LSQCURVEFIT, FSOLVE, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:02:09 $

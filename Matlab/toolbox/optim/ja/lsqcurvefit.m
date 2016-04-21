% LSQCURVEFIT   ����`�ŏ������������܂��B
%
% LSQCURVEFIT �́A���̌^�̖��������܂��B
% sum {(FUN(X,XDATA)-YDATA).^2} ��X��ω������āA�ŏ������܂��B
% �����ŁAX, XDATA, YDATA, FUN �̏o�͒l�́A�x�N�g���܂��͍s��ł��B
%
% X = LSQCURVEFIT(FUN,X0,XDATA,YDATA) �́A�����l�� X0 �Ƃ��AFUN �Œ�`
% �������`�֐����f�[�^ YDATA �ɁA�ŏ����I�ɍœK�ߎ�����W�� X ������
% �܂��BFUN �́AX �� XDATA ����͂��A�֐��l F �̃x�N�g��(�܂��́A�s��)��
% �o�͂��܂��B�����ŁAF �́AYDATA �Ɠ����T�C�Y�ŁAX �� XDATA �Ōv�Z����
% ���̂ł��B���ӁFFUN �́AFUN(X,XDATA) ���o�͂��A���a�� 
% sum(FUN(X,XDATA).^2) ���o�͂��܂���(FUN(X,XDATA) �́A�A���S���Y����
% ���ŁA�����I�ɘa���v�Z���A��悳��܂�)�B
%
% X = LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB) �́A�݌v�ϐ� X �̏㉺����
% �͈͂�^���܂��B���̏ꍇ�́A���́ALB <= X <= UB �͈̔͂ɓ���܂��B
% �͈͂ɂ�鐧�񂪂Ȃ��ꍇ�ALB �� UB �ɋ�s���ݒ肵�Ă��������BX(i) ��
% �������Ȃ��ꍇ�ALB(i) = -Inf �Ɛݒ肵�AX(i) �ɏ�����Ȃ��ꍇ�AUB(i) = Inf 
% �Ɛݒ肵�܂��B
% 
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS) �́AOPTIMSET �֐���
% ����āA�������쐬���ꂽ OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^
% ��u�������āA�ŏ������܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�����ł́A
% Display, TolX, TolFun, DerivativeCheck, Diagnostics, Jacobian, JacobMult, 
% JacobPattern, LineSearchType, LevenbergMarquardt, MaxFunEvals, MaxIter, 
% DiffMinChange and DiffMaxChange, LargeScale, MaxPCGIter, PrecondBandWidth, 
% TolPCG, TypicalX �p�����[�^���g���܂��B�I�v�V���� Jacobian ���g���āA
% 2�̏o�͈������������֐� FUN ���R�[�����A2�Ԗڂ̏o�͈��� J �ɁAJacobian
% �s���ݒ肷�邱�Ƃ��ł��܂��B[F,J] = feval(FUN,X) �̌^�ŃR�[�����܂��B
% FUN ���AX ������ n �̏ꍇ�Am �v�f�̃x�N�g��(�s��)���o�͂���ꍇ�AJ �́A
% m�sn��̍s��ɂȂ�܂��B�����ŁAJ(i,j) �́AF(i) �� x(j) �ɂ��Δ���
% �W���ł�(Jacobian J �́AF �̌��z��]�u�������̂ł�)�B
%
% X = LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS,P1,P2,..)  �́A����
% �֘A�����p�����[�^ P1,P2,... ���A���ځA�֐� FUN �ɓn���܂��B���Ƃ��΁A
% FUN(X,P1,P2,...)�̌^�Ŏg���܂��B���� OPTIONS �Ƀf�t�H���g�l���g�p����
% �ꍇ�́A��s���n���Ă��������B
%
% [X,RESNORM]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...)  �́AX �ł̎c����2�m����
% sum {(FUN(X,XDATA)-YDATA).^2} ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL] = LSQCURVEFIT(FUN,X0,...) �́A�� X �ł̎c���̒l 
% FUN(X,XDATA)-YDATA ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) �́A
% LSQCURVEFIT �̏I���󋵂����������� EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B:
%    > 0 �̏ꍇ�ALSQCURVEFIT �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�ALSQCURVEFIT �́A���Ɏ������܂���ł����B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) 
% �́A�J��Ԃ��� OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A
% �g�p�����A���S���Y�� OUTPUT.algorithm�A(�g�p�����ꍇ)CG �J��Ԃ��̉� 
% OUTPUT.cgiterations �A(�g�p�����ꍇ)�ꎟ�̍œK�l OUTPUT.firstorderopt 
% ���\���� OUTPUT �ɏo�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,) 
% �́A�� X �ł̃��O�����W��(Lagrangian)�搔 LAMBDA ���o�͂��܂��B:
% LAMBDA.lower �� LB ���ALAMBDA.upper �� UB ��ݒ肵�Ă��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) 
% �́A�� X �ł̊֐� FUN ��Jacobian�l���o�͂��܂��B
%
% ���
% FUN �́A@ ���g���Đݒ肷�邱�Ƃ��ł��܂��B:
% �@�@   xdata = [5;4;6];
%        ydata = 3*sin([5;4;6])+6;
%        x = lsqcurvefit(@myfun, [2 7], xdata, ydata)
%
% �����ŁAMYFUN �́A���� MATLAB �֐��ł��B
%
%       function F = myfun(x,xdata)
%       F = x(1)*sin(xdata)+x(2);
%
% FUN �́A�C�����C���I�u�W�F�N�g�Őݒ肷�邱�Ƃ��ł��܂��B:
%
%       fun = inline('x(1)*sin(xdata)+x(2)','x','xdata');
%       x = lsqcurvefit(fun,[2 7], xdata, ydata)
%
% �Q�l : OPTIMSET, LSQNONLIN, FSOLVE, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:02:04 $
%   Mary Ann Branch 8-22-96.

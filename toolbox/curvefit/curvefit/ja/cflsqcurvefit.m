% LSQCURVEFIT  ����`�ŏ������̉�@
% LSQCURVEFIT �́A���̌^�̖��������܂��B
%   min  sum {(FUN(X,XDATA)-YDATA).^2}  
%    X                                  
%                                       
% �����ŁAX, XDATA, YDATA, FUN ����o�͂����l�́A�x�N�g���A�܂��́A
% �s��ł��B
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA) �́AX0 ���X�^�[�g�_�Ƃ��āA�f�[�^ 
% YDATA ��FUN �̒��̔���`��������(����`�̈Ӗ���)�œK�ߎ�����W�� X ��
% ���߂܂��BFUN �́AX �� XDATA ����͂Ƃ��Ď󂯁A�֐��l F ����Ȃ�x�N
% �g��(�܂��́A�s��)���o�͂��܂��B�����ŁAF �� YDATA �Ɠ����T�C�Y�ŁAX 
% �� XDATA �Ōv�Z���ꂽ���̂ł��B
% 
% ���ӁFFUN �́AFUN(X,XDATA) ���o�͂��A���a sum(FUN(X,XDATA).^2)) ��
% �͂���܂���B(FUN(X,XDATA) �́A�A���S���Y���̒��ŁA�A�I�ɓ�悳��A
% �a���v�Z����܂�) 
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB) �́A�݌v�ϐ� X �ɉ����Ə����
% �ݒ肵�A���̂��߂ɁA���́ALB <= X <= UB �̃����W�ɂȂ�܂��B�͈͂�ݒ�
% ���Ȃ��ꍇ�ALB �� UB �ɂ́A��s����g���Ă��������BX(i) �ɉ���������
% �肵�Ȃ��ꍇ�́ALB(i) = -Inf ��X(i) �ɏ�������ݒ肵�Ȃ��ꍇ�́A
% UB(i) = Inf ��ݒ肵�Ă��������B
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS) �́A�֐� OPTIMSET �ō�
% �������\���� OPTIONS �̒��̒l���g���āA�f�t�H���g�ݒ�l�����������āA��
% �������s���܂��B�ڍׂ́AOPTIMSET ���Q�Ƃ��Ă��������B�g�p�\�ȃI�v�V��
% ���́ADisplay, TolX, TolFun, DerivativeCheck, Diagnostics, Jacobian, 
% JacobMult, JacobPattern, LineSearchType, LevenbergMarquardt, MaxFunEvals, 
% MaxIter, DiffMinChange, DiffMaxChange, LargeScale, MaxPCGIter, Precond-
% BandWidth, TolPCG, TypicalX �ł��BJacobian �I�v�V�������g���āA2�Ԗڂ�
% �o�͈��� J ���A�_ X �ł� Jacobian �s��ł���悤�� FUN ��ݒ肷�邱�Ƃ�
% �ł��܂��BFUN �́AX ������ n �̂Ƃ��ɁAm �v�f�̃x�N�g�� F ���o�͂����
% ���AJ �́Am �s n ��̍s��ɂȂ�܂��B�����ŁAJ(i,j) �́AF(i) �� x(j)��
% �ւ���Δ����ł�(Jacobian J �́AF �̌��z�̓]�u�ł�)�B
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS,P1,P2,..) �́A�֐� FUN:
% FUN(X,XDATA,P1,P2,..) �ɁA���Ɉˑ������p�����[�^ P1,P2,... �𒼐ړn
% ���܂��BOPTIONS �ɋ�s���n���ƁA�f�t�H���g�l���g���܂��B
%
% [X,RESNORM]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) �́AX �ł̎c����2�m��
% ��sum {(FUN(X,XDATA)-YDATA).^2} ���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL]=LSQCURVEFIT(FUN,X0,...) �́A�� X �ł̎c�� FUN(X,
% XDATA)-YDATA �̒l���o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) �́A
% LSQCURVEFIT �̏I���������L�q���������� EXITFLAG ���o�͂��܂��B
% 
%   EXITFLAG �́A�l�Ɉ˂�A���̈Ӗ��������܂��B
%      > 0 �FLSQCURVEFIT �́A�� X �Ɏ������܂��B
%      0   �F�֐��̌v�Z�񐔂��A�ݒ肵���񐔂ɒB���܂����B
%      < 0 �FLSQCURVEFIT �́A���Ɏ������܂���B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...)
% �́A�\���� OUTPUT ���o�͂��A���̗v�f�Ƃ��āAOUTPUT.iterations �ɌJ���
% ���񐔁AOUTPUT.funcCount �Ɋ֐��v�Z�̉񐔁AOUTPUT.algorithm �Ɏg�p����
% �A���S���Y���AOUTPUT.cgiterations ��CG �C�^���[�V�����̉񐔁AOUTPUT.fi-
% rstorderopt ��(�g�p���Ă���ꍇ)���`�œK�����o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA]=
% LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) �́A���ŁALagrangian �搔�� LAMB-
% DA �ɁALB �ɂ��ẮALAMBDA.lower ���AUB �ɂ��ẮALAMBDA.upper ��
% �o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN]=
% LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) �́AX �ł� FUN �� Jacobian ���o��
% ���܂��B
%
% ���
%     FUN �́A@ ���g���Ďw��ł��܂��B
%        xdata = [5;4;6];
%        ydata = 3*sin([5;4;6])+6;
%        x = lsqcurvefit(@myfun, [2 7], xdata, ydata)
%
% �����ŁAMYFUN �́A���̂悤�� MATLAB �֐��ł��B
%
%       function F = myfun(x,xdata)
%       F = x(1)*sin(xdata)+x(2);
%
% FUN �́Ainline �I�u�W�F�N�g�ł��\���܂���B
%
%       fun = inline('x(1)*sin(xdata)+x(2)','x','xdata');
%       x = lsqcurvefit(fun,[2 7], xdata, ydata)
%
% �Q�l   OPTIMSET, LSQNONLIN, FSOLVE, @, INLINE.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.

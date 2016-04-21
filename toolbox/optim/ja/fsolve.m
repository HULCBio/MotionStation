% FSOLVE   �ŏ����@���g���āA����`�������������܂��B
%
% FSOLVE �́A���̌`���̖��������܂��B
% 
% F(X) = 0    �����ŁAF �� X �́A�x�N�g���܂��͍s��ł��B   
%
% X = FSOLVE(FUN,X0) �́A�����l�� X0 �Ƃ��āAFUN �ɂ��\�����֐���
% �ŏ������� X �����߂܂��B�֐� FUN �́A�ʏ�AM-�t�@�C���ŁAF = FUN(X) 
% �̌^�ŃR�[�����ꂽ�Ƃ��AX �̓���̒l�ɑ΂���������̒l���o�͂��܂��B
%
% X = FSOLVE(FUN,X0,OPTIONS) �́AOPTIMSET �֐��ɂ���āA�������쐬���ꂽ
% OPTIONS �\���̂��f�t�H���g�I�v�V�����p�����[�^�ƒu�������܂��B�ڍׂ́A
% OPTIMSET ���Q�Ƃ��Ă��������B�����ł́ADisplay, TolX, TolFun, 
% DerivativeCheck, Diagnostics, Jacobian, JacobMult, JacobPattern, 
% LineSearchType, LevenbergMarquardt, MaxFunEvals, MaxIter, DiffMinChange, 
% DiffMaxChange, LargeScale, MaxPCGIter, PrecondBandWidth, TolPCG, TypicalX 
% �p�����[�^���g���܂��B�I�v�V���� Jacobian ���g���āA2�̏o�͈�����
% �������֐� FUN ���R�[�����A2�Ԗڂ̏o�͈��� J �ɁAJacobian �s���ݒ�
% ���邱�Ƃ��ł��܂��B[F,J] = feval(FUN,X) �̌^�ŃR�[�����܂��BFUN �́A
% X ������ n �̂Ƃ��� m �v�f�̃x�N�g��(�s��) F ���o�͂���ꍇ�AJ �́Am�s
% n��̍s��ɂȂ�܂��B�����ŁAJ(i,j) �́AF(i) �� x(j) �ɂ��Δ����W��
% �ł�(Jacobian J �́AF �̌��z��]�u�������̂ł�)�B
%
% X = FSOLVE(FUN,X0,OPTIONS,P1,P2,...)  �́A���Ɋ֘A�����p�����[�^ 
% P1,P2,... ���A���ځA�֐� FUN �ɓn���܂��B���Ƃ��΁AFUN(X,P1,P2,...) �̌^
% �Ŏg���܂��B���� OPTIONS �Ƀf�t�H���g�l���g�p����ꍇ�́A��s���n����
% ���������B
%
% [X,FVAL] = FSOLVE(FUN,X0,...) �́A�� X �ł̖ړI�֐��l���o�͂��܂��B
%
% [X,FVAL,EXITFLAG] = FSOLVE(FUN,X0,...) �́AFSOLVE �̏I���󋵂�����������
% EXITFLAG ���o�͂��܂��B
% EXITFLAG �́A���̈Ӗ���\�킵�܂��B
%    > 0 �̏ꍇ�AFSOLVE �́A�� X �Ɏ������Ă��܂��B
%    0   �̏ꍇ�A�֐��v�Z�̌J��Ԃ��񐔂��A�ݒ肵�Ă���ő�񐔂ɒB����
%                ���܂��B
%    < 0 �̏ꍇ�AFSOLVE �́A���Ɏ������܂���ł����B
%
% [X,FVAL,EXITFLAG,OUTPUT] = FSOLVE(FUN,X0,...) �́A�J��Ԃ��� 
% OUTPUT.iterations�A�֐��̌v�Z�� OUTPUT.funcCount�A�g�p�����A���S���Y�� 
% OUTPUT.algorithm�A(�g�p�����ꍇ)CG �J��Ԃ��̉� OUTPUT.cgiterations�A
% (�g�p�����ꍇ)�ꎟ�̍œK�l OUTPUT.firstorderopt ���\���� OUTPUT �ɏo��
% ���܂��B
%
% [X,FVAL,EXITFLAG,OUTPUT,JACOB] = FSOLVE(FUN,X0,...)  �́A�� X �ł̊֐�
% FUN ��Jacobian���o�͂��܂��B
% 
% ���F
% FUN �́A@ ���g���āA�ݒ肷�邱�Ƃ��ł��܂��B
%
%        x = fsolve(@myfun,[2 3 4],optimset('Display','iter'))
%
%�����ŁAMYFUN �́A���̂悤�� MATLAB �֐��ł��B
%
%       function F = myfun(x)
%       F = sin(x);
%
% FUN �́A�C�����C���I�u�W�F�N�g�ł��ݒ�ł��܂��B
%
%       fun = inline('sin(3*x)');
%       x = fsolve(fun,[1 4],optimset('Display','off'));
%
% �Q�l�FOPTIMSET, LSQNONLIN, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:09 $

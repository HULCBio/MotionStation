%FUNM  ��ʓI�ȍs��֐��̌v�Z
% F = FUNM(A,FUN) �́A�����s�� A �ŁA�֐� FUN ��]�����܂��B
% FUN(X,K) �́A�x�N�g�� X �ŕ]������� FUN �ɂ��\�킳���A�֐��� K�K
% ���֐����o�͂���K�v������܂��B
% MATLAB �֐� EXP, LOG, COS, SIN, COSH, SINH �́AFUN �Ƃ��ēn�����Ƃ��ł��܂��B
% ���Ȃ킿�AFUNM(A,@EXP), FUNM(A,@LOG), FUNM(A,@COS), FUNM(A,@SIN),
% FUNM(A,@COSH), FUNM(A,@SINH) �Ƃ��邱�Ƃ��ł��܂��B
% �s��̕������ɑ΂��āA����ɁASQRTM(A) ���g�p���Ă��������B
% �s��w���ɂ��ẮAA �Ɉˑ����āAEXPM(A) �� FUNM(A,@EXP) �̂����ꂩ���A
% ��萳�m�ɂȂ�܂��B
%
% FUN �ɂ��\�킳���֐��́A������̎������a������ Taylor ������
% ���K�v������܂��B
%
%   ���:
% FUNM ��1�x�R�[�����āAA �ł̊֐� EXP(X)+COS(X) ���v�Z���邽�߂ɂ́A
% �����g�p���Ă��������B
%       F = funm(A,@fun_expcos)
% �����ŁA
%       function f = fun_expcos(x,k)
%       % X �ł� EXP+COS �� k �K���֐����o��
%       g = mod(ceil(k/2),2);
%       if mod(k,2)
%          f = exp(x) + sin(x)*(-1)^g;
%       else
%          f = exp(x) + cos(x)*(-1)^g;
%       end
%
% F = FUNM(A,FUN,options) �́A�A���S���Y���̃p�����[�^���\���̃I�v�V����
% �̒l�ɐݒ肵�܂��B
%   options.Display:  �\�����x��
%                     [ {off} | on | verbose ]
%   options.TolBlk:   blocking Schur �^�ɑ΂��鋖�e�l
%                     [ ���̃X�J���[ {0.1} ]
%   options.TolTay:   �Ίp�u���b�N�� Taylor������]�����邽�߂�
%                     �I�����e�l
%                     [ ���̃X�J���[ {eps} ]
%   options.MaxTerms: Taylor �������̍ő吔
%                     [ ���̐��� {250} ]
%   options.MaxSqrt:  �ΐ����v�Z����ꍇ�Ainverse scaling and
%                     squaring method �Ōv�Z����镽�����̍ő吔
%                     [ ���̐��� {100} ]
%   options.Ord:      Schur �^, T �̎w�肵������
%                     T(i,i)���u�����u���b�N�̃C���f�b�N�X�Aoptions.Ord(i)
%                     �������� LENGTH(A) �̃x�N�g��
%                     [ integer vector {[]} ]
%
% F = FUNM(A,FUN,options,P1,P2,...) �́A�t���I�ȓ��� P1,P2,... �� 
% FEVAL(FUN,X,K,P1,P2,...)�̂悤�ɁA�֐��ɓn���܂��B
% �I�v�V�������ݒ肳��Ă��Ȃ��ꍇ�A�v���C�X�z���_�Ƃ��āAoptions = [] ��
% �g�p���Ă��������B
%
% [F,EXITFLAG] = FUNM(...) �́AFUNM �̏I���������L�q����X�J���[�� EXITFLAG 
% ���o�͂��܂��B
%   EXITFLAG = 0: �A���S���Y���̐���I��
%   EXITFLAG = 1: 1�܂��͕����� Taylor �������������܂���ł����B
%                 �������A�v�Z���ꂽ F �́A���m�ł��B
% ����: R13 �� �ȑO�̃o�[�W�����́A��2�o�͈����Ɍv�Z�ʂ������s���m�ɂȂ邱��
% �������덷�]�����o�͂��Ă������߁A���̓_�ňقȂ�܂��B
%
% [F,EXITFLAG,output] = FUNM(...) �́A�������\���� output ���o�͂��܂��B
%   output.terms(i):  i �Ԗڂ̃u���b�N��]������ꍇ�Ɏg�p����� Taylor ����
%                     �̐��A�܂��́A�ΐ��̏ꍇ�̕������̐�
%   output.ind(i):   �u���b�N���w�肷��Z���z��: 
%                    re-ordered Schur �^ T ��(i,j)�u���b�N�́A
%                    T(output.ind{i},output.ind{j}) �ł��B
%   output.ord:      ORDSCHUR �ɓn����鏇��
%   output.T:        re-ordered Schur �^
% Schur �^���Ίp�s��̏ꍇ�A
%   output = struct('terms',ones(n,1),'ind',{1:n})
%
% �Q�l EXPM, SQRTM, LOGM, @.

%   �Q�l����:
%   P. I. Davies and N. J. Higham.                                        
%   A Schur-Parlett algorithm for computing matrix functions.             
%   SIAM J. Matrix Anal. Appl., 25(2):464-485, 2003. 
%
%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc.


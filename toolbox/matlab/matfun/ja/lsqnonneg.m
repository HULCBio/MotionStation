% LSQNONNEG   �񕉐�������������`�ŏ����
% 
% X = LSQNONNEG(C,d) �́AX > =  0 �̐���ɏ]���āANORM(C*X - d) ���ŏ�
% �ɂ���x�N�g�� X ���o�͂��܂��B�����ŁAC �� d �͋��Ɏ����łȂ���΂Ȃ�
% �܂���B
%
% X = LSQNONNEG(C,d,X0) �́Aall(X0 > 0)�̏ꍇ�A�o���_�Ƃ��� X0 ���g����
% �������ȊO�ł́A�f�t�H���g���g���܂��B�f�t�H���g�̏o���_�͌��_�ł�
% (�f�t�H���g�́AX0 == [] �̏ꍇ�܂��͓��͈�����2�����ݒ肳��Ă��Ȃ���
% ���̂ǂ��炩�� �g���܂�)�B 
%
% X = LSQNONNEG(C,d,X0,OPTIONS) �́A�f�t�H���g�̍œK�p�����[�^�̑���
% �ɁA�֐� OPTIMSET �ō쐬���ꂽOPTIONS�\���̂̒l���g���čŏ������s
% ���܂��B�ڂ����́AOPTIMSET ���Q�Ƃ��Ă��������B�g�p����I�v�V�����́A
% Display�ATolX�ł�(�f�t�H���g�̋��e�͈� TolX �́A
% 10*MAX(SIZE(C))*NORM(C,1)*EPS ���g�p����܂�)�B
%
% [X,RESNORM] = LSQNONNEG(...) �́A�c���̕���2�m����norm(C*X-d)^2 ��
% �o�͂��܂��B
% 
% [X,RESNORM,RESIDUAL] = LSQNONNEG(...) �́A�c�� C*X-d ���o�͂��܂��B
% 
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONNEG(...) �́ALSQNONNEG��
% �I���������L�q���� EXITFLAG ���o�͂��܂��B 
% 
% EXITFLAG ��
%   1 �̏ꍇ�ALSQNONNEG �́A��X �Ɏ������܂��B
%   0 �̏ꍇ�A�J��Ԃ��񐔂��ݒ�l�𒴂��Ă��邱�Ƃ��Ӗ����܂��B���e�͈�
%   (OPTIONS.TolX)��傫�����邱�ƂŁA�������܂邩������܂���B
% 
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONNEG(...) �́A
% OUTPUT.iterations �œ�����X�e�b�v���AOUTPUT.algorithm �Ŏg��ꂽ
% �A���S���Y���̃^�C�v�A����сAOUTPUT.message �̏I�����b�Z�[�W���܂ށA
% OUTPUT �\���̂��o�͂��܂��B
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONNEG(...)
% �́A�o�΃x�N�g�� LAMBDA ���o�͂��܂��B�����ŁAX(i) ��(���悻) 0�̂Ƃ��A
% LAMBDA(i) <=0 �ŁAX(i) > 0 �̂Ƃ� LAMBDA(i) ��(���悻�j0�ł��B
% 
% �Q�l�FLSCOV, SLASH.

%   Copyright 1984-2004 The MathWorks, Inc. 

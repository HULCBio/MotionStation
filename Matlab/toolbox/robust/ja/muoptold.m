% MUOPT  ����/���f�������\�������ْl
%
% [MU,ASCALED,LOGD,X] = MUOPTOLD(A)�A�܂��́AMUOPTOLD(A,K) �́ASafonov �� 
% Lee(1993 IFAC World Congress)�̈�ʉ� Popov �搔�@���g���āA�v�Z���ꂽ��
% ���A�܂��́A���f���\�������ْl(SSV)�̃X�J����E MU ���v�Z���܂��B
% 
% ����:
%     A  -- �\�������ْl���v�Z����� p �s q �񕡑f�s��
% 
% �I�v�V�������́F
%     K  -- n �s 1��A�܂��́An �s 2��̍s��ŁA���̍s�́Assv �����肷��s
%           �m�����̃u���b�N�T�C�Y�ɂȂ�܂��BK �́Asum(K) == [q,p]�𖞑�
%           ����K�v������܂��B�����̕s�m�����́AK �̑Ή�����s�� -1 ����
%           �Z���邱�Ƃɂ��A������܂��B2�Ԗڂ̕s�m�����́A�����ŁAK(2,:) 
%           = [-1,-1] �Őݒ肵�܂��BK �̍ŏ��̗�݂̂��ݒ肳��Ă���ꍇ�A
%           �s�m�����̃u���b�N�́A�����`�A���Ȃ킿�AK(:,2) = K(:,1) �ƍl��
%           �܂��B
% �o�́F
%     MU      -- A �̍\�������ْl�̏�E
%     ASCALED -- mu*(I-X)/(I+X) �A�����ŁAX = D(mu*I-A)/(mu*I_A)*inv(D') 
%                �ł��B
%        LOGD -- �œK��ʉ� Popov �搔 M = D'*D �̑Ίp�v�f�̕������̑ΐ���
%                �v�f�Ƃ��� n �x�N�g��
%           x -- X+X'> = 0�̍ŏ��̌ŗL�l�Ɋ֘A���鐳�K�����ꂽ�ŗL�x�N�g���B

% Copyright 1988-2002 The MathWorks, Inc. 

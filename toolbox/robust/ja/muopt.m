% MUOPT   ����/���f�������\�������ْl
%
% [r,As,logd,x] = muopt(A)�܂���muopt(A,K)�́AFan �� Nekooie�̓��_�@�ɂ��
% �Čv�Z���������܂��͕��f���̍\�������ْl(ssv)�ɂ�����X�J����Er���v�Z
% ���܂��B
% 
% ����:
%     A  -- �\�������ْl���v�Z�����n�sn�񕡑f�s��
% 
% �I�v�V��������:
%     K  -- n�s1��x�N�g���ŁA���̍s��ssv���]�������s�m�����u���b�N�T�C
%           �Y�ł��BK�́Asum(K)=n�𖞑����Ȃ���΂Ȃ�܂���B�����̕s�m��
%           ��(�X�J���łȂ���΂Ȃ�܂���)�́AK�̑Ή�����s��-1����Z����
%           ���Ƃɂ�莦����܂��B���Ƃ��΁A2�Ԗڂ̕s�m�����u���b�N������
%           �Ƃ���ƁAK(2)=-1�Ɛݒ肵�܂��B
%
%  �o��:
%     r    -- A�̍\�������ْl�̏�E�B
%     As   -- r*(I-Ms)/(I+Ms)�B�����ŁAMs = Dt*(r*I-A)/(r*I)+A)/Dt'
%             Dt = Mult^0.5 �ŁAMult = D^2 + sqrt(-1)*G/r�́A�œK�Ȉ�ʉ�
%             Popov�搔�ł�(�s��D��G�̒�`�ɂ��ẮAmusol4.m���Q�Ƃ��Ă�
%             ������)�B
%     logd -- 0.5*log(diag(Mult))
%     x    -- X+X'>=0�̍ŏ��̌ŗL�l�Ɋ֘A���鐳�K�����ꂽ�ŗL�x�N�g���B
%             �����ŁAX=Mult*(r*I-A)/(r*I+A)�ł��B



% Copyright 1988-2002 The MathWorks, Inc. 

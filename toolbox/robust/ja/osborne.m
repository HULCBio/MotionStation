% OSBORNE   Osborne�@���g���āA�Ίp���X�P�[�����O
%
% [MU,ASCALED,LOGD] = OSBORNE(A)
% [MU,ASCALED,LOGD] = OSBORNE(A,K) 
% ���̊֐��́A���̎��ɂ���Čv�Z�����\�������ْl(ssv)�̃X�J����EMU��
% �o�͂��܂��B
% 
%           mu = max(svd(diag(dosb)*A/diag(dosb)))
% 
% �����ŁAdosb�́AOsborne�X�P�[�����O�@��K�p���ē����܂��B
%
% ����:
%     A  -- ssv���v�Z�����p�sq�񕡑f�s��B
% 
% �I�v�V��������:
%     K  -- n�s1��A�܂��́An�s2��s��ŁA���̍s��ssv���]�������s�m����
%           �u���b�N�̃T�C�Y�ł��BK�́Asum(K) == [q,p]�𖞑����Ȃ���΂Ȃ�
%           �܂���B
%           K��1�Ԗڂ̗�݂̂��^����ꂽ�ꍇ�́A�s�m�����u���b�N�́A
%           K(:,2)=K(:,1)�̂悤�ɐ����ɂȂ�܂��B
% �o��:
%     MU      -- A�̍\�������ْl�̏�E�B
%     ASCALED -- diag(dosb)*A/diag(dosb)
%     LOGD    -- dosb=exp(LOGD))�́AOsborne�X�P�[�����O�x�N�g���ł��B
%



% Copyright 1988-2002 The MathWorks, Inc. 

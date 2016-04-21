% PSV   Perron�ŗL�l�@�ɂ��Ίp�̃X�P�[�����O
%
% [MU,ASCALED,LOGD] = PSV(A)
% [MU,ASCALED,LOGD] = PSV(A,K) 
% ���̊֐��́A���̎��ɂ���Čv�Z�����\�������ْl(ssv)�̃X�J����EMU��
% �v�Z���܂��B
%           mu = max(svd(diag(dperron)*A/diag(dperron)))
% �����ŁAdperron�́ASafonov��Perron�ŗL�x�N�g���X�P�[�����O�@
% (IEE Proc., Pt. D, Nov. '82)���s��A�ɓK�p���ē����܂��B
%
% ����:
%     A  -- ssv���v�Z�����p�sq�񕡑f�s��B
% 
% �I�v�V��������:
%     K  -- n�s1��܂���n�s2��s��ŁA���̍s��ssv���]�������s�m����
%           �u���b�N�T�C�Y�ł��BK�́Asum(K) == [q,p]�𖞑����Ȃ����
%           �Ȃ�܂���BK��1�Ԗڂ̗�݂̂��^����ꂽ�ꍇ�́A�s�m����
%           �u���b�N�́AK(:,2)=K(:,1)�̂悤�ɐ����ɂȂ�܂��B
% 
% �o��:
%     MU      -- A�̍\�������ْl�̏�E�B
%     ASCALED -- diag(dperron)*A/diag(dperron)
%     LOGD    -- dperron=exp(LOGD))�́Aperron�X�P�[�����O�x�N�g���ł��B
%



% Copyright 1988-2002 The MathWorks, Inc. 

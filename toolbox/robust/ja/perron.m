% PERRON   Perron�ŗL�l
%
% [MU] = PERRON(A)�A�܂��́A[MU] = PERRON(A,K)�́ASafonov��Perron�ŗL�l�@
% (IEE Proc., Pt. D, Nov. '82)�ɂ���Čv�Z�����\�������ْl(ssv)��
% �X�J����EMU���v�Z���܂��B
%
% ����:
%     A  -- ssv���v�Z�����p�sq��̕��f�s��B
% �I�v�V�����̓���:
%     K  -- �s�m�����̃u���b�N�T�C�Y�B�f�t�H���g�́AK=ones(q,2)�ł��B
%           K�́An�s1��܂���n�s2��s��ŁA���̍s��ssv���]�������
%           �s�m�����u���b�N�T�C�Y�ł��BK�́Asum(K) == [q,p]��
%           �������Ȃ���΂Ȃ�܂���BK��1�Ԗڂ̗�݂̂��^����ꂽ�ꍇ�́A
%           �s�m�����u���b�N�́AK(:,2)=K(:,1)�̂悤�ɐ����ɂȂ�܂��B
% �o��:
%     MU -- A�̍\�������ْl�̏�E�B



% Copyright 1988-2002 The MathWorks, Inc. 

% AUGD 2�|�[�g��ԋ�ԃv�����g�̑Ίp�X�P�[�����O�s�� D(s) �ɂ��g��
%
% [TSS_D] = AUGD(TSS_,SS_D)�A�܂��́A
% [AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22] = AUGD(A,B1,B2,C1,C2,..
% D11,D12,D21,D22,AD,BD,CCD,DD) �́A2�|�[�g�g��v�����g�𐶐����܂��B
% TSS_D �́A�Ίp�s��D(s)��inv(D(s))�ɂ��A���̂悤�Ɋg�傳��܂��B
%                             -1
%     (TSS_D) := D(s) P(s) D(s)
%              = MKSYS(AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22,'tss');
%
%
%  ���̓f�[�^ : P = TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%               D = SS_D = MKSYS(AD,BD,CCD,DD);

% Copyright 1988-2002 The MathWorks, Inc. 

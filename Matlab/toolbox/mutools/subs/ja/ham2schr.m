% function [T, invT, S, s]=ham2schr(a,b1,c1,epr);
%
% HAM2SCHR�́A���̂悤��Hamilton�s��
%
%   H= [-a'     -c1*c1]
%      [b1*b1    a    ]
%
% ���A�u���b�N�Ίp��S = invT*H*T�ł���悤�ɁA�������ʁAjw-���A�E������
% ��3�̃X�y�N�g��������Ԃɕ������܂��B
%
% �Q�l: SDEQUIV, SDHFNORM, SDHFSYN

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:47 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 

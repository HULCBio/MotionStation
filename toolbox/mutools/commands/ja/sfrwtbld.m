% function syshat = sfrwtbld(sys,wt1,wt2)
%
% (WT1~)*SYS*(WT2~)�̈��蕔���v�Z���܂��B���[�`���́A���̂悤��SYSHAT
% �𓾂邽�߂�SFRWTBAL�Ƌ��Ɏg���܂��B
%
%  >>[sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%  >>sys1hat = strunc(sys1,k)
% �܂���
%  >>sys1hat = hankmr(sys1,sig1,k)
%  >>syshat = sfrwtbld(sys1hat,wt1,wt2);
%
% ���ʂ̌덷�́A���g�������̌v�Z�𒼐ڎg���ĕ]������܂��B
%
% �Q�l: HANKMR, SDECOMP, SFRWTBAL, SNCFBAL, SRELBAL, SYSBAL, 
%       SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

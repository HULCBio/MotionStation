% function [X,resid] = clyap(A,C))
%
% Lyapunov������A'*X + X*A + C'C = 0�������܂��BCLYAP�́A�R���X�L���q��
% �g���āALyapunov���������������߂ɁA�T�u���[�`��SJH6���Ăяo���܂��B
% RESID�́A�c���̌덷�̃m�����ł��B%	norm(A'*X + X*A + C'C)
%
% �Q�l: RIC_EIG, RIC_SCHR, SJH6, SYLV.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

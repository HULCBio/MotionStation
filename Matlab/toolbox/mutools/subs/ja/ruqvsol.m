% function [q,gammaopt] = ruqvsol(r,u,v)
%
% ����́ADavis-Kahan-Weinberger���̒萔�s��������܂�(SIAM Journal, 
% 1981)�B
%
% gammaopt := min norm(r + u*q*v)
%              q
%
% ����́A������`�V�X�e�����_�̒��ōł��d�v�Ȑ��`�㐔����1�ł��B19
% 82�N����1987�N�܂ł�H���̌�����operator-theoretic�o�[�W������1990�N��
% �猻�݂܂ł�AMI�x�[�X�̃V���Z�V�X��@�Ɏ�����Ă��܂��B

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:35 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 

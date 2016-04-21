% FREQSPACE   ���g�������̂��߂̓��Ԋu�̎��g��
% 
% FREQSPACE�́A���Ԋu�̎��g�����������߂邽�߂̎��g���͈̔͂��o�͂��܂��B
% FREQSPACE�́A��X��1�����A�v���P�[�V�����Ɠ��l�AFSAMP2�AFWIND1�AFWIND2
% �ɑ΂�����g���������쐬����̂ɖ𗧂��܂��B
% 
% [F1,F2] = FREQSPACE(N)�́AN�sN��̍s��ɑ΂���2�������g���x�N�g��F1��
% F2���o�͂��܂��B
% [F1,F2] = FREQSPACE([M N])�́AM�sN��̍s��ɑ΂���2�������g���x�N�g��
% ���o�͂��܂��B
%
% 2�����x�N�g����n����̏ꍇ�AF = (-1+1/n:2/n:1-1/n)�ł��B
% 2�����x�N�g����n�������̏ꍇ�AF = (-1    :2/n:1-2/n)�ł��B
%
% [F1,F2] = FREQSPACE(...,'meshgrid')�́A[F1,F2] = freqspace(...); 
% [F1,F2] = meshgrid(F1,F2)�Ɠ����ł��B
%
% F = FREQSPACE(N)�́A�P�ʉ~����̓��Ԋu��N�̓_�����肵�āA1�������g��
% �x�N�g��F���o�͂��܂��B1�����x�N�g���ɑ΂��āAF = (0:2/N:1)�ł��BF = 
% FREQSPACE(N,...'whole')�́A���Ԋu��N�̓_���o�͂��܂��B���̏ꍇ�AF = 
% (0:2/N:2*(N-1)/N)�ł��B
%
% �Q�l�FFSAMP2, FWIND1, FWIND2 (Image Processing Toolbox).


%   Clay M. Thompson 1-11-93
%   Copyright 1984-2003 The MathWorks, Inc. 

% function y = vinterp(u,stepsize,finaliv,order)
% �܂���
% function y = vinterp(u,varymat,order)
%
% �o�̓x�N�g��Y(VARYING)�́A����U����}�������̂ł��B
%
% 2�Ԗڂ̈��������̃X�J���̏ꍇ�A���̂悤�ɂȂ�܂��BY�̓Ɨ��ϐ���MIN
% (GETIV(U))����n�܂�AFINALIV(�܂��́A������2�݂̂̏ꍇ�AMAX(GETIV
% (U)))�ŏI�����܂��B������STEPSIZE�ł��B�]���āA����ɂ��o��IV�����
% �u�ɂȂ�܂��B2�Ԗڂ̈�����VARYING�s��̏ꍇ�A���̂悤�ɂȂ�܂��BY
% �̓Ɨ��ϐ��́AGETIV(VARYMAT)�Ɠ������Ȃ�܂��B���̏ꍇ�A3�Ԗڂ̈�����
% ���}�̎����ł��B
%
% order�́A���̓�����I������܂��B
%     0	�[�����z�[���h(������3�̏ꍇ�A�f�t�H���g)
%     1	���`���
%
% �Q�l: DTRSP, TRSP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

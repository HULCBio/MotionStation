% FNMIN   (�^����ꂽ��Ԃł�)�֐��̍ŏ��l
%
% FNMIN(F) �́A��{��ԏ�ŁAF �̃X�J���l��ϐ��X�v���C���̍ŏ��l��
% �o�͂��܂��B 
%
% FNMIN(F,INTERV) �́AINTERV �ɂ��([a,b] �Ƃ���)�w�肳����Ԃ̍ŏ��l
% ���o�͂��܂��B 
%
% [MINVAL, MINSITE] = FNMIN(F ...) �́AF �ɂ���֐����ŏ��l MINVAL �����
% �T�C�g MINSITE ���^���܂��B
%
% ���:
% spmak(1:5,-1) �́A �ߓ_�� (1,2,3,4,5) �����A�L���[�r�b�NB-�X�v���C��
% �̕��̒l��^���邽�߁A�ȉ��̂悤�ɁA
%
%      [y,x] = fnmin(spmak(1:5,-1))
%   
% ���A-2/3�ɓ����� y �ƁA3�ɓ����� x ��Ԃ����Ƃ�v�����܂��B����ɁA
% 
%      f = spmak(1:21,rand(1,15)-.5);
%      maxval = -fnmin(fncmb(f,-1))
%
% �ɂ��A��{��Ԃł� f �̃X�v���C���̍ő�l��^���܂��B
%      
%      fnplt(f), hold on, plot(fnbrk(f,'in'),[maxval maxval]), hold off
%
% �Q�l : FNZEROS, FNVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 

% RREF   �s�̊K�i�^�ւ̕ϊ�
% 
% R = RREF(A) �́AA �̍s�̊K�i�^���o�͂��܂��B
%
% [R,jb] = RREF(A) �́A���̂悤�ȃx�N�g�� jb ���o�͂��܂��B
% r = length(jb) �́AA �̃����N�Ɋւ���A���S���Y���̃A�C�f�A�ɂȂ��Ă��܂��B
% x(jb) �́A���`�V�X�e�� Ax = b �̋��E�ϐ��ł��BA(:,jb) �́AA �͈̔͂ɑ΂���
% ���ł��BR(1:r,jb) �́Ar �s r ��̒P�ʍs��ł��B
%
% [R,jb] = RREF(A,TOL) �́A�����N�̔���ŁA�^����ꂽ���e�덷���g���܂��B
% 
% �ۂߌ덷�ɂ��A���̃A���S���Y���́ARANK�AORTH�ANULL ���狁�܂郉���N��
% �قȂ�l���v�Z���邱�Ƃ�����܂��B
%
% �Q�l�FRREFMOVIE, RANK, ORTH, NULL, QR, SVD.

%   CBM, 11/24/85, 1/29/90, 7/12/92.
%   Copyright 1984-2004 The MathWorks, Inc. 


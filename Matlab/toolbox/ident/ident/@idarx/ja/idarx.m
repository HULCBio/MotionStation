% IDARX �́AIDARX ���f���\�����쐬���܂��B
%       
%   M = IDARX(A,B,Ts)
%   M = IDARX(A,B,Ts,'Property',Value,..)
%
% ny�o�́Anu���͂������ϐ� ARX ���f���́A���̂悤�ɕ\���܂��B
%
%   A0*y(t)+A1*y(t-T)+ ... + An*y(t-nT) =
%	      '                 B0*u(t)+B1*u(t-T)+Bm*u(t-mT) + e(t) 
%	      
% A �́Any-ny-n �̃T�C�Y�̔z��ŁAA(:,:,k+1) = Ak ��\���܂��BA0 = eye(ny)
% �ɂȂ�悤�Ȑ��K�����K�v�ł��BB �́A���l�� ny-nu-m �̃T�C�Y�̔z��ł��B
%   
% Ts �́A�T���v�����O�Ԋu�ł��B
%
% IDARX �v���p�e�B�̏ڍ׏��́ASET(IDARX)�A�܂��́AIDPROPS IDARX �Ɠ���
% ���ē����܂��B
%



%   Copyright 1986-2001 The MathWorks, Inc.

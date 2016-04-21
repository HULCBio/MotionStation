% MEMBRANE   MATLAB�̃��S�̏o��
%
% L = MEMBRANE(k)�́Ak < =  12�̂Ƃ��AL�^�̖���k���̌ŗL�֐��ł��B�ŏ���
% 3�̌ŗL�֐��́AMathWorks�̎�X�̏o�ŕ��̕\���ɂȂ��Ă��܂��B
%
% MEMBRANE(k)�́A�o�̓p�����[�^�Ȃ��ł́Ak���̌ŗL�֐����v���b�g���܂��B
% 
% MEMBRANE�́A���͂���яo�̓p�����[�^�Ȃ��ł́AMEMBRANE(1)���v���b�g��
% �܂��B
%
% L = MEMBRANE(k,m,n,np)�́A���b�V���Ɛ��x�̃p�����[�^���ݒ肵�܂��B
%
%   k�́A�ŗL�֐��̃C���f�b�N�X�ŁA�f�t�H���g��1�ł��B
%   m�́A���E��1/3�ɂ���_�̐��ł��B�o�͂̃T�C�Y�́A2*m+1�s2*m+1��ł��B
%         �f�t�H���g�́Am = 15�ł��B
%   n�́A�a���v�Z���鍀���ł��B�f�t�H���g�́An = min(m,9)�ł��B
%   np�́A�����a���v�Z���鍀���ł��B�f�t�H���g�́Anp = min(n,2)�ł��B
%   np = n�̂Ƃ��A�ŗL�֐��͋��E�Ń[���ɋߕt���܂��B
%   np = 2�̂悤�ɁAnp < n�̂Ƃ��́A���E�͂���܂���B
%



%   Out-of-date reference:
%       Fox, Henrici & Moler, SIAM J. Numer. Anal. 4, 1967, pp. 89-102.
%   Cleve Moler 4-21-85, 7-21-87, 6-30-91, 6-17-92;
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:49:03 $
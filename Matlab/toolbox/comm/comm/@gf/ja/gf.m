% GF   �K���A�̔z��̍쐬
%
% X_GF = GF(X,M) �́A1<=M<=16 �ɑ΂��āA�� GF(2^M) �� X ����K���A��
% �z����쐬���܂��BX �̗v�f�́A0��2^M-1�̊Ԃ̐����łȂ���΂Ȃ�܂���B
% X_GF �́AMATLAB�z��̂悤�ɐU�����A�W���̃C���f�b�N�X�t���ƎZ�p���Z
% (+, *, .*, .^, \, etc.)�Ƃ��Ďg�p���邱�Ƃ��ł��܂��B
% X_GF �����s���邽�߂̉��Z�̊��S�ȃ��X�g�ɂ��ẮA"GFHELP" ���^�C�v
% ���Ă��������B
%
% X_GF = GF(X,M,PRIM_POLY) �́A���n������ PRIM_POLY ��p���đ̂��`����
% ���߂ɁAX ����K���A�̔z����쐬���܂��BPRIM_POLY �́A10�i�\�L�@��
% ���n�������łȂ���΂Ȃ�܂���B���Ƃ��΁A1 1 0 1 �́A13�̃o�C�i��
% �`���ł��邽�߁A������ D^3+D^2+1 �́A��13�Ƃ��Ď�����܂��B
%
% X_GF = GF(X) �́AM = 1 �̃f�t�H���g�l���g�p���܂��B
%
% ���:
%     A = gf(randint(4,4,8,873),3);  % GF(2^3)��4x4�̍s��
%     B = gf(1:4,3)';                % 4x1�̃x�N�g��
%     C = A*B   
%
%     C = GF(2^3) array. Primitive polynomial = 1+D+D^3 (11 decimal)
% 
%      Array elements = 
% 
%        3
%        3
%        6
%        7
%
% �Q�l : GFHELP, GFTABLE.


%    Copyright 1996-2002 The MathWorks, Inc.

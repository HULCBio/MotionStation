% IDSS �́AIDSS ���f���N���X���쐬���܂��B
%       
%   M = IDSS(A,B,C,D)
%   M = IDSS(A,B,C,D,K,X0,Ts)
%   M = IDSS(A,B,C,D,K,X0,Ts,'Property',Value,..)
%   M = IDSS(MOD)  
% 
% �����ŁAMOD �́A�C�ӂ� SS, TF, ZPK ���f���A�܂��́A�C�ӂ� IDMODEL �I�u
% �W�F�N�g�ł��B
%
%   M : �o�͂���闣�U���ԃ��f�����L�q���郂�f���\���̃I�u�W�F�N�g
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
% A,B,C,D,K �́A��ԋ�ԍs��ŁAX0 �͏��������A�K�v�Ȃ� Ts �̓T���v����
% �Ԃł��BTs == 0 �̏ꍇ�A�A�����ԃ��f�����쐬����܂��B
%
% K, X0, Ts ���ȗ�����ƁA�f�t�H���g�l K = zeros(nx,ny), X0 = zeros(nx,1), 
% Ts = 1 ���g���܂��B�����ŁAnx �� ny �́A��Ԑ��Əo�͐��ł��B���Ȃ킿�A
% size(C) = [nx ny] �ł��B
%
% M = IDSS(MOD) �́AMOD �̒��̃��f�������o�͂��܂��B
% MOD ���A��`����� InputGroup 'Noise' �������Ȃ� LTI �I�u�W�F�N�g�̏�
% ���A�m�C�Y�����̂Ȃ�(K = 0) IDSS���f���������܂��B�f�t�H���g�ł́A
% �P�ʕ��U�m�C�Y�����o�͂ɕt������܂��B�m�C�Y��t�����Ȃ����߂ɂ́A����
% �����ɁA
%      ... , 'NoiseVariance' , zeros(ny,ny) , ...
% ��ǉ����܂��BMOD ���AInputGroup 'Noise' �������Ă���ꍇ�A�����̓���
% �́A�P�ʕ��U�����Ɨ��Ȕ��F�m�C�Y���Ɖ��߂���܂��B����ŁAK ��
% NoiseVariance �́A���̃��f���ɑ΂���J���}���t�B���^����v�Z����܂��B
%
% M = IDSS �́A��I�u�W�F�N�g���쐬���܂��B
%
% ��ԋ�ԃu���b�N�{�b�N�X���f���̈������́AIDHELP SSBB ���Q�Ƃ��Ă�����
% ���B�����āA�����\��������ԋ�ԃ��f���̈������́AIDHELP SSSTRUC ��
% �Q�Ƃ��Ă��������B
% 
% IDSS �v���p�e�B�̏ڍׂɂ��ẮAIDPROPS IDSS�A�܂��́ASET(IDSS) �ƃ^
% �C�v�C�����Ă��������B
%
% �Q�l:  SETSTRUC



%   Copyright 1986-2001 The MathWorks, Inc.

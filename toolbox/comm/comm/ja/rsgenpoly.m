% RSGENPOLY   ���[�h�\�������R�[�h�̐���������
%
% GENPOLY = RSGENPOLY(N,K) �́A����N �̃R�[�h���[�h�ƒ���K �̃��b�Z�[�W
% �������[�h�\�������R�[�h�̃f�t�H���g�̐������������o�͂��܂��B
% �R�[�h���[�h�̒���N�́A3��16�̊Ԃ̂��鐮��m�ɑ΂��āA�`��2^m-1������
% �K�v������܂��B �o��GENPOLY �́A�������������~�ׂ��̏��ɕ��ׂ�
% �K���A�̏�̌W���x�N�g���ł��B�f�t�H���g�̐����������́A
% (X-alpha)*(X-alpha^2)*...*(X-alpha^(N-K)) �ł��B�����ŁA
% alpha �́A�t�B�[���hGF(N+1)�ɑ΂���f�t�H���g�̌��n�������̍��ł��B
%   
% GENPOLY = RSGENPOLY(N,K,PRIM_POLY) �́APRIM_POLY �ɁAGF(N+1)���
% alpha�̍�������GF(N+1)�������n���������w�肷�邱�Ƃ������āA
% ��̃V���^�b�N�X�Ɠ����ł��B
% PRIM_POLY �́A���n�������̌W�����A �~�ׂ��̏��Ƀo�C�i���ŕ\������
% �����ł��B�f�t�H���g�̌��n���������g�p���邽�߂ɁAPRIM_POLY�� [] ��
% �ݒ肵�܂��B
%   
% GENPOLY = RSGENPOLY(N,K,PRIM_POLY,B) �́A���������� 
% (X-alpha^B)*(X-alpha^(B+1))*...*(X-alpha^(B+N-K-1)) ���o�͂��܂��B
% �����ŁAB �͐����ł���Aalpha ��PRIM_POLY �̍��ł��B
%   
% [GENPOLY,T] = RSGENPOLY(...) �́A�R�[�h�̃G���[�C���\�� T
% ���o�͂��܂��B
%
% ���:
%      g  = rsgenpoly(7,3)       %  �f�t�H���g�̐���������
%      g2 = rsgenpoly(7,3,13)    %  ���n�������AD^3+D^2+1�Ɋւ���
%                                %  �f�t�H���g�̐���������
%                                %   
%      g3 = rsgenpoly(7,3,[],4)  %  b=4���g�p
%   
% �Q�l GF, RSENC, RSDEC.


%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2.4.1 $  $Date: 2003/06/23 04:35:16 $ 

% MKSYS   �V�X�e���s���ϐ�"TREE"�ɂ܂Ƃ߂܂�
%
% S=MKSYS(A,B,C,D)�܂���S=MKSYS(V1,V2,...,VN, TY)�́A�V�X�e�����L�q����s
% ����A���̂悤�ȕ�����TY�Ŏw�肳���ϐ��������c���[�x�N�g��S�ɂ܂�
% �߂܂��B
% -----   -------------------------------  ---------------------------
% TY      V1,V2,...,VN                     �ڍ�
% -----   -------------------------------  ---------------------------
% 'ss'    'a,b,c,d,ty'                        �W���̏�ԋ�Ԍ^(�f�t�H���g)
% 'des'   'a,b,c,d,e,ty'                      �f�B�X�N���v�^�V�X�e��
% 'tss'   'a,b1,b2,c1,c2,d11,d12,d21,d22,ty'  2�|�[�g�̏�ԋ�Ԍ^
% 'tdes'  'a,b1,b2,c1,c2,d11,d12,d21,d22,e,ty'2�|�[�g�̃f�B�X�N���v�^
% 'gss'   'sm,dimx,dimu,dimy,ty'              ��ʓI�ȏ�ԋ�Ԍ^
% 'gdes'  'e,sm,dimx,dimu,dimy,ty'            ��ʓI�ȃf�B�X�N���v�^
% 'gpsm'  'psm,deg,dimx,dimu,dimy,ty'         ��ʓI�ȑ������V�X�e���s��
% 'tf'    'num,den,ty'                        �`�B�֐�
% 'tfm'   'num,den,m,n,ty'                    �`�B�֐��s��
% 'imp'   'y,ts,nu,ny'                        �C���p���X����
% ----------------------------------------------------------------------
%
% �I�v�V�������� Ts (�T���v�����O����)�A�[���łȂ��ꍇ�A�V�X�e���͗��U�n��
% �l���܂��B�܂��ATs = -1 �̏ꍇ�́A�T���v�����O���Ԃ���`����Ă��Ȃ�����
% �������܂��B
% �֐�BRANCH�́A�V�X�e��S�Ƀp�b�N���ꂽ�s��𕪉����܂��B���Ƃ��΁A�R�}��
% �h [C,A]=BRANCH(S,'c','a')�́A�W���̏�ԋ�ԃV�X�e���̍s��'c'��'a'���o��
% ���܂��B
% �܂��A�R�}���h [AG,BG,CG,DG,TY]=BRANCH(S)�́A�p�b�N���ꂽ�Ƃ��̏����ŁA
% �S�Ă̍s����o�͂��܂��B
%
% �Q�l   TREE, BRANCH, GRAFT.



% Copyright 1988-2002 The MathWorks, Inc. 

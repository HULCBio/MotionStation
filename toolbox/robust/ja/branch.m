% BRANCH "TREE"�ϐ��̃u�����`(�I�v�V�����̃V�X�e���s��̃f�[�^�\��)
%
% [B1,B2,...,BN] = BRANCH(SYS) �܂��́A
% [B1,B2,...,BN] = BRANCH(SYS,V1,...VN) �́ALTI�V�X�e������N�̃V�X�e��
% �f�[�^�s��[B1,...,BN]���o�͂��܂��B
% �I�v�V�����̓���V1,...,VN�́A���o�����ϐ��̖��O�̕����ł��B
% SYS�ɑ΂���K�؂Ȗ��OV1,...,VN�̃��X�g�́ABRANCH(SYS,0)�ŏo�͂���܂��B
%
% [B1,B2,...,BN] = BRANCH(TR,PATH1,PATH2,...,PATHN) �́A�c���[TR��N��
% �T�u�u�����`���o�͂��܂��BNARGIN==1�̏ꍇ�A���[�g�u�����`�́A�����C��
% �f�b�N�X�ɏ]���ĘA���I�ɏo�͂���܂��B����ȊO�ł́A�o�͂����u�����`
% ���p�XPATH1,PATH2,...,PATHN�ɂ���Đݒ肳��܂��B�e�X�̃p�X�́A�ʏ�A
% ���̌`���̕�����ł��B
%           PATH = '/name1/name2/.../namen'
% �����ŁAname1,name2���́A���[�g�c���[����Ώۂ̃T�u�u�����`�܂ł̃p�X
% ���`����u�����`���̕�����ł��B����APATH���`���Ă���u�����`�̐�
% ���C���f�b�N�X���܂ލs�x�N�g�����g�����Ƃ��ł��܂��B���Ƃ��΁A
% S=TREE('a,b,c','foo',[49  50],'bar')�̏ꍇ�ABRANCH(S,'c')��BRANCH(S,3)
% �́A���ɒl'bar'���o�͂��܂��B
%
% �Q�l�FISTREE, TREE, MKSYS, BRANCH.



% Copyright 1988-2002 The MathWorks, Inc. 

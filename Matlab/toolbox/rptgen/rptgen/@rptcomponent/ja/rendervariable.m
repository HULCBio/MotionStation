% RENDERVARIABLE   MATLAB�ϐ���XML�\�[�X�ɕϊ�
% 
%   S=RENDERVARIABLE(R,V,I,L,T,E)
% 
% S�́AXML�o�͂ł��B
% R�́ARPTCOMPONENT�I�u�W�F�N�g�ł��B
% V�́AMATLAB�ϐ��܂��̓��[�N�X�y�[�X�ϐ����ł�("E"���Q��)�B
% I�́A�l��1�ł���ꍇ�́A�o�͂������I�ɃC�����C��������ɂ��܂��B
%      �l��0�ł���ꍇ�́A�o�͂̓e�[�u���ł��B
%      I�̓I�v�V�����ŁA�f�t�H���g=logical(1)�ł��B
% L�́A[MxN CLASSNAME]�Ƃ��ċL�q�����O�ɔz�񂪂����Ă��Ȃ���΂Ȃ�Ȃ�
%      �ő�̗v�f���ɑ΂���搔���`������q�ł��B�e�f�[�^�^�C�v�ɂ́A
%      �L�q���_�E���O���[�h�����O�ɋ��e�����v�f��������܂��BL���[��
%      �ł���ꍇ�A�o�͔͂z��̃T�C�Y�Ɋւ�炸�_�E���O���[�h����܂���B
%      L�̓I�v�V�����ŁA�f�t�H���g=1�ł��B
% T�́A�ϐ��̃^�C�g���ł��B�e�[�u�����쐬�����ꍇ�AT�̓e�[�u���̃^�C�g
%      ���ł��BT�̓I�v�V�����ŁA�f�t�H���g=''�ł��B
% E�́Aboolean�l�ŁA�^�ł���ꍇ�͋L�q���ꂽ�ϐ������[�N�X�y�[�X���璊�o
%      ����邱�Ƃ������܂��BE���^�ł���ꍇ�́AV�͒��o�����ϐ����̕�
%      ����ł��BE�̓I�v�V�����ŁA�f�t�H���g=logical(0)�ł��B
%  
% �e�f�[�^�^�C�v�́A�ϐ���[MxN CLASSNAME]�Ƃ��ċ����I�ɋL�q�����O�ɂ�
% ���Ƃ��\�ȍŏ��̗v�f��������܂��B
%
%   String = 2080  (26*80)
%   Double & Sparse = 1024 (32*32)
%   Cell Arrays = 256 (16*16)
%   Structures = 32   
% 





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:21:03 $
%   Copyright 1997-2002 The MathWorks, Inc.

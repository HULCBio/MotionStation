% IVX �́AARX ���f���̕⏕�ϐ�������v�Z���܂��B
%
%   MODEL = IVX(Z,NN,X)
%
%   MODEL : ���̂悤�ɕ\����� ARX ���f��
% 
%               A(q) y(t) = B(q) u(t-nk) + v(t)
%         
%           �ɑ΂��āA�֘A�����\�����Ƌ��ɁAIV ������o�͂��܂��BMODEL
%           �̐��m�ȍ\���ɂ��ẮAHELP IDPOLY ���Q�Ƃ��Ă��������B
%
%   Z     : IDDATA �I�u�W�F�N�g�Ƃ��ĕ\�����o�� - ���̓f�[�^�BHELP IDD-
%           ATA ���Q�ƁB
%
%   NN    : NN=[na nb nk] �́A��̃��f���Ɋ֘A���������ƒx��ł��B
%   X     : �⏕�ϐ��̃x�N�g���ŁAy �x�N�g��(���Ȃ킿�AZ.y)�Ɠ����T�C�Y
%           �̂��̂ł��B�܂��AZ �������̎������ʂ��܂�ł���ꍇ�AX �͎�
%           ���Ɠ����M�������Z���z��ɂȂ�܂��B
%
% �⏕�ϐ��̏��ŁA�����I�ȑI���ɂ��ẮAIV4 ���Q�Ƃ��Ă��������B
% ���o�̓o�[�W�����́AIDARX/IVX �ł��B
%
% TH = ivx(Z,NN,X,maxsize) �́A�A���S���Y���ɂ��`�������maxsize �v�f
% ���傫���s����܂݂܂���B

%   Copyright 1986-2001 The MathWorks, Inc.

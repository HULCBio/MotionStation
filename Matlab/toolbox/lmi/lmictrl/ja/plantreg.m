% [Preg,gbest,x1,x2,y1,y2]=plantreg(P,r,gama,x1,x2,y1,y2,sing12,sing21)
%
% �֐�HINFRIC�ŗ��p�B���[�U�͂��̊֐��𒼐ڗ��p���܂���B
%
% D12��D21�������N��������v�����gP(s)�̐��K�����s���܂��B
%
% eps���K�������l�I���萫�ƃR���g���[���p�����[�^�̑傫���Ƃ̊ԂōœK��
% ����܂��B
% GAMA�́A���l�I�M�����̂��߂ɕK�v�Ƃ����Ƃ��AGBEST�ɑ�������܂��B
%
% ����:
%   P             �p�b�N���ꂽ�`���ł̃v�����g�̏�ԋ�ԕ\��
%   R             D22�̃T�C�Y   (R = [ �o�͐� , ������͐� ])
%   GAMA          �v�������Hinf���\
%   X1,X2,Y1,Y2   �֐�GOPTRIC�̏o��
%   SING12        D12�������N��������Ƃ��ASING12 > 0
%   SING21        D21�������N��������Ƃ��ASING21 > 0
%
% �o��:
%   PREG          ���K�����ꂽ�v�����g (�p�b�N���ꂽ�`��)
%   GBEST         ���K�����[GAMA, +Inf]�Ԃł̒B���\�ȍœK���\
%   X1,X2,Y1,Y2   gamma = GBEST�ɑ΂���2��HinfRiccati�������̈��艻��
%�@�@�@�@�@�@�@�@ X = X2/X1��Y = Y2/Y1�B
%
% �Q�l�F    HINFRIC.

% Copyright 1995-2001 The MathWorks, Inc. 

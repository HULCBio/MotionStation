% FIXMULT LMI/�搔�ʉ��
%
% [mu,sysm,syss] = fixmult(sys1,k,n)�A�܂��́A
% [mu,am,bm,cm,dm,as,bs,cs,ds]=fixmult(a,b,c,d,k,n) �́A
% G(s) := [A,B,C,D] �̎�/���f�\�������ْl�Ɋւ���X�J���̏�EMU�ƁA�֘A
% ����Œ莟���œK�Ίp�搔(�X�P�[�����O�s��)M(s)���v�Z���܂��B�搔MU�̏�
% �E�́A���̎����������ƂŌv�Z����܂��B
%
%        min MU
%         Mi
%            s.t. hinfnorm(G(s)) <= 1 �����ŁA
%        G(s) := blt( M(s) * blt( G(s)/MU ))
%        M(s) := diag(M1(s)*I, ... , Mn(s)*I).
% blt(X) = (I-X)/(I+X) �� Mi(s) (for i=1,...,n) �́A�v���p�[���L���ł�
% ����΂����܂���B�܂��A���ꑽ����DEN(�f�t�H���g��1)��real(M(jw))>=0
% �łȂ���΂����܂���B
%
% ���̊֐��́AACC '94 �� Ly, Safonov �� Chiang ��LMI�`����p���ď搔���v�Z
% ���邱�Ƃɑ΂��ALMI Lab �𗘗p���܂��B
%
% ���� :
%  [A,B,C,D]�A�܂��́ASYS --- G(s)�̏�ԋ�ԕ\��
% �I�v�V�������� :
%  k --- k��n�s�ڂ́A���̂悤�ɕs�m�����̍\�����w�肵�܂��B
%        k(i,1) --- �����ɑ΂���-1�A���f���ɑ΂���1
%        k(i,2) --- i�Ԗڂ̕s�m�����̃T�C�Y (�����u���b�N)
%        k(i,3) --- �J��Ԃ��u���b�N
%  n --- i�Ԗڂ̏搔�̎����ŁA�����łȂ���΂����܂���B
%
% ���� : ���̍\���I�s�m���������p�ł��܂��B
%        ���X�J��, �J��Ԃ����X�J��
%        ���f�X�J��, �J��Ԃ����f�X�J��
%        ���f�t���u���b�N
%
% �o�� :
%  MU --- G(s)�̃X�J���\�������ْl
%  [AM,BM,CM,DM] �搔 M(s) := diag(M1(s)*I,...,Mn(s)*I) �̏�ԋ�ԕ\��
%  [AS,BS,CS,DS] �œK��"�X�P�[�����O���ꂽ�V�X�e��"�̏�ԋ�ԕ\��
%
% Author : J. H. Ly   5/95
% Updated by R. Y. Chiang 2/96

% Copyright 1988-2002 The MathWorks, Inc. 

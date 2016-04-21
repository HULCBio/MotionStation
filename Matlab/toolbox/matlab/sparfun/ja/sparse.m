% SPARSE   �X�p�[�X�s��̍쐬
% 
% S = sparse(X) �́A�[���v�f����菜���āA�X�p�[�X�s��܂��̓t���s����A
% �X�p�[�X�^�ɕϊ����܂��B
%
% S = SPARSE(i,j,s,m,n,nzmax) �́A[i,j,s] �̍s���g���Anzmax �̔�[��
% �v�f�ɑ΂��Ċ��蓖�Ă���X�y�[�X������ m �s n ��̃X�p�[�X�s����쐬
% ���܂��B2�̐����C���f�b�N�X�x�N�g�� i �� j �ƁA�����܂��͕��f����
% �v�f�x�N�g���́A���ׂē������� nnz �ŁA����͌��ʂ̃X�p�[�X�s�� S ��
% ��[�����ł��Bi �� j �Ɠ����l������ s �̗v�f���ǉ�����܂��B
%
% ����6�̈����R�[�����ȗ����邱�Ƃ��ł��邢�����̕��@������܂��B
%
% S = SPARSE(i,j,s,m,n) �́Anzmax = length(s) ���g���܂��B
%
% S = SPARSE(i,j,s) �́Am = max(i) �� n = max(j) ���g���܂��B
%
% S = SPARSE(m,n) �́ASPARSE([],[],[],m,n,0) �̏ȗ��`�ł��B����́Am �s n
% ��̂��ׂĂ̗v�f���[���̃X�p�[�X�s����쐬���܂��B
%
% ���� s �� i �܂��� j �̂����ꂩ�́A�X�J���ł��\���܂���B���̏ꍇ�A
% �ŏ���3�̈��������������ł���悤�Ɋg������܂��B
%
% ���Ƃ��΁A�X�p�[�X�s��𕪐͂��A�ēx�쐬���܂��B
%
%            [i,j,s] = find(S);
%            [m,n] = size(S);
%            S = SPARSE(i,j,s,m,n);
%
% ������s�����ƂŁA�Ō�̍s�Ɨ�͔�[���v�f�������܂��B
%
%            [i,j,s] = find(S);
%            S = SPARSE(i,j,s);
%
% ���ׂĂ�MATLAB�̑g�ݍ��݂̎Z�p�A�_���A�C���f�b�N�X���Z�́A�X�p�[�X�s��
% �܂��̓X�p�[�X�s��ƃt���s�񂪍��݂������̂ɓK�p�ł��܂��B�X�p�[�X�s��
% �ł̉��Z�̓X�p�[�X�s����o�͂��A�t���s��ł̉��Z�̓t���s����o�͂��܂��B
% �قƂ�ǂ̏ꍇ�A�X�p�[�X�s��ƃt���s�񂪍��݂������Z�ł́A�t���s���
% �o�͂��܂��B��O�I�ɁA���݂����s�񉉎Z�ł����ʂ��\���I�ɃX�p�[�X�ɂȂ�
% �ꍇ������܂��B���Ƃ��΁AA .* S �͏��Ȃ��Ƃ� S �Ɠ������炢�X�p�[�X
% �ł��BS > =  0�ł���悤�ȉ��Z�ł́A"Big Sparse"�܂���"BS"�s����쐬
% ���܂��B����́A�X�p�[�X�ȃX�g���[�W�\���ł����A�[���v�f���قƂ��
% �����܂���B
% 
% �Q�l�FSPALLOC, SPONES, SPEYE, SPCONVERT, FULL, FIND, SPARFUN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:54 $
%   Built-in function.


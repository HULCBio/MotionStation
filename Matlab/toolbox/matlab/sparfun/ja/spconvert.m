% SPCONVERT   �X�p�[�X�s��̊O����������s�����荞��
% 
% SPCONVERT �́AMATLAB�ȊO�̃X�p�[�X�v���O�����ō쐬���ꂽ�ȒP�ȃX�p�[�X
% �`������A�X�p�[�X�s����쐬���邽�߂Ɏg���܂��BSPCONVERT �ɂ́A
% 2�̃v���Z�X������܂��B
% 
%  1) [i,j,v] �܂��� [i,j,re,im] ���܂�ASCII�f�[�^�t�@�C�����A�s�Ƃ���
%     MATLAB�ϐ��Ƀ��[�h���܂��B
%  2) ���̕ϐ���MATLAB�X�p�[�X�s��ɕϊ����܂��B
%
% S = SPCONVERT(D) �́A�s-��-�l��3�v�f [i,j,v] ���܂ލs�� D ���A�s�Ƃ���
% �X�p�[�X�s�� S �ɕϊ����܂��B
% 
%    for k = 1:size(D,1),
%       S(D(k,1),D(k,2)) = D(k,3).
%    end
%
% D ��M�s4��̏ꍇ�́A3��ڂ�4��ڂ͕��f���̎����Ƌ����Ƃ��Ĉ����܂��B
% 
%    for k = 1:size(D,1),
%       S(D(k,1),D(k,2)) = D(k,3) + i*D(k,4).
%    end
%
% D �́Asize(S) �� m �s n ��ł��邱�Ƃ��w�肷�邽�߂ɁA[m n 0] �܂���
% [m n 0 0] �̌^�̍s���܂ނ��Ƃ��ł��܂��BD ���A���ɃX�p�[�X�Ȃ�Εϊ���
% �s���Ȃ��̂ŁASPCONVERT �� D ��MAT�t�@�C���܂���ASCII�t�@�C������
% ���[�h���ꂽ��Ŏg�p����܂��B
%
% ���: 
% mydata.dat �́A���̍s���܂ނƉ��肵�܂��B
% 
%         8  1  6.00
%         3  5  7.00
%         4  9  2.00
%         9  9  0
%
% �R�}���h
%
%     load mydata.dat
%     A = spconvert(mydata);
%
% �́A9�s9��̃X�p�[�X�s����쐬���܂��B
%
%     A = 
%        (8,1)        6
%        (3,5)        7
%        (4,9)        2
%
% �Q�l�FSPARSE, FULL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:57 $

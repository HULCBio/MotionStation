% FNCMB   �֐��̎Z�p
%
% FNCMB(function,operation) �́A�֐��ɑ����K�p���܂��B���ɁA
%   FNCMB(function,scalar)    �֐��ɃX�J���������܂��B
%   FNCMB(function,vector)    �x�N�g���ɂ���āA�֐��̒l�𕽍s�ړ����܂��B
%       (�֐����X�J���l�̏ꍇ�AFNCMB(function,'+',scalar) ���g�p���āA
%        �X�J���ɂ��֐��𕽍s�ړ����܂��B)
%   FNCMB(function,matrix)    �֐��̌W���ɍs���K�p���܂��B
%   FNCMB(function,string)    m-�t�@�C���A�܂��́A�֐��̌W���ɕ������
%                             ����Ďw�肳�ꂽ�֐���K�p���܂��B
%
% FNCMB(function,function) �́A�����^��2�̊֐��̘a�ł��B
% FNCMB(function,matrix,function) �́A
%         FNCMB(fncmb(function,matrix),function) �Ɠ����ł��B
% FNCMB(function,matrix,function,matrix) �́A
%         FNCMB(fncmb(function,matrix),fncmb(function,matrix)) �Ɠ����ł��B
%                        
% FNCMB(function,op,function) �́A2�̊֐�(�ꍇ�ɂ���Ă͈قȂ�^)�̘a
%                      (op �� '+')�A��(op �� '-')�A�܂��͓_�Ɋւ����
%                      (op �� '*')�ł��B���ɁA���Z/���Z�̏ꍇ�A2�Ԗڂ�
%                      �֐��́A1�Ԗڂ̊֐��̖ڈ��ƂȂ邽��1�_(���Ȃ킿
%                      �萔�֐�)�ł��邩������܂���B
%
% ���̂Ƃ���A���ׂĂ̊֐��́AFNCMB(function,operation) �̌Ăяo����
% �����āA1�ϐ�(UNIVARIATE)�łȂ���΂Ȃ�܂���B
%
% ���:
%
%      fncmb( sp1, '+', sp2 );
%
% �́ASP1 �ɂ���֐��� SP2 �ɂ���֐���(�_�Ɋւ���)�a���o�͂��A
%
%      fncmb( spmak( augknt(4:9,4), eye(8) ), [1:8] )
%
% �́A�ߓ_�� AUGKNT(4:9,4) �ɑ΂��āA8�̃L���[�r�b�NB-�X�v���C�� B_j 
% �ɑ΂��� sum_{j=1:8} j*B_j ���쐬���邽�߂̕��G�ȕ��@�ł��B
%
% SP ���AB-�^�̃X�v���C�����܂ޏꍇ�A
%
%      spa = fncmb( sp, 'abs' );
%
% �́A���̌W�������ׂĐ�Βl�ɕύX���܂��B
% 
% FN ���A3�̃x�N�g���l�֐�(���Ȃ킿�AR^3 �ւ̎ʑ�)�̏ꍇ�A
%
%      fncmb( fn, [1 0 0; 0 0 1] )
%
% �́A(x,z) ���ʂւ̎ˉe���o�͂��܂��B
%
%      fncmb( fncmb (fn, [1 0 0; 0 0 -1; 0 1 0] ), [1;2;3] )
%
% �́AFN �ɂ���֐��̃C���[�W��x���̎����90�x��]���A���̂��Ƀx�N�g�� 
% (1,2,3) �ɂ���ĕ��s�ړ����܂��B


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

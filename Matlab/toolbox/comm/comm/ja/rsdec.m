% RSDEC   ���[�h�\������������
%
% DECODED = RSDEC(CODE,N,K) �́A�f�t�H���g�̐������������g�p���āA(N,K)  
% ���[�h�\�������������p���āACODE�̎�M�M���𕜍����܂��B
% CODE �́AGF(2^m)�𒴂���V���{���̃K���A�z��ł���A�����ŁAm �́A
% �V���{�����Ƃ̃r�b�g���ł��BCODE��N-�v�f�̊e�s�́A��܂肪�܂܂��
% �g�D�����̃��[�h��\�킵�܂��B�����ŁA�p���e�B�V���{���́A�Ō�ɂ���A
% �ō��[�̃V���{���͍ŏ�ʃV���{���ł��B N ���A2^m-1��菬�����Ƃ��A
% RSDEC�́ACODE���A���̊܂܂��Z�k�������ł���Ɖ��肳��܂��B
%   
% �K���A�z�� DECODED�ł́A�e�s�́ACODE�̑Ή�����s�𕜍����܂��B
% �����̌��́A CODE�̍s���A(N-K)/2�ȏ�̃G���[���܂ޏꍇ�ɋN����܂��B
% ���̏ꍇRSDEC�́ACODE�̍s�̍Ōォ��P��N-K�V���{�����������Ƃɂ��A
% DECODED�̑Ή�����s���`�����܂��B
%   
% DECODED = RSDEC(CODE,N,K,GENPOLY) �́AGENPOLY �ɃR�[�h�̐�����������
% �w�肷�邱�Ƃ������ẮA��̃V���^�b�N�X�Ɠ����ł��B���̏ꍇ�AGENPOLY ��
% �������������~�ׂ��̏��ɂȂ�ׂ��A�K���A�̏�̌W���x�N�g���ł��B 
% �����������́AN-K�������K�v������܂��B �f�t�H���g�̐�����������
% �g�p���邽�߂ɂ́AGENPOLY �� [] �ɐݒ肵�܂��B
%   
% DECODED = RSDEC(...,PARITYPOS) �́A�����̍ۂɃp���e�B�V���{����
% ���̓��b�Z�[�W�̑O�ɕt���Ă���̂��A��ɂ��Ă���̂����w�肵�܂��B
% ������ PARITYPOS �́A'end'�A���邢�́A'beginning'�̂����ꂩ�ɂȂ邱�Ƃ�
% �ł��܂��B�f�t�H���g�́A'end'�ł��BPARITYPOS ���A'beginning'�ł���ƁA
% �����ł��Ȃ��ꍇ�ARSDEC�̍s�̍Ō�ł͂Ȃ��A�n�߂���N-K�V���{����������
% ���ʂƂȂ�܂��B
%
% [DECODED,CNUMERR] = RSDEC(...) �́A��x�N�g��CNUMERR���o�͂��܂��B
% �e�v�f�́ACODE�̑Ή�����s�̒������ꂽ�G���[�̐��ł��B
% CNUMERR��-1�̒l�́ACODE�̂��̍s�̕����̌��������܂��B
%   
% [DECODED,CNUMERR,CCODE] = RSDEC(...) �́ACODE�̒��������o�[�W�����A
% CCODE ���o�͂��܂��BGalois �z��CCODE�́A CODE�Ɠ����t�H�[�}�b�g�ł��B
% CODE �̂���s�ŁA�����̌�肪�N����ꍇ�ACCODE�̑Ή�����s�́A�ύX
% ����Ȃ��s���܂݂܂��B 
%
% ���:
%      n=7; k=3;                       % �R�[�h���[�h�ƃ��b�Z�[�W���[�h�̒���
%      m=3;                               % �V���{�����Ƃ̃r�b�g��
%      msg  = gf([7 4 3;6 2 2;3 0 5],m)   % 3��k-�V���{�����b�Z�[�W���[�h
%      code = rsenc(msg,n,k);             % 2��n-�V���{���R�[�h���[�h
%      %1�Ԗڂ̌��1�̃G���[�A2�Ԗڂ�2�̃G���[�A3�Ԗڂ�3�̃G���[��ǉ�
%      errors = gf([3 0 0 0 0 0 0;4 5 0 0 0 0 0;6 7 7 0 0 0 0],m);
%      codeNoi = code + errors
%      [dec,cnumerr] = rsdec(codeNoi,n,k) % �����̌�� : cnumerr(3) ��-1�ł�
%
% �Q�l RSENC, GF, RSGENPOLY.


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2.4.1 $  $Date: 2003/06/23 04:35:12 $ 

% RSENC   ���[�h�\������������
%
% CODE = RSENC(MSG,N,K) �́A�f�t�H���g�̐�����������p���āA(N,K) 
% ���[�h�\��������������g�p���āAMSG�̃��b�Z�[�W�𕄍����܂��B
% MSG �́AGF(2^m)���Galois�z��ł��B MSG ��K-�v�f�̊e�s�́A���b�Z�[�W
% ���[�h��\���܂��B �����ŁA�ł����̃V���{���́A�ŏ�ʃV���{���ł��B
% N ���A2^m-1��菬�����ꍇ�ARSENC �́A�Z�k�����[�h�\�������R�[�h���g�p
% ���܂��B�p���e�B�V���{���́A�o��Galois �z��R�[�h�̊e��̍Ō�ɂ���܂��B 
%   
% CODE = RSENC(MSG,N,K,GENPOLY) �́AGENPOLY�ɃR�[�h�̐������������w��
% ���邱�Ƃ������ẮA��̃V���^�b�N�X�Ɠ����ł��B 
% ���̏ꍇ�AGENPOLY �́A�������������~�ׂ��̏��ɕ��ׂ��A�K���A�̏��
% �W���x�N�g���ł��B�����������́AN-K �������K�v������܂��B 
% �f�t�H���g�̐������������g�p���邽�߂ɂ́AGENPOLY��[]�ɐݒ肵�܂��B 
%   
% CODE = RSENC(...,PARITYPOS) �́A�R�[�h���`������ۂɁA���̓��b�Z�[�W��
% �΂� RSENC���A�p���e�B�V���{����O�ɕt�����邩�A���邢�́A���ɕt��
% ���邩���w�肵�܂��B������PARITYPOS �́A'end' �A���邢�́A'beginning'
% �̂����ꂩ�ł��B�f�t�H���g�́A'end'�ł��B
%
% ���:
%      n=7; k=3;                 % �R�[�h���[�h ����� ���b�Z�[�W���[�h�̒���
%      m=3;                             % �V���{�����Ƃ̃r�b�g��
%      msg  = gf([5 2 3; 0 1 7],m)      % 2��k-�V���{�����b�Z�[�W���[�h
%      code = rsenc(msg,n,k)            % 2��n-�V���{���R�[�h���[�h
%
%      genpoly = rsgenpoly(n,k);        % �f�t�H���g�̐���������
%      code2 = rsenc(msg,n,k,genpoly);  % code�����code1�́A�����R�[�h���[�h
%                                       % �ł��B
%
%      nS = n-1;  kS = k-1;
%      msgS  = gf([5 2;0 1],m);
%      codeS = rsenc(msgS,nS,kS);       % �Z�k���ꂽ(6,2) ���[�h�\�������R�[�h
% 
% �Q�l RSDEC, GF, RSGENPOLY.


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2.4.1 $  $Date: 2003/06/23 04:35:14 $ 

% MKARGS �́AMKSYS �ō쐬���ꂽ���͈������g�����܂��B
%
% CMD = mkargs(TEMP,N,F) �́A(MKSYS �ō쐬���ꂽ)�V�X�e�����܂ޓ��͈�����
% �X�g���g��������A�e�V�X�e���̈ʒu�ɃV�X�e���s���}�����邽�߂ɁA�֐���
% ���Ŏg�p�������̂ł��B��ʓI�Ȏg�����́A�֐���`���C���̒��ŁAZ1,Z2,Z3
% ,...,ZN �̌^�Őݒ肳��Ă�����͈����̃��X�g�ŕύX���A�ύX�����֐���`��
% �C���̂������2�̃��C����}�����Ă��������B���Ƃ��΁A
% 
%            function [x,y,z] = foo(a,b,c)
% 
% �́A���̂��̂ƒu���������܂��B
% 
%            function [x,y,z] = foo(Z1,Z2,Z3)
%            inargs='(a,b,c)';
%            eval(mkargs(inargs,nargin))
%
% �I�v�V�������� TY �́A���݂��Ă���ꍇ�A���҂������A���Ƃ��΁ATY = 
% 'ss,tss' �Ő�����悤�ȃV�X�e���ɑ΂���g�p�ł���V�X�e����ݒ肵�܂��B
%
% ���ӁFMATLAB �̃o�[�W�����ɂ���ẮAEVAL �֐��̎�舵���Ƀo�O�����邽�߁A
% ������ INARGS �́A������ INARGS �̒��ɖ��O Z1,Z2,... ���܂܂��Ȃ��ł���
% �����B 

% Copyright 1988-2002 The MathWorks, Inc. 

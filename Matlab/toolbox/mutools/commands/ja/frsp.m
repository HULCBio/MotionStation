% function out = frsp(sys,omega,T,balflg)
%
% SYSTEM�s��̕��f���g�������́A���g���������܂�VARYING�s��𐶐����܂��B
%
% SYS     - SYSTEM�s��
% OMEGA   - �������v�Z������g���A����VARYING�s�񂪐ݒ肳��Ă���Ƃ��́A
%           �����̓Ɨ��ϐ����g���܂��B
% T       - 0(�f�t�H���g)�́A�A���n�V�X�e���������AT ~= 0�̏ꍇ�A�T���v
%           ������T���g���ė��U�����܂��B
% BALFLG  - 0(�f�t�H���g)�́A�v�Z����O��A�s��𕽍t�����A��[���̏ꍇ�́A
%           ��ԋ�Ԃ�ύX���Ȃ��Ōv�Z���܂��B
% OUT     - VARYING���g�������s��
%
% �Q�l: BALANCE, HESS, SAMHLD, TUSTIN, VPLOT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

% function matout = xtracti(mat,ivindex,ascon)
%
% MAT��VARYING�s��ŁAIVINDEX�����̂悤�Ȑ��̐����z��̏ꍇ�A
%
%       MAX(IVINDEX) <= LENGTH(GETIV(MAT))
%
% MATOUT��IVINDEX�Ԗڂ̓Ɨ��ϐ��l�Ɋ֘A����s��ł��BMATOUT�́A�f�t�H��
% �g�ł�VARYING�s��ł��B�I�v�V������3�Ԗڂ̈���ASCON�����̐��ɐݒ肳��
% ��ƁAMATOUT�́A���o���ꂽ�f�[�^���܂�CONSTANT�s��ł��B
%
% MAT��CONSTANT�܂���SYSTEM�s��ŁAINDVINDX�����̐����̏ꍇ�AMATOUT��MAT
% �Ɠ������Ȃ�܂��B
%
% �Q�l: GETIV, MINFO, SCLIV, SEL, VAR2CON, XTRACT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

% DEAL   ���͂��o�͂֕��z
% 
% [A,B,C,...] = DEAL(X,Y,Z,...)�́A���̓��X�g�Əo�̓��X�g�̒P���ȃ}�b�`
% ���O���s���܂��B����́AA = X�AB = Y�AC = Z���Ɠ����ł��B
% 
% [A,B,C,...] = DEAL(X)�́A1�̓��͂�v������邷�ׂĂ̏o�͂ɃR�s�[����
% ���B����́AA = X�AB = X�AC = X���Ɠ����ł��B
%
% DEAL�́A�J���}�ŋ�؂�ꂽ�g�����X�g�ɂ��Z���z���\���̂�p����Ƃ�
% �ɁA���ɕ֗��ł��B���̂悤�ȕ֗��ȍ\��������܂��B
% 
% [S.FIELD] = DEAL(X)�́A�\���̔z��S����FIELD�Ƃ����t�B�[���h���ׂĂɒlX
% ��ݒ肵�܂��BS�����݂��Ȃ���΁A[S(1:M).FIELD] = DEAL(X)���g���܂��B
% 
% [X{:}] = DEAL(A.FIELD)�́AFIELD�Ƃ������O�̃t�B�[���h�̒l���A�Z���z��X
% �ɃR�s�[���܂��BX�����݂��Ȃ���΁A[X{1:M}] = DEAL(A.FIELD)���g���܂��B
% 
% [A,B,C,...] = DEAL(X{:})�́A�Z���z��X�̓��e���A�ʁX�̕ϐ�A�AB�AC�ɃR�s
% �[���܂��B
% 
% [A,B,C,...] = DEAL(S.FIELD)�́AFIELD�Ƃ������O�̃t�B�[���h�̓��e���A��
% �̕ϐ�A�AB�AC...�ɃR�s�[���܂��B
%
% ���:
%       sys = {rand(3) ones(3,1) eye(3) zeros(3,1)};
%       [a,b,c,d] = deal(sys{:});
%
%       direc = dir; filenames = {};
%       [filenames{1:length(direc),1}] = deal(direc.name);
%
% �Q�l�F LISTS, PAREN.


%   Copyright 1984-2004 The MathWorks, Inc. 

% OHKAPP �œK�n���P���m�����ߎ� (����v�����g)
%
% [SS_X,SS_Y,AUG] = OHKAPP(SS_,MRTYPE,IN)�A�܂��́A
% [AX,BX,CX,DX,AY,BY,CY,DY,AUG] = OHKAPP(A,B,C,D,MRTYPE,IN) �́A�f�X�N��
% �v�^�V�X�e���ɂ��œK�n���P���m�����ߎ����Z�o���܂��B
% 
% (AX,BX,CX,DX)�͒᎟�������f���ŁA(AY,BY,CY,DY)�͉��̔���ʕ��ł��B
%
%   (G - Ghed)�̖�����m���� <= 
%            K�Ԗڂ���n�Ԗڂ̃n���P�����ْl�܂ł̘a��2�{
% 
% ���t���͕K�v����܂���B
%
%   mrtype = 1�̏ꍇ�Ain�͒᎟�������f���̎���k�B
%   mrtype = 2�̏ꍇ�A�g�[�^���̌덷��"in"��菬�����Ȃ�᎟�������f����
%                     �Z�o�B
%   mrtype = 3�̏ꍇ�A�n���P�����ْl��\�����A����k�̓��͂𑣂��܂��B
%                    (���̏ꍇ�A"in"���w�肷��K�v�͂���܂���B)
%
% AUG = [�ő�n���P�����ْl ,�폜���ꂽ���(s) ,�덷�͈� ,...
%            �n���P�����ْl�̏W��]



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 

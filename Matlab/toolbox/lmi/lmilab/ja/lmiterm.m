% lmiterm(termID,A,B,flag)
%
% �J�����g�ɋL�q����Ă���A��LMI�̒���LMI�ɍ���ǉ����܂��B���́A�O����
% �q�A�萔�s��AX���s��ϐ��̂Ƃ��͕ϐ���A*X*B�A�܂��́AA*X'*B�ł��B
%
% �d�v: 
% ��Ίp�u���b�N(i,j)��(j,i)�́A���݂��ɓ]�u�����̂ŁA������2�̃u
% ���b�N�̂���1�̍��̓��e�݂̂�ݒ肵�Ă��������B
%
% ����:
%  TERMID    ���̈ʒu�Ɛ�����ݒ肷��4�v�f�x�N�g���B
%            LMI
%		TERMID(1) = +n  ->  n�Ԗڂ�LMI�̍��ӂ̍�
%		TERMID(1) = -n  ->  n�Ԗڂ�LMI�̉E�ӂ̍�
%            �u���b�N
%		�O�����q�ɑ΂��ẮATERMID(2:3) = [0 0]�ł��B�����łȂ�
%               ��΁A����LMI��(i,j)�u���b�N�ɑ�����ꍇ�́ATERMID(2:3) 
%               = [i j]�Ɛݒ肵�܂��B
%            ���̃^�C�v
%		TERMID(4) =  0  ->  �萔��
%		TERMID(4) =  X  ->  �ϐ���A*X*B
%		TERMID(4) = -X  ->  �ϐ���A*X'*B
%               �����ŁAX�́ALMIVAR�ŏo�͂���ϐ��̎��ʎq�ł��B
%  A         �O�����q�̒l�A�萔���A�ϐ���A*X*B�A�܂��́AA*X'*B�̍����W��
%  B         �ϐ���A*X*B�A�܂��́AA*X'*B�̉E���W��
%  FLAG      �Ίp�u���b�N�ɂ����ĕ\��A*X*B+B'*X'*A'��ݒ肷�邽�߂̊ȒP
%            �ȕ��@�ł��BFLAG='s'�Ɛݒ肷��ƁA1��LMITERM�R�}���h�ŁA
%            ���̂悤�ȕ\�����ݒ�ł��܂��B
%
% �Q�l�F    SETLMIS, LMIVAR, GETLMIS, LMIEDIT, NEWLMI.



% Copyright 1995-2002 The MathWorks, Inc. 

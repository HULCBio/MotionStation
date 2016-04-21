% HANK2SYS    Hankel �s�����`�V�X�e�����f���֕ϊ�
%
% [NUM, DEN] = HANK2SYS(H, INI, TOL) �́AHankel �s�� H �𕪎q NUM �ƕ���
% DEN �̐��`�V�X�e���`�B�֐��֕ϊ����܂��BINI �́A����0�ł̃V�X�e���C��
% �p���X�ł��BTOL > 1 �̂Ƃ��ATOL �͕ϊ��̎�����\���܂��BTOL < 1 �̂Ƃ�
% TOL �́A���ْl�Ɋ�Â��Ď�����I������ۂ̋��e�덷��\���܂��BTOL ��
% �f�t�H���g�l��0.01�ł��B���̕ϊ��ł́A���ْl����(SVD)���g�p���܂��B
% 
% [NUM, DEN, SV] = HANK2SYS(...) �́A�`�B�֐��� SVD �l���o�͂��܂��B
% 
% [A, B, C, D] = HANK2SYS(...)�́A���`�V�X�e���̏�ԋ�ԃ��f���� A, B, 
% C, D �s����o�͂��܂��B
% 
% [A, B, C, D, SVD ] = HANK2SYS(...) �́A��ԋ�ԃ��f���� SVD �l���o��
% ���܂��B
%
% �Q�l�F RCOSFLT.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $

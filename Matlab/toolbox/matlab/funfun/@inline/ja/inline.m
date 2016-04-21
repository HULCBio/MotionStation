% INLINE   INLINE�I�u�W�F�N�g�̍쐬
%
% INLINE(EXPR) �́A������ EXPR ���Ɋ܂܂�Ă���MATLAB�\������C�����C��
% �֐��I�u�W�F�N�g���쐬���܂��B���͈����́A�ϐ����� EXPR �ŒT�����邱��
% �ɂ�莩���I�ɋ��߂��܂�(�Q�� SYMVAR)�B�ϐ������݂��Ȃ��ꍇ�A'x' 
% ���g���܂��B
%
% INLINE(EXPR, ARG1, ARG2, ...) �́A���͈����Ƃ��ĕ�����ARG1�AARG2�A...
% ���܂ރC�����C���֐����쐬����܂��B�}���`�L�����N�^�V���{�����g������
% ���ł��܂��B
%
% INLINE(EXPR, N) ������ N �̓X�J���ŁA���͈����� 'x', 'P1', 'P2', ..., 
% 'PN' �����C�����C���֐����쐬���܂��B
%
% ���:
%     g = inline('t^2')
%     g = inline('sin(2*pi*f + theta)')
%     g = inline('sin(2*pi*f + theta)', 'f', 'theta')
%     g = inline('x^P1', 1)
%
% �Q�l : SYMVAR.



%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:52:03 $

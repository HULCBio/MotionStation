% WHILE   �s��񐔂̌J��Ԃ��X�e�[�g�����g
% 
% WHILE�X�e�[�g�����g�̈�ʓI�ȏ����́A���̂悤�ɂȂ�܂��B
% 
%    WHILE expression
%      statements
%    END
% 
% statements�́Aexpression�̎��������ׂ�0�łȂ��v�f�ł���ԁA���s����
% �܂��Bexpression�́Arop�� =  = �A<�A>�A< = �A> = �A~ = �̂Ƃ��A�ʏ�
% expr rop expr�̌��ʂł��B
%
% BREAK�X�e�[�g�����g�́A���[�v���I�����邽�߂Ɏg�p����܂��B
%
% ���Ƃ���(A�����ɒ�`����Ă���Ɖ��肵�܂�)
%  
%           E = 0*A; F = E + eye(size(E)); N = 1;
%           while norm(E+F-E,1) > 0,
%              E = E + F;
%              F = A*F/N;
%              N = N + 1;
%           end
%
% �Q�l�FFOR, IF, SWITCH, BREAK, CONTINUE, END.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:36 $
%   Built-in function.
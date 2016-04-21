% GAMMAINC   �s���S�K���}�֐�
% 
% Y = GAMMAINC(X,A) �́AX �� A �̑Ή�����v�f�ɂ��āA�s���S�K���}�֐���
% ���s���܂��BX �� A �́A�����T�C�Y�łȂ���΂Ȃ�܂���(�܂��́A�����ꂩ��
% �X�J���ł��\���܂���)�BA �͔񕉂łȂ���΂Ȃ�܂���B
%
% �s���S�K���}�֐��́A���̂悤�ɒ�`����܂��B 
% 
% gammainc(x,a) = 1 ./ gamma(a) .* t^(a-1) exp(-t)      
%                     dt��0����x�܂ł̐ϕ�
%
% �C�ӂ̐��� a �ɑ΂��āAx ��������ɋߕt���ƁAgammainc(x,a) ��1�ɋߕt����
% ���Bx �� a ����������΁Agammainc(x,a) ~ =  x^a �Ȃ̂ŁAgammainc(0,0) ��
% 1�ɂȂ�܂��B
%
% Y = GAMMAINC(X,A,TAIL)�́AX���񕉂̂Ƃ��s���S�K���}�֐��̐����w�肵�܂��B
% �I�����́A'lower' (�f�t�H���g)��'upper'�ł��Bupper�s���S�K���}�֐��́A
% ���̂悤�ɒ�`����܂��B
%   1 - gammainc(x,a).
%
%   ���[�j���O: X�����̂Ƃ��AY��abs(X) > A+1�ɑ΂��ĕs���m�ɂȂ�ꍇ������܂��B

% �Q�l�FGAMMA, GAMMALN, PSI.


%   Copyright 1984-2002 The MathWorks, Inc. 

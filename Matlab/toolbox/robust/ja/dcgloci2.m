% DCGLOCI2  ���U�̓����Q�C��/�ʑ����g������
%
% [CG,PH] = DCGLOCI2(SS_, CGTYPE, W, Ts) �A�܂��́A
% [CG,PH] = DCGLOCI2(A, B, C, D, CGTYPE, W, Ts) �́A
%                           -1
% ���g������ G(z) = C(zI - A)  B + D ������ Ts �b�ŃT���v�����O���ꂽ��
% �U�V�X�e��
% 
%                x(k+1) = Ax(k) + Bu(k)
%                y(k) = Cx(k) + Du(k)
% 
% �ɑ΂�������Q�C��/�ʑ��l���܂ލs�� G ��PH ���v�Z���܂��B
% 
% DCGLOCI �́A"cgtype" �̒l�Ɉˑ����āA�ŗL�l�̌v�Z���s�Ȃ��܂��B
%
%     cgtype = 1   ----   char( G(z) )
%     cgtype = 2   ----   char( inv( G(z) ) )
%     cgtype = 3   ----   char( I + G(z) )
%     cgtype = 4   ----   char( I + inv( G(z) )
%
% �x�N�g�� W �́A���g���������v�Z������g����ݒ肷����̂ł��B�s�� CG 
% �� PH �̍s�́A�~���ɓ����Q�C��/�ʑ��ɑΉ����܂��B
%

% Copyright 1988-2002 The MathWorks, Inc. 

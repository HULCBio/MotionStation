% CGLOCI2   �A���n�̓����Q�C��/�ʑ����g������
%
% [CG,PH] = CGLOCI2(SS_,cgtype,W)�A�܂��́A
% [CG,PH] = CGLOCI2(A, B, C, D, CGTYPE, W) �́A���g������
%                          -1
%      G(jw) = C(jwI - A)  B + D.
% 
% �����A���̃V�X�e��
%                .
%                x = Ax + Bu
%                y = Cx + Du
% 
% �̓����Q�C��/�ʑ��l���܂ލs�� CG �� PH ���v�Z���܂��B
%
% CGLOCI �́A"cgtype"�̒l�Ɉˑ����āA���̂����ꂩ�̌ŗL�l���v�Z���܂��B
%
%     cgtype = 1   ----   G(jw)
%     cgtype = 2   ----   inv(G(jw))
%     cgtype = 3   ----   I + G(jw)
%     cgtype = 4   ----   I + inv(G(jw))
%
% �x�N�g�� W �́A���g���������v�Z������g���_����Ȃ�܂��B�s�� CG �� 
% PH �́A�~���ɁA�����Q�C���ƈʑ����s�ɏo�͂��܂��B

% Copyright 1988-2002 The MathWorks, Inc. 

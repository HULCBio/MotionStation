% [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r)
% data = hinfpar(P,r,string)
%
% �W��Hinf�v�����g
%
%                    |  a   b1   b2 |
%             P  =   | c1  d11  d12 |
%                    | c2  d21  d22 |
%
% ���A���p�b�N���A��ԋ�ԍs��a,b1,b2,...���o�͂��܂��B2�s1��x�N�g��R��
% D22�̃T�C�Y��ݒ肵�܂��B���Ȃ킿R = [ NY , NU ]�ŁA������
% 
%     NY = �ϑ��ʂ̐�	      NU = ����ʂ̐�
% 
% �ł��BP�́ALTISYS���g���č쐬���ꂽ���̂łȂ���΂Ȃ�܂���B
%
% ����̏�ԋ�ԍs��(�Ⴆ��c1)�𓾂邽�߂ɂ́A3�Ԗڂ̈����𕶎���'a','b1',
% 'b2',...�̂����ꂩ�ɐݒ肵�Ă��������B���Ƃ��΁Ac1 = hinfpar(P,r,'c1')
% �ƂȂ�܂��B
%
% �Q�l�F    LTISYS, LTISS.



% Copyright 1995-2002 The MathWorks, Inc. 

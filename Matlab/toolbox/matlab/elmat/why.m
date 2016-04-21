function why(n)
%WHY    Provides succinct answers to almost any question.
%   WHY, by itself, provides a random answer.
%   WHY(N) provides the N-th answer.
%   Please embellish or modify this function to suit your own tastes.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.15 $  $Date: 2002/06/17 13:20:59 $

if nargin > 0, rand('state',n); end
switch fix(10*rand)
    case 0,        a = special_case;
    case {1 2 3},  a = phrase;
    otherwise,     a = sentence;
end
a(1) = upper(a(1));
disp(a);


%------------------

function a = special_case
switch fix(12*rand)
    case 0,   a = 'why not?';
    case 1,   a = 'don''t ask!';
    case 2,   a = 'it''s your karma.';
    case 3,   a = 'stupid question!';
    case 4,   a = 'how should I know?';
    case 5,   a = 'can you rephrase that?';
    case 6,   a = 'it should be obvious.';
    case 7,   a = 'the devil made me do it.';
    case 8,   a = 'the computer did it.';
    case 9,   a = 'the customer is always right.';
    case 10,  a = 'in the beginning, God created the heavens and the earth...';
    otherwise,a = 'don''t you have something better to do?';
end

function a = phrase
switch fix(3*rand)
    case 0,    a = ['for the ' nouned_verb ' ' prepositional_phrase '.'];
    case 1,    a = ['to ' present_verb ' ' object '.'];
    otherwise, a = ['because ' sentence];
end

function a = preposition
switch fix(2*rand)
    case 0,    a = 'of';
    otherwise, a = 'from';
end

function a = prepositional_phrase
switch fix(3*rand)
    case 0,    a = [preposition ' ' article ' ' noun_phrase];
    case 1,    a = [preposition ' ' proper_noun];
    otherwise, a = [preposition ' ' accusative_pronoun];
end

function a = sentence
switch fix(0)
    case 0,    a = [subject ' ' predicate '.'];
end

function a = subject
switch fix(4*rand)
    case 0,    a = proper_noun;
    case 1,    a = nominative_pronoun;
    otherwise, a = [article ' ' noun_phrase];
end

function a = proper_noun
switch fix(8*rand) 
    case 0,    a = 'Cleve';
    case 1,    a = 'Jack';
    case 2,    a = 'Bill';
    case 3,    a = 'Joe';
    case 4,    a = 'Pete';
    case 5,    a = 'Loren';
    case 6,    a = 'Damian';
    case 7,    a = 'Barney';
    end

function a = noun_phrase
switch fix(4*rand)
    case 0,    a = noun;
    case 1,    a = [adjective_phrase ' ' noun_phrase];
    otherwise, a = [adjective_phrase ' ' noun];
end

function a = noun
switch fix(6*rand)
    case 0,    a = 'mathematician';
    case 1,    a = 'programmer';
    case 2,    a = 'system manager';
    case 3,    a = 'engineer';
    case 4,    a = 'hamster';
    case 5,    a = 'kid';
end

function a = nominative_pronoun
switch fix(5*rand)
    case 0,    a = 'I';
    case 1,    a = 'you';
    case 2,    a = 'he';
    case 3,    a = 'she';
    case 4,    a = 'they';
end

function a = accusative_pronoun
switch fix(4*rand)
    case 0,    a = 'me';
    case 1,    a = 'all';
    case 2,    a = 'her';
    case 3,    a = 'him';
end

function a = nouned_verb
switch fix(2*rand)
    case 0,    a = 'love';
    case 1,    a = 'approval';
end

function a = adjective_phrase
switch fix(6*rand)
    case {0 1 2},a = adjective;
    case {3 4},  a = [adjective_phrase ' and ' adjective_phrase];
    otherwise,   a = [adverb ' ' adjective];
end

function a = adverb
switch fix(3*rand)
    case 0,    a = 'very';
    case 1,    a = 'not very';
    otherwise, a = 'not excessively';
end

function a = adjective
switch fix(7*rand)
    case 0,    a = 'tall';
    case 1,    a = 'bald';
    case 2,    a = 'young';
    case 3,    a = 'smart';
    case 4,    a = 'rich';
    case 5,    a = 'terrified';
    otherwise, a = 'good';
end

function a = article
switch fix(3*rand)
    case 0,    a = 'the';
    case 1,    a = 'some';
    otherwise, a = 'a';
end

function a = predicate
switch fix(3*rand)
    case 0,    a = [transitive_verb ' ' object];
    otherwise, a = intransitive_verb;
end

function a = present_verb
switch fix(3*rand)
    case 0,    a = 'fool';
    case 1,    a = 'please';
    otherwise, a = 'satisfy';
end

function a = transitive_verb
switch fix(10*rand)
    case 0,    a = 'threatened';
    case 1,    a = 'told';
    case 2,    a = 'asked';
    case 3,    a = 'helped';
    otherwise, a = 'obeyed';
end

function a = intransitive_verb
switch fix(6*rand)
    case 0,    a = 'insisted on it';
    case 1,    a = 'suggested it';
    case 2,    a = 'told me to';
    case 3,    a = 'wanted it';
    case 4,    a = 'knew it was a good idea';
    otherwise, a = 'wanted it that way';
end

function a = object
switch fix(10*rand)
    case 0,    a = accusative_pronoun;
    otherwise, a = [article ' ' noun_phrase];
end

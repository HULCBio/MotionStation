function outv = sf_deal_cards (cmd)

% Copyright 2002 The MathWorks, Inc.

    persistent vec;

    if isempty(vec)
        vec = zeros(1,53);
        outv = vec;
        return;
    end

    if cmd ~= vec(1)
        deck = sf('Private','shuffle', 1:52);

        club_mask = hex2dec('10');
        diamond_mask = hex2dec('20');
        heart_mask = hex2dec('40');
        spade_mask = hex2dec('80');
        honor_mask = hex2dec('08');

        for j = 0:3
            s.clubs = [];
            s.diamonds = [];
            s.hearts = [];
            s.spades = [];

            hand = sort(deck(j*13+1:(j+1)*13));

            for i = 1:13
                suit = ceil(hand(i)/13);
                card = rem(hand(i)-1,13);
                cardName = [' ' int2str(card+2)];
                if card>8
                    switch card
                    case 9
                        cardName = ' J';
                    case 10
                        cardName = ' Q';
                    case 11
                        cardName = ' K';
                    case 12
                        cardName = ' A';
                    end
                end
                switch suit
                case 1
                    card = card + club_mask;
                    s.clubs = [cardName s.clubs];
                case 2
                    card = card + diamond_mask;
                    s.diamonds = [cardName s.diamonds];
                case 3
                    card = card + heart_mask;
                    s.hearts = [cardName s.hearts];
                case 4
                    card = card + spade_mask;
                    s.spades = [cardName s.spades];
                end
                cards(j*13+i) = card;
            end

            switch(j)
            case 0
                sf_bridge_state('north', s);
            case 1
                sf_bridge_state('east', s);
            case 2
                sf_bridge_state('south', s);
            case 3
                sf_bridge_state('west', s);
            end
        end

        vec = [~vec(1) cards];
    end

    outv = vec;

address  0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Badge {

    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::Errors;
    use 0x1::Token;
    use 0x1::Account;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::BadgeDetail;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    const MAX_BADGE_TYPE: u64 = 10;

    const ALREADY_PUBLISHED: u64 = 2001;
    const BADGE_NOT_EXIST: u64 = 2002;


    struct Badge has store, key {
        type: u64,
        level: u64,
        exp: u64,
        reward: Token::Token<Quark::QUARK>,
    }


    struct BadgeCollection has store, key {
        badge: vector<Badge>,
        badge_count: u64,
    }

    public fun initialize(account: &signer, candy: Token::Token<Quark::QUARK>) {
        assert(
            !exists<BadgeCollection>(Signer::address_of(account)),
            Errors::already_published(ALREADY_PUBLISHED)
        );

        move_to(account, BadgeCollection {
            badge: empty_badges(candy),
            badge_count: 0,
        });
    }


    fun empty_badges(candy: Token::Token<Quark::QUARK>): vector<Badge> {
        let vec = Vector::singleton(Badge {
            type: 1,
            exp: 0,
            level: 0,
            reward: candy
        });
        let i = 1;

        while (i < MAX_BADGE_TYPE) {
            Vector::push_back(&mut vec, Badge {
                type: i + 1,
                exp: 0,
                level: 0,
                reward: Token::zero<Quark::QUARK>(),
            });
            i = i + 1;
        };
        vec
    }

    public fun add_badge_exp(address: address, type: u64, exp: u64) acquires BadgeCollection {
        if (!exists<BadgeCollection>(address)) { return };
        let collection = borrow_global_mut<BadgeCollection>(address);
        let b = Vector::borrow_mut<Badge>(&mut collection.badge, type - 1);
        let (n_level, n_exp, reward_amount) = BadgeDetail::level_check(type, b.level, b.exp, exp);
        b.exp = n_exp;
        b.level = n_level;
        let (_, reward, reward_b) = Quark::reward_balance();
        reward_amount = reward_amount * Token::scaling_factor<Quark::QUARK>();
        if (reward + reward_b > reward_amount) {
            let reward_tokens = Quark::get_reward_token(reward_amount);
            Token::deposit(&mut b.reward, reward_tokens);
        }
    }


    public fun has_badge(address: address, type: u64): bool acquires BadgeCollection {
        if (!exists<BadgeCollection>(address)) { return false };
        let collection = borrow_global<BadgeCollection>(address);
        let badge = Vector::borrow(&collection.badge, type - 1);
        let (_, _level, exp, _) = unpack_badge(badge);
        exp > 0
    }

    public fun unpack_badge(badge: &Badge): (u64, u64, u64, u128) {
        (badge.type, badge.level, badge.exp, balance_for(badge))
    }

    fun balance_for(badge: &Badge): u128 {
        Token::value<Quark::QUARK>(&badge.reward)
    }


    public fun badge_info(address: address, type: u64): (u64, u64, u64, u128)  acquires BadgeCollection {
        assert(has_badge(address, type), Errors::invalid_argument(BADGE_NOT_EXIST));
        let collection = borrow_global<BadgeCollection>(address);
        let badge = Vector::borrow(&collection.badge, type - 1);
        unpack_badge(badge)
    }


    public fun is_new_user(address: address): bool acquires BadgeCollection {
        if (!exists<BadgeCollection>(address)) {
            return true
        };
        has_badge(address, 1)
    }

    public fun reward_amount(address: address): u128 acquires BadgeCollection {
        if (!exists<BadgeCollection>(address)) {
            return 0
        };
        let collection = borrow_global<BadgeCollection>(address);
        let i = 0;
        let ll = Vector::length<Badge>(&collection.badge);
        let sum = 0;
        while (i < ll) {
            let badge = Vector::borrow(&collection.badge, i);
            let c = balance_for(badge);
            sum = sum + c;
            i = i + 1;
        };
        sum
    }


    public fun claim_reward(account: &signer) acquires BadgeCollection {
        let collection = borrow_global_mut<BadgeCollection>(Signer::address_of(account));
        let i = 0;
        let ll = Vector::length<Badge>(&collection.badge);
        while (i < ll) {
            let badge = Vector::borrow_mut(&mut collection.badge, i);
            deposit_reward(account, badge);
            i = i + 1;
        };
    }


    fun deposit_reward(account: & signer, badge: &mut Badge) {
        let v = Token::value<Quark::QUARK>(&badge.reward);
        if (v >0) {
            let c = Token::withdraw<Quark::QUARK>(&mut badge.reward, v);
            let is_accept_token = Account::is_accepts_token<Quark::QUARK>(Signer::address_of(account));
            if (!is_accept_token) {
                Account::do_accept_token<Quark::QUARK>(account);
            };
            Account::deposit_to_self<Quark::QUARK>(account, c);
        };
    }
}
}
    
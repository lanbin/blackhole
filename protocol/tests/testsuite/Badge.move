//! account: bob
//! account: admin , 0xb987F1aB0D7879b2aB421b98f96eFb44
//! sender: admin
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_initialize(sender: signer) {
        Quark::initialize(&sender);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_initialize(sender: signer) {
        Badge::initialize(&sender, Quark::get_candy());
    }
}
// check: "Keep(EXECUTED)"
//
//! new-transaction
//! sender: bob
script {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_initialize(sender: signer) {
        Badge::initialize(&sender, Quark::get_candy());
    }
}
// check: " Keep(ABORTED { code: 512262, "

//  claim badge type 1 and exp 1
//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;

    fun test_initialize(sender: signer) {
        assert(Badge:: has_badge(Signer::address_of(&sender), 1) == false, 1);
        Badge::add_badge_exp(Signer::address_of(&sender), 1, 1);
        assert(Badge:: has_badge(Signer::address_of(&sender), 1) == true, 2);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;

    fun add_badge_exp(sender: signer) {
        Badge::add_badge_exp(Signer::address_of(&sender), 1, 1);
    }
}
// check: " Keep(ABORTED { code: 512776, "


//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun test_badge_info(sender: signer) {
        let (type, level, exp, reward_token) = Badge::badge_info(Signer::address_of(&sender), 1);
        assert(type == 1, 1);
        assert(level == 1, 2);
        assert(exp == 1, 3);
        assert(reward_token == Quark::params(), 4);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;

    fun reward_amount(sender: signer) {
        let reward_token_amount = Badge::reward_amount(Signer::address_of(&sender));
        assert(reward_token_amount == Quark::params(), 1);
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: bob
script {
    use 0x1::Token;
    use 0x1::Signer;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;
    fun add_badge_exp(sender: signer) {
        let i = 0;
        let last_reward = 0;
        let last_level = 0;
        while ( i < 100) {
            Badge::add_badge_exp(Signer::address_of(&sender), 2, 1);
            let (_, level, exp, reward_token) = Badge::badge_info(Signer::address_of(&sender), 2);
            if (exp < 5) {
                assert(level == 1, 1);
            }else if ( exp >=5 && exp < 10) {
                assert(level == 2, 2);
            } else if ( exp >=10 && exp < 15) {
                assert(level == 3, 3);
            } else if ( exp >=15 && exp < 20) {
                assert(level == 4, 4);
            }else if ( exp >=20 && exp < 25) {
                assert(level == 5, 5);
            }else if ( exp >=25 && exp < 30) {
                assert(level == 6, 6);
            }else {
                assert(level == exp / 5 + 1, 7);
            };

            let bonus = 0;
            if (last_level < level) {
                if (level == 2 ) {
                    bonus = 10;
                }else if (level == 3) {
                    bonus = 15;
                }else if (level == 4) {
                    bonus = 30;
                }else if (level == 5) {
                    bonus = 40;
                }else if (level >=6) {
                    bonus = 50;
                };
            };
            last_level  = level;
            last_reward = last_reward + 1 * Token::scaling_factor<Quark::QUARK>() + bonus * Token::scaling_factor<Quark::QUARK>();
            assert(last_reward == reward_token, 8);
            i = i + 1;
        };
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::Signer;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Badge;

    fun reward_amount(sender: signer) {
        let reward_token_amount = Badge::reward_amount(Signer::address_of(&sender));
        assert(reward_token_amount == 998000000000, 1);
    }
}
// check: "Keep(EXECUTED)"

address  0xb987F1aB0D7879b2aB421b98f96eFb44 {
module BadgeDetail {
    use 0x1::Errors;


    const BADGE_EXP_IS_OVERFLOW: u64 = 2003;
    const INVALID_BADGE_TYPE: u64 = 2004;
    const INVALID_ADD_EXP: u64 = 2004;

    public fun level_check(type: u64, level: u64, exp: u64, add_exp: u64): (u64, u64, u128) {
        if (type == 1) {
            let n = exp + add_exp;
            assert(n <=1, Errors::limit_exceeded(BADGE_EXP_IS_OVERFLOW));
            return (1, n, 0)
        };
        if (type == 2) {
            return check_invite_badge(level, exp, add_exp)
        };

        abort Errors::invalid_argument(INVALID_BADGE_TYPE)
    }


    fun check_invite_badge(level: u64, exp: u64, add_exp: u64): (u64, u64, u128) {
        assert(add_exp == 1, Errors::invalid_argument(INVALID_ADD_EXP));
        let reward: u128 = 1;
        let n_exp = exp + add_exp;

        let n_level = n_exp / 5 + 1;
        let levelup = n_level >level;
        if (levelup) {
            if (n_level == 2) {
                reward = reward + 10;
            }else if (n_level == 3) {
                reward = reward + 15;
            }else if (n_level == 4) {
                reward = reward + 30;
            }else if (n_level == 5) {
                reward = reward + 40;
            }else if (n_level >= 6) {
                reward = reward + 50;
            };
        };
        (n_level, n_exp, reward)
    }
}
}
    
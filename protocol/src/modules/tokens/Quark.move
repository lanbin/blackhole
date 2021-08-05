address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Quark {
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::Treasury;
    use 0x1::Math;

    const QUARK_PRECISION: u8 = 9;

    const TOTAL_QUARK_AMOUNT: u128 = 100000 * 1000000000;

    const CANDY_PERCENT: u128 = 5; // 5%
    const INVITATION_REWARD_PERCENT: u128 = 5; // 5%
    const INVITATION_REWARD_BOUNS_PERCENT: u128 = 0; //

    const TIME_MINT_QUARK_AMOUNT: u128 = 10000000000000 / 5;
    const TIME_MINT_QUARK_PERIOD: u64 = 1;

    const CANDY_PER_ADDRESS: u128 = 3;

    const ALREAD_CLAIMED_CANDY: u64 = 100;

    struct QUARK has copy, drop, store {}


    struct SharedBurnCapability has key, store {
        cap: Token::BurnCapability<QUARK>,
    }

    struct SharedTreasuryWithdrawCapability has key, store {
        cap: Treasury::WithdrawCapability<QUARK>,
    }

    struct Vault  has store, key {
        candy_tokens: Token::Token<QUARK>,
        invitation_reward_tokens: Token::Token<QUARK>,
        invitation_reward_bouns_tokens: Token::Token<QUARK>,
    }


    public fun reward_balance(): (u128, u128, u128) acquires Vault {
        let vault = borrow_global<Vault>(Token::token_address<QUARK>());
        (
            Token::value<QUARK>(&vault.candy_tokens),
            Token::value<QUARK>(&vault.invitation_reward_tokens),
            Token::value<QUARK>(&vault.invitation_reward_bouns_tokens),
        )
    }

    public fun initialize(account: &signer) {
        //register token
        Token::register_token<QUARK>(account, QUARK_PRECISION);
        Account::do_accept_token<QUARK>(account);
        //mint all token
        let all_tokens = Token::mint<QUARK>(account, TOTAL_QUARK_AMOUNT);

        //split token to candy and other reward
        let candy_amount = Math::mul_div(CANDY_PERCENT, TOTAL_QUARK_AMOUNT, 100);
        let invitation_reward_amount = Math::mul_div(INVITATION_REWARD_PERCENT, TOTAL_QUARK_AMOUNT, 100);
        let invitation_reward_bouns_amount = Math::mul_div(INVITATION_REWARD_BOUNS_PERCENT, TOTAL_QUARK_AMOUNT, 100);
        move_to(account, Vault {
            candy_tokens: Token::withdraw<QUARK>(&mut all_tokens, (candy_amount as u128)),
            invitation_reward_tokens: Token::withdraw<QUARK>(&mut all_tokens, (invitation_reward_amount as u128)),
            invitation_reward_bouns_tokens: Token::withdraw<QUARK>(&mut all_tokens, (invitation_reward_bouns_amount as u128)),
        });


        let withdraw_cap = Treasury::initialize<QUARK>(account, all_tokens);
        //        let liner_withdraw_cap = Treasury::issue_linear_withdraw_capability<QUARK>(&mut withdraw_cap,
        //            TIME_MINT_QUARK_AMOUNT,
        //            TIME_MINT_QUARK_PERIOD);
        //        Treasury::add_linear_withdraw_capability(account, liner_withdraw_cap);
        //
        //
        move_to(account, SharedTreasuryWithdrawCapability { cap: withdraw_cap });

        let mint_cap = Token::remove_mint_capability<QUARK>(account);
        Token::destroy_mint_capability(mint_cap);

        let burn_cap = Token::remove_burn_capability<QUARK>(account);
        move_to(account, SharedBurnCapability { cap: burn_cap });
    }

    public fun get_candy(): Token::Token<QUARK> acquires Vault {
        let (candy_amount, _reward_amount, _bonus_amount) = reward_balance();
        if (candy_amount >= CANDY_PER_ADDRESS) {
            let vault = borrow_global_mut<Vault>(Token::token_address<QUARK>());
            return Token::withdraw<QUARK>(&mut vault.candy_tokens, CANDY_PER_ADDRESS * Token::scaling_factor<QUARK>())
        };
        Token::zero<QUARK>()
    }

    public fun get_reward_token(amount: u128): Token::Token<QUARK> acquires Vault {
        let (_, reward_amount, bonus_amount) = reward_balance();
        let vault = borrow_global_mut<Vault>(Token::token_address<QUARK>());

        if (reward_amount >= amount) {
            return Token::withdraw(&mut vault.invitation_reward_tokens, amount)
        };
        if (bonus_amount >= amount) {
            return Token::withdraw(&mut vault.invitation_reward_bouns_tokens, amount)
        };

        let get_from_bounus = amount - bonus_amount;
        let get_from_reward = reward_amount - get_from_bounus;
        let token1 = Token::withdraw(&mut vault.invitation_reward_tokens, get_from_bounus);
        let token2 = Token::withdraw(&mut vault.invitation_reward_tokens, get_from_reward);
        return Token::join(token1, token2)
    }

    public fun params(): u128 {
        CANDY_PER_ADDRESS * Token::scaling_factor<QUARK>()
    }

    public fun add_to_treasury(token: Token::Token<QUARK>) {
        Treasury::deposit(token)
    }

    public fun treasury_balance(): u128 {
        Treasury::balance<QUARK>()
    }
}
}
    
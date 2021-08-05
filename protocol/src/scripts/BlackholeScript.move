address  0xb987F1aB0D7879b2aB421b98f96eFb44 {
module BlackholeScript {
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Quark;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Blackhole;
    use  0xb987F1aB0D7879b2aB421b98f96eFb44::Whitehole;

    public(script) fun initialize(sender: signer) {
        Quark::initialize(&sender);
    }

    public(script) fun has_candy(address: address): bool {
        Whitehole::has_candy(address)
    }

    public(script) fun candy_amount(address: address): u128 {
        Whitehole::candy_amount(address)
    }


    public(script) fun claim_reward(sender: signer, invite_address: address) {
        Whitehole::claim_reward(&sender, invite_address)
    }

    public(script) fun burn_every_token<TokenType: store>(sender: signer,
                                                          amount: u128,
                                                          message: vector<u8>) {
        Blackhole::burn_every_token<TokenType>(&sender, amount, message)
    }
}
}
    
address  0xb987F1aB0D7879b2aB421b98f96eFb44 {
module CapHolder {
    use 0x1::Signer;

    struct GetCapCapability<T> has key, store {}

    struct Hold<T> has key, store {
        x: T
    }

    public fun hold<T: store>(account: &signer, x: T): GetCapCapability<T> {
        move_to(account, Hold<T> { x });
        GetCapCapability {}
    }

    public fun get<T: store>(account: &signer): T acquires Hold, GetCapCapability {
        get_with_capability(
            account,
            borrow_global<GetCapCapability<T>>(Signer::address_of(account))
        )
    }

    fun get_with_capability<T: store>(account: &signer, _cap: &GetCapCapability<T>): T acquires Hold {
        let Hold { x } = move_from<Hold<T>>(Signer::address_of(account));
        x
    }

    public fun destroy_get_capability<T: store>(cap: GetCapCapability<T>) {
        let GetCapCapability<T> {} = cap;
    }
}
}
    
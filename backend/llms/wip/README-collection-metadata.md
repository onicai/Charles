# ICRC-7 style Collection Metadata ?

The CHARLES canister provides an endpoint to retrieve Collection Metadata based on the [ICRC-7](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md) specs:

```bash
type NFTCollection = 
  record {
    nft_supply_cap: nat64; 
    nft_total_supply: nat64; 
    nft_symbol: text; 
    nft_name: text; 
    nft_description: text;
  };

service : {
  nft_metadata:       ()                 -> (NFTCollection);
}
```

Ownership of a CHARLES token is determined by the Bitcoin Inscription, so the CHARLES ICRC-7 smart contract is not providing methods associated with the ledger.

## Collection Metadata

The metadata fields of the Smart Contract are configured after deployment, by calling the `nft_init` method, using the principal of the owner.

...
Note that if max values specified through metadata are violated in a query call by providing larger argument lists or resulting in larger responses than permitted, the canister traps with an according system error message.

Generic value in accordance with ICRC-3
```
type Value = variant { 
    Blob : blob; 
    Text : text; 
    Nat : nat;
    Int : int;
    Array : vec Value; 
    Map : vec record { text; Value }; 
};
```

| key | value | query call |
| - | - | - |
| icrc7:symbol  | CHARLES  | icrc7_collection_metadata : () -> (vec record { text; Value } ) query;<br>[icrc7_collection_metadata](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_collection_metadata) |

### Used ICRC-7 Metadata fields

| key | value | query call |
| - | - | - |
| icrc7:symbol  | CHARLES  | icrc7_symbol : () -> (text) query;<br>[icrc7_symbol](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_symbol) |
| icrc7:name  | Sir Charles The 3rd  |icrc7_name : () -> (text) query;<br>[icrc7_name](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_name)|
| icrc7:description<br>(optional)  | ...See Above...   |icrc7_description : () -> (opt text) query;<br>[icrc7_description](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_description)|
| icrc7:logo<br>(optional)  | Either a [DataURL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs) or a link   |icrc7_logo : () -> (opt text) query;<br>[icrc7_logo](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_logo)|
| icrc7:total_supply  | 25   |icrc7_total_supply : () -> (nat) query;<br>[icrc7_total_supply](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_total_supply)|

### Unused Optional ICRC-7 Metadata fields

| key | value | query call |
| - | - | - |
| icrc7:supply_cap<br>(optional)  | -   |icrc7_supply_cap : () -> (opt nat) query;<br>[icrc7_supply_cap](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_supply_cap)|
| icrc7:max_update_batch_size<br>(optional)  | -   |icrc7_supply_cap : () -> (opt nat) query;<br>[icrc7_supply_cap](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_supply_cap)|
| icrc7:max_query_batch_size<br>(optional)  | -   |icrc7_supply_cap : () -> (opt nat) query;<br>[icrc7_supply_cap](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_supply_cap)|
| icrc7:default_take_value<br>(optional)  | -   |icrc7_supply_cap : () -> (opt nat) query;<br>[icrc7_supply_cap](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_supply_cap)|
| icrc7:max_take_value<br>(optional)  | -   |icrc7_supply_cap : () -> (opt nat) query;<br>[icrc7_supply_cap](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_supply_cap)|
| icrc7:max_memo_size<br>(optional)  | -   |icrc7_supply_cap : () -> (opt nat) query;<br>[icrc7_supply_cap](https://github.com/dfinity/ICRC/blob/icrc7-wg-draft/ICRCs/ICRC-7/ICRC-7.md#icrc7_supply_cap)|


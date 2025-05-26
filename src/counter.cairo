#[starknet::interface]
pub trait Icounter<TContractState>{
    // Increment the counter
    fn increment(ref self: TContractState) -> u32;
    // Decrement the counter
    fn decrement(ref self: TContractState) -> u32;
    // Get the current value of the counter
    fn get_value(self: @TContractState) -> u32;
}

#[starknet::contract]
mod Counter {
    use starknet::storage::{StorageMapWriteAccess, StorageMapReadAccess};
    use starknet::{ContractAddress};
}

#[storage]
struct Storage {
    value: u32,
}

#[abi(embed_v0)]
impl Counter of super::Icounter<ContractState> {
    fn increment(ref self: ContractState) -> u32 {
        self.value.write(self.value.read() + 1);
        self.value.read()
    }

    fn decrement(ref self: ContractState) -> u32 {
        self.value.write(self.value.read() - 1);
        self.value.read()
    }

    fn get_value(self: @ContractState) -> u32 {
        self.value.read()
    }
}

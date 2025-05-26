use starknet::ContractAddress;

#[starknet::interface]
pub trait IRewardsPoint<TContractState> {
    // Add points to a user
    fn add_points(ref self: TContractState, user_address: ContractAddress, points: u16) -> bool;
    // Redeem points
    fn redeem_points(ref self: TContractState, points: u16) -> bool;
    // Check user points balance
    fn check_points(self: @TContractState, user_address: ContractAddress) -> u16;
    // Transfer points from one user to another
    fn transfer_points(ref self: TContractState, to_address: ContractAddress, points: u16) -> bool;
}

#[starknet::contract]
mod RewardsPoint {
    use starknet::event::EventEmitter;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress};
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        points: Map<ContractAddress, u16>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        PointsAdded: PointsAdded,
        PointsRedeemed: PointsRedeemed,
        PointsTransferred: PointsTransferred,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PointsAdded {
        #[key]
        user_address: ContractAddress,
        points: u16,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PointsRedeemed {
        #[key]
        user_address: ContractAddress,
        points: u16,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PointsTransferred {
        #[key]
        from_address: ContractAddress,
        #[key]
        to_address: ContractAddress,
        points: u16,
    }

    #[abi(embed_v0)]
    impl RewardsPoint of super::IRewardsPoint<ContractState> {
        fn add_points(ref self: ContractState, user_address: ContractAddress, points: u16) -> bool {
            let current_points = self.points.read(user_address);
            let new_points = current_points + points;
            self.points.write(user_address, new_points);
            // Emit event for points added - should emit the points added, not total balance
            self.emit(PointsAdded {user_address, points});
            true
        }

        fn redeem_points(ref self: ContractState, points: u16) -> bool {
            let user_address = get_caller_address();
            let current_points = self.points.read(user_address);
            assert(current_points >= points, 'Insufficient points');
            self.points.write(user_address, current_points - points);
            // Emit event for points redeemed - should emit the points redeemed, not remaining balance
            self.emit(PointsRedeemed {user_address, points});
            true
        }

        fn check_points(self: @ContractState, user_address: ContractAddress) -> u16 {
            self.points.read(user_address)
        }

        fn transfer_points(ref self: ContractState, to_address: ContractAddress, points: u16) -> bool {
            let from_address = get_caller_address();
            assert(from_address != to_address, 'Cannot transfer points to self');
            assert(points > 0, 'Points must be greater than 0');
            let from_points = self.points.read(from_address);
            assert(from_points >= points, 'Insufficient points');
            let to_points = self.points.read(to_address);
            self.points.write(from_address, from_points - points);
            self.points.write(to_address, to_points + points);
            // Emit event for points transferred
            self.emit(PointsTransferred {from_address, to_address, points});
            true
        }
    }
}
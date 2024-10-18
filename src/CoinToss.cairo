#[starknet::interface]
trait ICoinToss<TContractState> {
    fn toss(ref self: TContractState, player1_choice: u8, player2_choice: u8) -> u8; // 0 = draw, 1 = player1 wins, 2 = player2 wins
    fn get_result(ref self: TContractState) -> (u8, u8, u8); // Returns choices and winner
}

#[starknet::contract]
mod CoinToss {
    #[storage]
    struct Storage {
        // Keep track of players' choices
        player1_choice: u8,
        player2_choice: u8,
        // Track the winner
        winner: u8, // 0 = no winner, 1 = player 1, 2 = player 2
        last_toss: u8, // Simulate randomness
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        // Initialize choices and winner
        self.player1_choice.write(0);
        self.player2_choice.write(0);
        self.winner.write(0);
        self.last_toss.write(0);
    }

    #[abi(embed_v0)]
    impl CoinToss of super::ICoinToss<ContractState> {
        fn toss(ref self: ContractState, player1_choice: u8, player2_choice: u8) -> u8 {
            // Choices: 0 = Heads, 1 = Tails
            self.player1_choice.write(player1_choice);
            self.player2_choice.write(player2_choice);

            // Simulate a coin toss by flipping the last_toss value
            let new_toss = (self.last_toss.read() + 1) % 2;
            self.last_toss.write(new_toss); // Update last toss value

            // Determine the winner based on players' choices and the coin toss result
            if player1_choice == new_toss && player2_choice != new_toss {
                self.winner.write(1); // Player 1 wins
                return 1;
            } else if player2_choice == new_toss && player1_choice != new_toss {
                self.winner.write(2); // Player 2 wins
                return 2;
            } else {
                self.winner.write(0); // Draw
                return 0;
            }
        }

        // Function to get the result of the toss
        fn get_result(ref self: ContractState) -> (u8, u8, u8) {
            // Returns the choices and the winner
            let player1_choice = self.player1_choice.read();
            let player2_choice = self.player2_choice.read();
            let winner = self.winner.read();
            (player1_choice, player2_choice, winner)
        }
    }
}
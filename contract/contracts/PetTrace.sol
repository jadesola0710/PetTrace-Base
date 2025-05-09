// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}

contract PetTrace {
    struct Pet {
        uint256 id;
        address payable owner;
        string name;
        string breed;
        string gender;
        uint256 sizeCm;
        uint256 ageMonths;
        string dateTimeLost;
        string description;
        string imageUrl;
        string lastSeenLocation;
        string contactName;
        string contactPhone;
        string contactEmail;
        uint256 ethBounty;
        uint256 usdcBounty;
        bool isFound;
        bool ownerConfirmed;
        bool finderConfirmed;
        address finder;
    }

    // Base Sepolia Testnet USDC address
    address public constant USDC_ADDRESS =
        0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    uint256 public nextPetId;
    mapping(uint256 => Pet) public pets;
    mapping(uint256 => uint256) public escrowedUSDC;

    event PetPosted(uint256 indexed petId, address indexed owner);
    event PetFound(uint256 indexed petId, address indexed finder);
    event BountyClaimed(
        uint256 indexed petId,
        address indexed finder,
        uint256 ethAmount,
        uint256 usdcAmount
    );
    event ConfirmationAdded(
        uint256 indexed petId,
        address indexed confirmer,
        bool isOwner
    );
    event BountyRefunded(
        uint256 indexed petId,
        address indexed owner,
        uint256 ethAmount,
        uint256 usdcAmount
    );

    function postLostPet(
        string calldata name,
        string calldata breed,
        string calldata gender,
        uint256 sizeCm,
        uint256 ageMonths,
        string calldata dateTimeLost,
        string calldata description,
        string calldata imageUrl,
        string calldata lastSeenLocation,
        string calldata contactName,
        string calldata contactPhone,
        string calldata contactEmail,
        uint256 usdcBounty
    ) external payable {
        require(
            msg.value > 0 || usdcBounty > 0,
            "Either ETH or USDC bounty required"
        );
        require(bytes(name).length > 0, "Pet name required");
        require(
            bytes(lastSeenLocation).length > 0,
            "Last seen location required"
        );

        if (usdcBounty > 0) {
            require(
                IERC20(USDC_ADDRESS).transferFrom(
                    msg.sender,
                    address(this),
                    usdcBounty
                ),
                "USDC transfer failed. Check approval and balance."
            );
            escrowedUSDC[nextPetId] = usdcBounty;
        }

        pets[nextPetId] = Pet({
            id: nextPetId,
            owner: payable(msg.sender),
            name: name,
            breed: breed,
            gender: gender,
            sizeCm: sizeCm,
            ageMonths: ageMonths,
            dateTimeLost: dateTimeLost,
            description: description,
            imageUrl: imageUrl,
            lastSeenLocation: lastSeenLocation,
            contactName: contactName,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            ethBounty: msg.value,
            usdcBounty: usdcBounty,
            isFound: false,
            ownerConfirmed: false,
            finderConfirmed: false,
            finder: address(0)
        });

        emit PetPosted(nextPetId, msg.sender);
        nextPetId++;
    }

    function markAsFound(uint256 petId) external {
        Pet storage pet = pets[petId];
        require(!pet.isFound, "Already found");
        require(pet.owner != address(0), "Pet does not exist");
        require(msg.sender != pet.owner, "Owner cannot be finder");

        pet.finder = msg.sender;
        pet.finderConfirmed = true;

        if (pet.ownerConfirmed) {
            pet.isFound = true;
            emit PetFound(petId, msg.sender);
        }

        emit ConfirmationAdded(petId, msg.sender, false);
    }

    function confirmFoundByOwner(uint256 petId) external {
        Pet storage pet = pets[petId];
        require(!pet.isFound, "Already found");
        require(msg.sender == pet.owner, "Only owner can confirm");
        require(pet.finder != address(0), "No finder yet");

        pet.ownerConfirmed = true;

        if (pet.finderConfirmed) {
            pet.isFound = true;
            emit PetFound(petId, pet.finder);
        }

        emit ConfirmationAdded(petId, msg.sender, true);
    }

    function claimBounty(uint256 petId) external {
        Pet storage pet = pets[petId];
        require(pet.isFound, "Pet not confirmed as found by both parties");
        require(msg.sender == pet.finder, "Not the finder");
        require(pet.ethBounty > 0 || pet.usdcBounty > 0, "No bounty to claim");

        uint256 ethAmount = pet.ethBounty;
        uint256 usdcAmount = pet.usdcBounty;

        // Reset bounties
        pet.ethBounty = 0;
        pet.usdcBounty = 0;
        escrowedUSDC[petId] = 0;

        // Transfer ETH bounty if exists
        if (ethAmount > 0) {
            payable(msg.sender).transfer(ethAmount);
        }

        // Transfer USDC bounty if exists
        if (usdcAmount > 0) {
            require(
                IERC20(USDC_ADDRESS).transfer(msg.sender, usdcAmount),
                "USDC transfer failed"
            );
        }

        emit BountyClaimed(petId, msg.sender, ethAmount, usdcAmount);
    }

    function cancelAndRefund(uint256 petId) external {
        Pet storage pet = pets[petId];
        require(msg.sender == pet.owner, "Only owner can cancel");
        require(!pet.isFound, "Pet already found");
        require(pet.finder == address(0), "Finder already assigned");

        uint256 ethAmount = pet.ethBounty;
        uint256 usdcAmount = pet.usdcBounty;

        // Reset bounties
        pet.ethBounty = 0;
        pet.usdcBounty = 0;
        escrowedUSDC[petId] = 0;

        // Refund ETH bounty if exists
        if (ethAmount > 0) {
            payable(msg.sender).transfer(ethAmount);
        }

        // Refund USDC bounty if exists
        if (usdcAmount > 0) {
            require(
                IERC20(USDC_ADDRESS).transfer(msg.sender, usdcAmount),
                "USDC refund failed"
            );
        }

        emit BountyRefunded(petId, msg.sender, ethAmount, usdcAmount);
    }

    // Helper function to check USDC balance in contract
    function getEscrowedUSDCBalance(
        uint256 petId
    ) external view returns (uint256) {
        return escrowedUSDC[petId];
    }

    // Helper function to check contract's USDC balance
    function getContractUSDCBalance() external view returns (uint256) {
        return IERC20(USDC_ADDRESS).balanceOf(address(this));
    }

    // Returns both the IDs and full Pet data of all lost pets
    function getAllLostPets()
        public
        view
        returns (uint256[] memory, Pet[] memory)
    {
        uint256 count = 0;

        // First count how many pets are lost
        for (uint256 i = 0; i < nextPetId; i++) {
            if (!pets[i].isFound) {
                count++;
            }
        }

        // Initialize arrays
        uint256[] memory petIds = new uint256[](count);
        Pet[] memory lostPets = new Pet[](count);
        uint256 index = 0;

        // Populate arrays
        for (uint256 i = 0; i < nextPetId; i++) {
            if (!pets[i].isFound) {
                petIds[index] = i; // The pet ID (key in mapping)
                lostPets[index] = pets[i];
                index++;
            }
        }

        return (petIds, lostPets);
    }

    function getLostPetsCount() external view returns (uint256) {
        uint256 counter = 0;
        for (uint256 i = 0; i < nextPetId; i++) {
            if (!pets[i].isFound) {
                counter++;
            }
        }
        return counter;
    }

    function getPetDetails(
        uint256 petId
    )
        public
        view
        returns (
            uint256 id,
            address owner,
            string memory name,
            string memory breed,
            string memory gender,
            uint256 sizeCm,
            uint256 ageMonths,
            string memory dateTimeLost,
            string memory description,
            string memory imageUrl,
            string memory lastSeenLocation,
            string memory contactName,
            string memory contactPhone,
            string memory contactEmail,
            uint256 ethBounty,
            uint256 usdcBounty,
            bool isFound,
            bool ownerConfirmed,
            bool finderConfirmed,
            address finder,
            uint256 escrowedUSDCAmount
        )
    {
        require(petId < nextPetId, "Pet does not exist");
        Pet storage pet = pets[petId];
        return (
            pet.id,
            pet.owner,
            pet.name,
            pet.breed,
            pet.gender,
            pet.sizeCm,
            pet.ageMonths,
            pet.dateTimeLost,
            pet.description,
            pet.imageUrl,
            pet.lastSeenLocation,
            pet.contactName,
            pet.contactPhone,
            pet.contactEmail,
            pet.ethBounty,
            pet.usdcBounty,
            pet.isFound,
            pet.ownerConfirmed,
            pet.finderConfirmed,
            pet.finder,
            escrowedUSDC[petId]
        );
    }
}

pragma solidity ^0.4.18;

import './common/SafeMath.sol';
import './common/Destructible.sol';
import './Credit.sol';

contract PeerToPeerLending is Destructible {
    // Using SafeMath for our calculations with uints.
    using SafeMath for uint;

    // User structure
    struct User {
        // Is the user currently credited.
        bool credited;

        // The adress of the active credit.
        address activeCredit;

        // Is the user marked as fraudlent.
        bool fraudStatus;

        // All user credits.
        address[] allCredits;
    }

    // We store all users in a mapping.
    mapping(address => User) public users;

    // Array of all credits adresses.
    address[] public credits;

    event LogCreditCreated(address indexed _address, address indexed _borrower, uint indexed timestamp);
    event LogCreditStateChanged(address indexed _address, Credit.State indexed state, uint indexed timestamp);
    event LogCreditActiveChanged(address indexed _address, bool indexed active, uint indexed timestamp);
    event LogUserSetFraud(address indexed _address, bool fraudStatus, uint timestamp);

    function PeerToPeerLending() public {

    }

    function applyForCredit(uint requestedAmount, uint repaymentsCount, uint interest, bytes32 creditDescription) public returns(address _credit) {
        // The user should not have been credited;
        require(users[msg.sender].credited == false);

        // THe user should not be marked as fraudlent.
        require(users[msg.sender].fraudStatus == false);

        // Assert there is no active credit for the user.
        assert(users[msg.sender].activeCredit == 0);

        // Mark the user as credited. Prevent from reentrancy.
        users[msg.sender].credited = true;

        // Create a new credit contract with the given parameters.
        Credit credit = new Credit(requestedAmount, repaymentsCount, interest, creditDescription);

        // Set the user's active credit contract.
        users[msg.sender].activeCredit = credit;

        // Add the credit contract to our list with contracts.
        credits.push(credit);

        // Add the credit to the user's profile.
        users[msg.sender].allCredits.push(credit);

        // Log the credit creation event.
        LogCreditCreated(credit, msg.sender, block.timestamp);

        return credit;
    }

    function getCredits() public view returns (address[]) {
        return credits;
    }

    function getUserCredits() public view returns (address[]) {
        return users[msg.sender].allCredits;
    }

    function setFraudStatus(address _borrower) external returns (bool) {
        // Update user fraud status.
        users[_borrower].fraudStatus = true;

        // Log fraud status.
        LogUserSetFraud(_borrower, users[_borrower].fraudStatus, block.timestamp);

        return users[_borrower].fraudStatus;
    }

    function changeCreditState (Credit _credit, Credit.State state) public onlyOwner {
        // Call credit contract changeStage.
        Credit credit = Credit(_credit);
        credit.changeState(state);

        // Log state change.
        LogCreditStateChanged(credit, state, block.timestamp);
    }

    function changeCreditState (Credit _credit) public onlyOwner {
        // Call credit contract toggleActive method.
        Credit credit = Credit(_credit);
        bool active = credit.toggleActive();

        // Log state change.
        LogCreditActiveChanged(credit, active, block.timestamp);
    }
}
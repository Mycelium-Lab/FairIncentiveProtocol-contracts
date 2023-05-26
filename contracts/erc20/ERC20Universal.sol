// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ERC20Universal is ERC20, Ownable, Pausable {
    enum Type {
        Capped,
        Fixed,
        Unlimited
    }
    struct AllowedUser {
        address userAddress;
        bool allowed;
    }
    Type public supplyType; 
    bool private isPausable;
    bool private isBurnable;
    bool private isBlacklist;
    bool private isRecoverable;

    uint256 private _cap;

    address private fairProtocolManager;
    mapping (address => bool) public allowedUsers;
    mapping (address => uint256) allowedUsersID;
    uint256 public lastAllowedUserID;
    AllowedUser[] public allowedUsersList;
    mapping (address => bool) public blacklist;
    mapping (address => uint256) blacklistID;
    mapping (address => uint256) public blacklistTime;
    address[] public blacklistUsers;
    uint256 public blacklistLastID;

    constructor(
        string memory _name, 
        string memory _symbol,
        Type _supplyType,
        uint256 cap_,
        uint256 _initialSupply,
        bool _isPausable,
        bool _isBurnable,
        bool _isBlacklist,
        bool _isRecoverable,
        address _fairProtocolManager
    ) ERC20(_name, _symbol) {
        if (_supplyType == Type.Capped) {
            require(cap_ > 0, "ERC20: Cap is 0");
            _cap = cap_;
        }
        if (_supplyType == Type.Fixed) {
            require(_initialSupply != 0, "ERC20: Initial supply is 0");
        }
        fairProtocolManager = _fairProtocolManager;
        supplyType = _supplyType;
        isPausable = _isPausable;
        isBurnable = _isBurnable;
        isBlacklist = _isBlacklist;
        isRecoverable = _isRecoverable;
        if (_initialSupply != 0 || _supplyType == Type.Fixed) {
            _mint(owner(), _initialSupply);
            increaseAllowance(fairProtocolManager, _initialSupply);
        }
        blacklistUsers.push(address(0));
        blacklistLastID = 0;
        allowedUsersList.push(AllowedUser(address(0), false));
    }

    function cap() public view virtual returns (uint256) {
        require(supplyType == Type.Capped, "ERC20: Not capped contract");
        return _cap;
    }

    function mint(uint256 amount) public rolesControl {
        require(supplyType != Type.Fixed, "ERC20: Not allowed to mint");
        if (isPausable) {
            require(!paused(), "ERC20: Token transfer while paused");
        }
        if (supplyType == Type.Capped) {
            require(ERC20.totalSupply() + amount <= cap(), "ERC20: Cap exceeded");
        }
        _mint(owner(), amount);
        increaseAllowance(fairProtocolManager, amount);
    }

   function burn(uint256 amount) public virtual isUserInBlacklist(msg.sender) {
        require(isBurnable, "ERC20: Not allowed to burn");
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual isUserInBlacklist(msg.sender) isUserInBlacklist(account) {
        require(isBurnable, "ERC20: Not allowed to burn");
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override isUserInBlacklist(from) isUserInBlacklist(to) {
        super._beforeTokenTransfer(from, to, amount);

        if (isPausable) {
            require(!paused(), "ERC20: Token transfer while paused");
        }
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) public virtual rolesControl {
        require(isRecoverable, "ERC20: Contract is not recoverable");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    function pause() external rolesControl {
        require(isPausable, "ERC20: Not pausable");
        _pause();
    }

    function unpause() external rolesControl {
        require(isPausable, "ERC20: Not pausable");
        _unpause();
    }

    function setAllowedUser(address user) external onlyOwner {
        allowedUsers[user] = true;
        uint256 allowedUserID = allowedUsersID[user];
        if (allowedUserID == 0) {
            allowedUsersList.push(AllowedUser(user, true));
            uint256 _lastUserID = allowedUsersList.length - 1;
            lastAllowedUserID = _lastUserID;
            allowedUsersID[user] = _lastUserID;
        } else {
            allowedUsersList[allowedUserID].allowed = true;
        }
    }

    function deleteAllowedUser(address user) external onlyOwner {
        allowedUsers[user] = false;
        allowedUsersList[allowedUsersID[user]].allowed = false;
    }

    function setBlacklistUsers(address[] memory users) external rolesControl {
        require(isBlacklist, "ERC20: Not blacklist");
        for (uint256 i; i < users.length; i++) {
            blacklist[users[i]] = true;
            if (blacklistID[users[i]] == 0) {
                uint256 ID = blacklistUsers.length;
                blacklistUsers.push(users[i]);
                blacklistID[users[i]] = ID; 
                blacklistLastID = ID;
            }
            blacklistTime[users[i]] = block.timestamp;
        }
    }

    function deleteBlacklistUsers(address[] memory users) external rolesControl {
        require(isBlacklist, "ERC20: Not blacklist");
        for (uint256 i; i < users.length; i++) {
            blacklist[users[i]] = false;
            uint256 length = blacklistUsers.length;
            uint256 ID = blacklistID[users[i]];
            //if last -> just delete
            if (ID == length - 1) {
                blacklistUsers[ID] = address(0);
            } else {
            //if not last -> change places with last and pop
                address lastUser = blacklistUsers[length - 1];
                blacklistUsers[ID] = lastUser;
                blacklistID[lastUser] = ID;
                blacklistUsers.pop();
            }
            blacklistID[users[i]] = 0;
            blacklistLastID -= 1;
        }
    }

    modifier rolesControl() {
        require(msg.sender == owner() || allowedUsers[msg.sender], "ERC20: Not allowed wallet");
        _;
    }

    modifier isUserInBlacklist(address user) {
        require(!blacklist[user], "ERC20: User in blacklist");
        _;
    }

}

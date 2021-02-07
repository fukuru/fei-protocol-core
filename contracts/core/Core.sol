pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Permissions.sol";
import "./ICore.sol";
import "../token/Fei.sol";
import "../dao/Tribe.sol";

/// @title ICore implementation
/// @author Fei Protocol
contract Core is ICore, Permissions {
    IFei public override fei;
    IERC20 public override tribe;

    address public override genesisGroup;
    bool public override hasGenesisGroupCompleted;

    constructor() public {
        _setupGovernor(msg.sender);
    }

    function init() external onlyGovernor {
        Fei _fei = new Fei(address(this));
        _setFei(address(_fei));

        Tribe _tribe = new Tribe(address(this), msg.sender);
        _setTribe(address(_tribe));
    }

    function setFei(address token) external override onlyGovernor {
        _setFei(token);
    }

    function setTribe(address token) external override onlyGovernor {
        _setTribe(token);
    }

    function setGenesisGroup(address _genesisGroup)
        external
        override
        onlyGovernor
    {
        genesisGroup = _genesisGroup;
        emit GenesisGroupUpdate(_genesisGroup);
    }

    function allocateTribe(address to, uint256 amount)
        external
        override
        onlyGovernor
    {
        IERC20 _tribe = tribe;
        require(
            _tribe.balanceOf(address(this)) >= amount,
            "Core: Not enough Tribe"
        );

        _tribe.transfer(to, amount);

        emit TribeAllocation(to, amount);
    }

    function completeGenesisGroup() external override {
        require(
            !hasGenesisGroupCompleted,
            "Core: Genesis Group already complete"
        );
        require(
            msg.sender == genesisGroup,
            "Core: Caller is not Genesis Group"
        );

        hasGenesisGroupCompleted = true;

        // solhint-disable-next-line not-rely-on-time
        emit GenesisPeriodComplete(block.timestamp);
    }

    function _setFei(address token) internal {
        fei = IFei(token);
        emit FeiUpdate(token);
    }

    function _setTribe(address token) internal {
        tribe = IERC20(token);
        emit TribeUpdate(token);
    }
}

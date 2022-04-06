pragma solidity ^0.8.0;
pragma abicoder v2;

interface xWSFInterface {

    function transferXWSFToHolder(uint256 amount, address recipient) external ;

    function increaseBalance(uint256 amount, address recipient) external ;

    function decreaseBalance(uint256 amount, address recipient) external ;

    function resetBalance(address recipient) external ;

    function getPercentOf(address recipient) external view returns (uint256) ;

    function updateNewBalance(uint256 amount, address recipient) external ;

    function xWSFBalanceOf(address account) external view returns (uint256);

}

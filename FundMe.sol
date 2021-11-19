pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract FundMe {
    
    address public owner;
    address[] public funders;
    
    mapping(address => uint256) public addressToFund;
    
    constructor() {
        
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        
        require(msg.sender == owner);
        _;
    }
    
    function fund() public payable {
        
        uint256 minAmount = 50 * 10 ** 18;
        
        require(getRate(msg.value) >= minAmount, 'You need more money');
        
        addressToFund[msg.sender] += msg.value;
        
        funders.push(msg.sender);
    }
    
    function getPrice() public view returns(uint256) {
        
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        
        return uint256(answer * 10000000000);
    }
    
    function getRate(uint256 _amountUsd) public view returns(uint256) {
        
        uint256 price = getPrice();
        uint256 priceUsd = (_amountUsd * price) / 1000000000000;
        
        return priceUsd;
    }
    
    function withdraw() payable public onlyOwner {
        
        payable(msg.sender).transfer(address(this).balance);
        
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            
            address funder = funders[funderIndex];
            addressToFund[funder] = 0;
        }
        
        funders = new address[](0);
    }
    
    
}

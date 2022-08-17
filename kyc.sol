pragma solidity ^0.5.0;

contract kyc1{
    struct customerDetails {
        string name;
        uint aadhaarNo;
        string panNo;
        bool verification;
        address addingMember;
        uint custId;
    }

    struct memberDetails {
        string memberName;
        address account;
        uint regNo;
        uint rating;
    }
    
    uint counter =1;
    uint counter1=1001;

    event showCust(string name, uint aadhaarNo, string panNo, bool verification);
    event addMem(uint regNo);
    event getId(uint id);
    event verifiedmsg(bool );
    customerDetails[] public cust_details;

    mapping(uint=>customerDetails)  public customerList;
    mapping(address=>memberDetails)public memberList;

    modifier byAddingMember(uint reqid, address memaddr){
        require(memaddr == customerList[reqid].addingMember);
        _;
    }
    
    modifier memberexist(address member){
        require (memberList[member].account!=member,"");
        _;
    }

    function addMembers(string memory memberName, address enode) public memberexist(enode) {
    //   this function will add new mebmer in the ethereum network
    //   this function can be invoked only by other member on the network
    //    update regNo
    //   update member details in the list
    memberList[enode].memberName=memberName;
    memberList[enode].account=enode;
    memberList[enode].regNo=counter1;
    memberList[enode].rating=0;
    counter1=counter1+1;
    emit addMem(memberList[enode].regNo);
    }
    
    function addCustomer(string memory name, uint aadhaarNo, string memory panNo)public {
        // this function can be invoked by any member of the network
        // updates the customer list
        
        customerDetails memory custDetails;
        custDetails.name = name;
        custDetails.aadhaarNo = aadhaarNo;
        custDetails.panNo = panNo;
        custDetails.addingMember = msg.sender;
        custDetails.custId = counter;
        counter++;
        customerList[custDetails.custId]=custDetails;
        emit getId(custDetails.custId);
    }
    function getCustomer(uint custId)public view returns(string memory , uint , string memory , bool ){
        // displays customer list in the network
        if(custId>=counter){
            return ("0",0,"0",false);
        }
        return (customerList[custId].name, customerList[custId].aadhaarNo,
        customerList[custId].panNo, customerList[custId].verification);
        
    }
    
    
    function verifyCustomer(uint custId)public byAddingMember(custId, msg.sender) returns(bool ){
        // verifies the kyc details of the customer
        // can be verified only by that member who has added that customer
        // update the corresponding rating counter for the member
        
        customerList[custId].verification = true;
        memberList[msg.sender].rating+=1;
        emit verifiedmsg(true);
    } 
    function Unverified_custlist() public view  returns (string memory){
        uint i ;
        bool isData = true;
        uint maxlength = 100000;
        bytes memory reversed = new bytes(maxlength);
        for(uint k=1;k<=counter;k++){
        if(customerList[k].addingMember==msg.sender && customerList[k].verification==false){
            uint v=k;
            while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + uint8(remainder));
            isData=false;
        }
            reversed[i++]=",";
            }
        }
        if(isData){
            return "No Data";
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }

        string memory str = string(s);
        bytes memory s1=bytes(str);
        bytes memory result=new bytes(s.length-2);
        for (uint m=2; m<s.length; m++){
            result[m-2]=s1[m];
        }
        str=string(result);
        
        return str;
    }
    function aadhaarVerify(uint aadhaarNo) public view returns(bool){
        for(uint i=0; i<counter; i++){
            if(customerList[i].aadhaarNo==aadhaarNo){
                return false;
            }
        }
        return true;
    }
    function panNoVerify(string  memory panNo) public view returns(bool){
        for(uint i=0; i<counter; i++){
            // string memory temp;
            // temp=customerList[i].panNo;
            if(keccak256(abi.encodePacked(customerList[i].panNo))==keccak256(abi.encodePacked(panNo))){
                return false;
            }
        }
        return true;
    }
    function nodeVerify(address  node) public view returns(bool){
        if(memberList[node].account==node){
            return false;
        }
        return true;
    }
    function loginMember(string memory name,address memaccount)public view returns(bool){
        if(keccak256(abi.encodePacked(memberList[memaccount].memberName))==keccak256(abi.encodePacked(name))){
            return true;
        }
        return false;
    }
    function get_rating() public view returns(uint){
        return memberList[msg.sender].rating;
    }
}

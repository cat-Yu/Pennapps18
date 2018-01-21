pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with


contract DB {
    
    struct UserInfo {
        int  score;
        Request[]   req_history ;
    }

    struct Request{
        uint  amount;
        uint  expire_ts;
        bool  offered;
        uint  amount_return;
        address lender;
        address borrower;
        bool accepted;
        bool returned;
    }
    
    mapping (address => UserInfo) public userinfo;
    Request[] public pool;

    function myscore() public view returns (uint){
        UserInfo storage myinfo = userinfo[msg.sender];
        return myinfo.req_history.length;
    }
    
    function submit_request(uint amount, uint expire) public{
        Request memory req;
        req.amount = amount;
        req.expire_ts = expire;
        req.borrower = msg.sender;
        userinfo[msg.sender].req_history.push(req);
        Request storage new_req = userinfo[msg.sender].req_history
        [userinfo[msg.sender].req_history.length - 1];
        pool.push(new_req);
    }
    

    function submit_offer(uint order_idx, uint amount) payable public 
    returns (bool){

        bool success;
        
        if(msg.value != amount || order_idx >= pool.length){
            success = false;
        }
        else{
            Request storage req = pool[order_idx];
            
            if((!req.offered) || req.amount_return > amount){
                success = true;
                req.offered = true;
                req.amount_return = amount;
                req.lender.transfer(req.amount);
                req.lender = msg.sender;
            }
            else{
                success = false;
            }
        }
        
        if(!success){
            msg.sender.transfer(msg.value);
        }
        
        return success;
    }
    
    function remove_from_pool(uint order_idx) {
        uint last_idx = pool.length - 1;
        if(last_idx >= 0){
            pool[order_idx] = pool[last_idx];
            delete pool[last_idx];
            pool.length --;
        }
    }
    
    function accept_offer(uint order_idx) public returns (bool){
        if (order_idx >= pool.length){
            return false;
        }
        Request storage req = pool[order_idx];
        if (req.borrower != msg.sender || req.accepted || (!req.offered)){
            return false;
        }
        
        msg.sender.transfer(req.amount);
        
        remove_from_pool(order_idx);
        
        return true;
    }
    
    
}



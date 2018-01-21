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
    }
    
    mapping (address => UserInfo) public userinfo;
    Request[] public pool;

    function myscore() public returns (uint){
        UserInfo myinfo = userinfo[msg.sender];
        return myinfo.req_history.length;
    }
    
    function submit_request(uint amount, uint expire){
        Request memory req;
        req.amount = amount;
        req.expire_ts = expire;
        pool.push(req);
        Request storage new_req = pool[pool.length - 1];
        userinfo[msg.sender].req_history.push(new_req);
    }
    

    function submit_offer(uint order_idx, uint amount) payable returns (bool){

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
                req.lender.send(req.amount);
                req.lender = msg.sender;
            }
            else{
                success = false;
            }
        }
        
        if(!success){
            msg.sender.send(msg.value);
        }
        
        return success;
    }
    
}



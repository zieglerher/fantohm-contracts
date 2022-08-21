// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;
pragma abicoder v2;

interface IOwnable {
    function policy() external view returns (address);

    function renounceManagement() external;

    function pushManagement( address newOwner_ ) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyPolicy() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is IERC20 {

    using SafeMath for uint256;

    // TODO comment actual hash value.
    bytes32 constant private ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256( "ERC20Token" );

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;

    string internal _symbol;

    uint8 internal _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account_, uint256 ammount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address( this ), account_, ammount_);
        _totalSupply = _totalSupply.add(ammount_);
        _balances[account_] = _balances[account_].add(ammount_);
        emit Transfer(address( this ), account_, ammount_);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
}

interface IERC2612Permit {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
}

library Counters {
    using SafeMath for uint256;

    struct Counter {

        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

abstract contract ERC20Permit is ERC20, IERC2612Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")), // Version
                chainID,
                address(this)
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "Permit: expired deadline");

        bytes32 hashStruct =
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner].current(), deadline));

        bytes32 _hash = keccak256(abi.encodePacked(uint16(0x1901), DOMAIN_SEPARATOR, hashStruct));

        address signer = ecrecover(_hash, v, r, s);
        require(signer != address(0) && signer == owner, "ZeroSwapPermit: Invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, amount);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library FullMath {
    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
    }
}

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    function decode112with18(uq112x112 memory self) internal pure returns (uint) {

        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface AggregatorV3Interface {

    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

interface ITreasury {
    function deposit( uint _amount, address _token, uint _profit ) external returns ( uint send_ );
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
    function mintRewards( address _recipient, uint _amount ) external;
}

interface IStaking {
    function stake( uint _amount, address _recipient ) external returns ( bool );
}

interface IStakingHelper {
    function stake( uint _amount, address _recipient ) external;
}

interface IMintable {
    function mint(address to, uint256 amount) external;
}

interface IBurnable {
    function burn(uint256 amount) external;
}

interface IUsdbMinter {
    function getMarketPrice() external view returns (uint);
}

interface IAsset {
    // solhint-disable-previous-line no-empty-blocks
}

interface IVault {

    /**
     * @dev Called by users to join a Pool, which transfers tokens from `sender` into the Pool's balance. This will
     * trigger custom Pool behavior, which will typically grant something in return to `recipient` - often tokenized
     * Pool shares.
     *
     * If the caller is not `sender`, it must be an authorized relayer for them.
     *
     * The `assets` and `maxAmountsIn` arrays must have the same length, and each entry indicates the maximum amount
     * to send for each asset. The amounts to send are decided by the Pool and not the Vault: it just enforces
     * these maximums.
     *
     * If joining a Pool that holds WETH, it is possible to send ETH directly: the Vault will do the wrapping. To enable
     * this mechanism, the IAsset sentinel value (the zero address) must be passed in the `assets` array instead of the
     * WETH address. Note that it is not possible to combine ETH and WETH in the same join. Any excess ETH will be sent
     * back to the caller (not the sender, which is important for relayers).
     *
     * `assets` must have the same length and order as the array returned by `getPoolTokens`. This prevents issues when
     * interacting with Pools that register and deregister tokens frequently. If sending ETH however, the array must be
     * sorted *before* replacing the WETH address with the ETH sentinel value (the zero address), which means the final
     * `assets` array might not be sorted. Pools with no registered tokens cannot be joined.
     *
     * If `fromInternalBalance` is true, the caller's Internal Balance will be preferred: ERC20 transfers will only
     * be made for the difference between the requested amount and Internal Balance (if any). Note that ETH cannot be
     * withdrawn from Internal Balance: attempting to do so will trigger a revert.
     *
     * This causes the Vault to call the `IBasePool.onJoinPool` hook on the Pool's contract, where Pools implement
     * their own custom logic. This typically requires additional information from the user (such as the expected number
     * of Pool shares). This can be encoded in the `userData` argument, which is ignored by the Vault and passed
     * directly to the Pool's contract, as is `recipient`.
     *
     * Emits a `PoolBalanceChanged` event.
     */
    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        IAsset[] assets;
        uint[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    /**
     * @dev Called by users to exit a Pool, which transfers tokens from the Pool's balance to `recipient`. This will
     * trigger custom Pool behavior, which will typically ask for something in return from `sender` - often tokenized
     * Pool shares. The amount of tokens that can be withdrawn is limited by the Pool's `cash` balance (see
     * `getPoolTokenInfo`).
     *
     * If the caller is not `sender`, it must be an authorized relayer for them.
     *
     * The `tokens` and `minAmountsOut` arrays must have the same length, and each entry in these indicates the minimum
     * token amount to receive for each token contract. The amounts to send are decided by the Pool and not the Vault:
     * it just enforces these minimums.
     *
     * If exiting a Pool that holds WETH, it is possible to receive ETH directly: the Vault will do the unwrapping. To
     * enable this mechanism, the IAsset sentinel value (the zero address) must be passed in the `assets` array instead
     * of the WETH address. Note that it is not possible to combine ETH and WETH in the same exit.
     *
     * `assets` must have the same length and order as the array returned by `getPoolTokens`. This prevents issues when
     * interacting with Pools that register and deregister tokens frequently. If receiving ETH however, the array must
     * be sorted *before* replacing the WETH address with the ETH sentinel value (the zero address), which means the
     * final `assets` array might not be sorted. Pools with no registered tokens cannot be exited.
     *
     * If `toInternalBalance` is true, the tokens will be deposited to `recipient`'s Internal Balance. Otherwise,
     * an ERC20 transfer will be performed. Note that ETH cannot be deposited to Internal Balance: attempting to
     * do so will trigger a revert.
     *
     * `minAmountsOut` is the minimum amount of tokens the user expects to get out of the Pool, for each token in the
     * `tokens` array. This array must match the Pool's registered tokens.
     *
     * This causes the Vault to call the `IBasePool.onExitPool` hook on the Pool's contract, where Pools implement
     * their own custom logic. This typically requires additional information from the user (such as the expected number
     * of Pool shares to return). This can be encoded in the `userData` argument, which is ignored by the Vault and
     * passed directly to the Pool's contract.
     *
     * Emits a `PoolBalanceChanged` event.
     */
    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

    struct ExitPoolRequest {
        IAsset[] assets;
        uint[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    function getPoolTokens(bytes32 poolId) external view returns (
        IERC20[] calldata tokens,
        uint[] calldata balances,
        uint lastChangeBlock
    );
}

interface IStablePool {
    function getPoolId() external view returns (bytes32);
}

interface IMasterChef {
    function getPoolIdForLpToken(IERC20 _lpToken) external view returns (uint);

    function deposit(uint _pid, uint _amount, address _claimable) external;

    function withdraw(uint _pid, uint _amount, address _claimable) external;

    function harvest(uint _pid, address _to) external;

    function userInfo(uint _pid, address _user) external view returns (uint, uint);
}


/// @notice FantOHM PRO - Single sided stable bond
/// @dev based on UsdbABondDepository
contract SingleSidedLPBondDepository is Ownable, ReentrancyGuard {

    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    /* ======== EVENTS ======== */

    event BondCreated(address indexed depositor, uint depositInDai, uint amountInLP, uint indexed expires, uint indexed priceInUSD);
    event BondRedeemed(address indexed recipient, uint payoutInDai, uint amountInLP, uint remainingInDai);
    event BondIlProtectionRedeem(address indexed recipient, uint payoutInFhm, uint payoutInDai);

    uint internal constant max = type(uint).max;


    /* ======== STATE VARIABLES ======== */

    address public immutable FHM; // token given as payment for bond
    address public immutable USDB; // USDB
    address public immutable principle; // token used to create bond
    address public immutable treasury; // mints FHM when receives principle
    address public immutable DAO; // receives profit share from bond
    address public immutable usdbMinter; // receives profit share from bond
    address public immutable masterChef; // MasterChef

    address public immutable balancerVault; // beets vault to add/remove LPs
    address public immutable lpToken; // USDB/principle LP token

    AggregatorV3Interface internal priceFeed;

    Terms public terms; // stores terms for new bonds

    mapping(address => Bond) public bondInfo; // stores bond information for depositors

    uint public totalDebt; // total value of outstanding bonds; used for pricing
    uint public lastDecay; // reference block for debt decay
    uint public dustRounding;
    uint public ilProtectionMaxCapInUsd;
    uint public ilProtectionFullProtectionInDays;

    bool public useWhitelist;
    bool public useCircuitBreaker;
    mapping(address => bool) public whitelist;
    SoldBonds[] public soldBondsInHour;

    /* ======== STRUCTS ======== */

    // Info for creating new bonds
    struct Terms {
        uint vestingTerm; // in blocks
        uint discount; // discount in in thousandths of a % i.e. 5000 = 5%
        uint maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint maxDebt; // 9 decimal debt ratio, max % total supply created as debt
        uint soldBondsLimitUsd; //
        uint ilProtectionMinBlocksFromDeposit; // minimal blocks between deposit to apply IL protection
        uint ilProtectionRewardsVestingBlocks; // minimal blocks to wait between liquidation of the position and claiming IL protection rewards
        uint ilProtectionMinimalLossInUsd; // minimal loss in usd
    }

    /// @notice Info for bond holder
    struct Bond {
        uint payout; // minimal principle to be paid
        uint lpTokenAmount; // amount of lp token
        uint vesting; // Blocks left to vest
        uint lastBlock; // Last interaction
        uint pricePaid; // In DAI, for front end viewing
        uint ilProtectionAmountInUsd; // amount in usd to use for IL protection rewards
        uint ilProtectionUnlockBlock; // block number in which amount is unlocked
    }

    struct SoldBonds {
        uint timestampFrom;
        uint timestampTo;
        uint payoutInUsd;
    }

    /* ======== INITIALIZATION ======== */

    constructor (
        address _FHM,
        address _USDB,
        address _principle,
        address _treasury,
        address _DAO,
        address _usdbMinter,
        address _balancerVault,
        address _lpToken,
        address _masterChef,
        address _priceFeed
    ) {
        require(_FHM != address(0));
        FHM = _FHM;
        require(_USDB != address(0));
        USDB = _USDB;
        require(_principle != address(0));
        principle = _principle;
        require(_treasury != address(0));
        treasury = _treasury;
        require(_DAO != address(0));
        DAO = _DAO;
        require(_usdbMinter != address(0));
        usdbMinter = _usdbMinter;
        require(_balancerVault != address(0));
        balancerVault = _balancerVault;
        require(_lpToken != address(0));
        lpToken = _lpToken;
        require(_masterChef != address(0));
        masterChef = _masterChef;
        require(_priceFeed != address(0));
        priceFeed = AggregatorV3Interface(_priceFeed);
        useWhitelist = true;
        whitelist[msg.sender] = true;
        dustRounding = 1;
        ilProtectionFullProtectionInDays = 100;

        IERC20(_principle).approve(_balancerVault, max);
        IERC20(_USDB).approve(_balancerVault, max);
        IERC20(_lpToken).approve(_masterChef, max);
        IERC20(_lpToken).approve(_balancerVault, max);
    }

    /**
     *  @notice initializes bond parameters
     *  @param _vestingTerm uint
     *  @param _discount uint
     *  @param _maxPayout uint
     *  @param _fee uint
     *  @param _maxDebt uint
     *  @param _initialDebt uint
     *  @param _soldBondsLimitUsd uint
     *  @param _useWhitelist bool
     *  @param _useCircuitBreaker bool
     *  @param _ilProtectionMinBlocksFromDeposit uint
     *  @param _ilProtectionRewardsVestingBlocks uint
     *  @param _ilProtectionMinimalLossInUsd uint
     */
    function initializeBondTerms(
        uint _vestingTerm,
        uint _discount,
        uint _maxPayout,
        uint _fee,
        uint _maxDebt,
        uint _initialDebt,
        uint _soldBondsLimitUsd,
        bool _useWhitelist,
        bool _useCircuitBreaker,
        uint _ilProtectionMinBlocksFromDeposit,
        uint _ilProtectionRewardsVestingBlocks,
        uint _ilProtectionMinimalLossInUsd
    ) external onlyPolicy() {
        terms = Terms({
        vestingTerm : _vestingTerm,
        discount : _discount,
        maxPayout : _maxPayout,
        fee : _fee,
        maxDebt : _maxDebt,
        soldBondsLimitUsd : _soldBondsLimitUsd,
        ilProtectionMinBlocksFromDeposit: _ilProtectionMinBlocksFromDeposit,
        ilProtectionRewardsVestingBlocks: _ilProtectionRewardsVestingBlocks,
        ilProtectionMinimalLossInUsd: _ilProtectionMinimalLossInUsd
        });
        totalDebt = _initialDebt;
        lastDecay = block.number;
        useWhitelist = _useWhitelist;
        useCircuitBreaker = _useCircuitBreaker;
    }




    /* ======== POLICY FUNCTIONS ======== */

    enum PARAMETER {VESTING, PAYOUT, FEE, DEBT}
    /**
     *  @notice set parameters for new bonds
     *  @param _parameter PARAMETER
     *  @param _input uint
     */
    function setBondTerms(PARAMETER _parameter, uint _input) external onlyPolicy() {
        if (_parameter == PARAMETER.VESTING) {// 0
            require(_input >= 10000, "Vesting must be longer than 10000 blocks");
            terms.vestingTerm = _input;
        } else if (_parameter == PARAMETER.PAYOUT) {// 1
            require(_input <= 1000, "Payout cannot be above 1 percent");
            terms.maxPayout = _input;
        } else if (_parameter == PARAMETER.FEE) {// 2
            require(_input <= 10000, "DAO fee cannot exceed payout");
            terms.fee = _input;
        } else if (_parameter == PARAMETER.DEBT) {// 3
            terms.maxDebt = _input;
        }
    }

    /* ======== USER FUNCTIONS ======== */

    /**
     *  @notice deposit bond
     *  @param _amount uint amount in DAI
     *  @param _maxPrice uint
     *  @param _depositor address
     *  @return uint
     */
    function deposit(
        uint _amount,
        uint _maxPrice,
        address _depositor
    ) external nonReentrant returns (uint) {
        require(_depositor != address(0), "Invalid address");
        // allow only whitelisted contracts
        if (useWhitelist) require(whitelist[msg.sender], "SENDER_IS_NOT_IN_WHITELIST");

        decayDebt();
        require(totalDebt <= terms.maxDebt, "Max capacity reached");

        // Stored in bond info
        uint nativePrice = bondPrice();

        require(_maxPrice >= nativePrice, "Slippage limit: more than max price");
        // slippage protection

        uint value = ITreasury(treasury).valueOf(principle, _amount).mul(10 ** 9);
        uint payout = payoutFor(value);
        // payout to bonder is computed

        require(payout >= 10_000_000_000_000_000, "Bond too small");
        // must be > 0.01 DAI ( underflow protection )
        require(payout <= maxPayout(), "Bond too large");
        // size protection because there is no slippage
        require(!circuitBreakerActivated(payout), "CIRCUIT_BREAKER_ACTIVE");

        uint _usdbAmount = usdbAmountForPrinciple(_amount);
        uint payoutInFhm = payoutInFhmFor(_usdbAmount);

        // profits are calculated
        uint fee = payoutInFhm.mul(terms.fee).div(10000);

        IERC20(principle).safeTransferFrom(msg.sender, address(this), _amount);

        ITreasury(treasury).mintRewards(address(this), payoutInFhm.add(fee));

        // mint USDB with guaranteed discount
        IMintable(USDB).mint(address(this), _usdbAmount);

        // burn whatever FHM got from treasury in current market price
        IBurnable(FHM).burn(payoutInFhm);

        uint _lpTokenAmount = joinPool(_amount, _usdbAmount);
        uint poolId = IMasterChef(masterChef).getPoolIdForLpToken(IERC20(lpToken));
        IMasterChef(masterChef).deposit(poolId, _lpTokenAmount, _depositor);

        if (fee != 0) {// fee is transferred to dao
            IERC20(FHM).safeTransfer(DAO, fee);
        }

        // total debt is increased
        totalDebt = totalDebt.add(value);

        // update sold bonds
        if (useCircuitBreaker) updateSoldBonds(_amount);

        // depositor info is stored
        bondInfo[_depositor] = Bond({
        payout : bondInfo[_depositor].payout.add(_amount),
        lpTokenAmount : bondInfo[_depositor].lpTokenAmount.add(_lpTokenAmount),
        vesting : terms.vestingTerm,
        lastBlock : block.number,
        pricePaid : bondPriceInUSD(),
        ilProtectionAmountInUsd: bondInfo[_depositor].ilProtectionAmountInUsd,
        ilProtectionUnlockBlock: bondInfo[_depositor].ilProtectionUnlockBlock
        });

        // indexed events are emitted
        emit BondCreated(_depositor, _amount, _lpTokenAmount, block.number.add(terms.vestingTerm), bondPriceInUSD());

        return payout;
    }

    /**
     * @dev This helper function is a fast and cheap way to convert between IERC20[] and IAsset[] types
     */
    function _convertERC20sToAssets(IERC20[] memory tokens) internal pure returns (IAsset[] memory assets) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            assets := tokens
        }
    }

    function joinPool(uint _principleAmount, uint _usdbAmount) private returns (uint _lpTokenAmount) {
        // https://dev.balancer.fi/resources/joins-and-exits/pool-joins
        // https://github.com/balancer-labs/balancer-v2-monorepo/blob/master/pkg/balancer-js/src/pool-stable/encoder.ts
        (IERC20[] memory tokens,) = getPoolTokens();

        uint[] memory rawAmounts = new uint[](2);
        rawAmounts[0] = _usdbAmount;
        rawAmounts[1] = _principleAmount;

        bytes memory userDataEncoded = abi.encode(1 /* EXACT_TOKENS_IN_FOR_BPT_OUT */, rawAmounts, 0);

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
        assets : _convertERC20sToAssets(tokens),
        maxAmountsIn : rawAmounts,
        userData : userDataEncoded,
        fromInternalBalance : false
        });

        uint tokensBefore = IERC20(lpToken).balanceOf(address(this));
        IVault(balancerVault).joinPool(IStablePool(lpToken).getPoolId(), address(this), address(this), request);
        uint tokensAfter = IERC20(lpToken).balanceOf(address(this));

        _lpTokenAmount = tokensAfter.sub(tokensBefore);
    }

    function exitPool(uint _lpTokensAmount) private returns (uint _usdbAmount, uint _principleAmount) {
        (IERC20[] memory tokens,) = getPoolTokens();

        // https://dev.balancer.fi/resources/joins-and-exits/pool-exits
        uint[] memory minAmountsOut = new uint[](2);

        bytes memory userDataEncoded = abi.encode(1 /* EXACT_BPT_IN_FOR_TOKENS_OUT */, _lpTokensAmount);

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest({
        assets : _convertERC20sToAssets(tokens),
        minAmountsOut : minAmountsOut,
        userData : userDataEncoded,
        toInternalBalance : false
        });

        uint usdbBefore = IERC20(USDB).balanceOf(address(this));
        uint principleBefore = IERC20(principle).balanceOf(address(this));
        IVault(balancerVault).exitPool(IStablePool(lpToken).getPoolId(), address(this), payable(address(this)), request);
        uint usdbAfter = IERC20(USDB).balanceOf(address(this));
        uint principleAfter = IERC20(principle).balanceOf(address(this));

        _usdbAmount = usdbAfter.sub(usdbBefore);
        _principleAmount = principleAfter.sub(principleBefore);
    }

    /**
     *  @notice redeem bond for user
     *  @param _recipient address
     *  @param _amount uint amount of lpToken
     *  @param _amountMin uint  slippage minimal amount in dai
     *  @return uint amount in dai really claimed
     */
    function redeem(address _recipient, uint _amount, uint _amountMin) external nonReentrant returns (uint) {
        require(_recipient == msg.sender, "CALL_FORBIDDEN");
        // due to integer math there needs to be some dusting which is still considered as full withdraw
        _amount = _amount.sub(dustRounding);

        Bond storage info = bondInfo[_recipient];
        require(_amount <= info.lpTokenAmount, "Exceed the deposit amount");
        // (blocks since last interaction / vesting term remaining)
        uint percentVested = percentVestedFor(_recipient);

        require(percentVested >= 10000, "Wait for end of bond");

        IMasterChef _masterChef = IMasterChef(masterChef);
        uint poolId = _masterChef.getPoolIdForLpToken(IERC20(lpToken));
        (uint lpTokenAmount,) = _masterChef.userInfo(poolId, _recipient);
        require(_amount <= lpTokenAmount, "Exceed the deposit amount");
        _masterChef.withdraw(poolId, _amount, _recipient);

        // disassemble LP into tokens
        (uint _usdbAmount, uint _principleAmount) = exitPool(_amount);
        require(_principleAmount >= _amountMin, "Slippage limit: more than amountMin");

        // @dev to test il protection redeem lets change _principleAmount to _principleAmount.div(2) in the line below
        uint ilUsdWorth = ilProtectionClaimable(_recipient, _amount, _principleAmount);
        if (ilUsdWorth > 0) {
            info.ilProtectionAmountInUsd = info.ilProtectionAmountInUsd.add(ilUsdWorth);
            info.ilProtectionUnlockBlock = block.number + terms.ilProtectionRewardsVestingBlocks;
        }

        uint toSendToDao = 0;
        if (_principleAmount > info.payout) {
            toSendToDao = _principleAmount.sub(info.payout);
            _principleAmount = info.payout;
        }

        if (_principleAmount < info.payout) {
            info.payout = info.payout.sub(_principleAmount);
        } else {
            info.payout = 0;
        }

        info.lpTokenAmount = info.lpTokenAmount.sub(_amount);

        // delete user info if there is no IL
        if (info.lpTokenAmount <= dustRounding && info.ilProtectionAmountInUsd == 0) {
            delete bondInfo[_recipient];
        }

        emit BondRedeemed(_recipient, _principleAmount, _amount, info.payout);
        // emit bond data

        IBurnable(USDB).burn(_usdbAmount);
        IERC20(principle).transfer(_recipient, _principleAmount);
        if (toSendToDao > 0) {
            IERC20(principle).transfer(DAO, toSendToDao);
        }

        return _principleAmount;
    }

    /// @notice claim IL protection rewards in FHM
    /// @param _recipient address which receive tokens
    /// @return amount in FHM which was redeemed
    function ilProtectionRedeem(address _recipient) external nonReentrant returns (uint) {
        Bond storage info = bondInfo[_recipient];

        uint usdAmount = info.ilProtectionAmountInUsd;
        uint fhmAmount = payoutInFhmFor(usdAmount);

        require(usdAmount > 0, "NOT_ELIGIBLE");
        require(block.number >= info.ilProtectionUnlockBlock, "CLAIMING_TOO_SOON");

        info.ilProtectionAmountInUsd = 0;
        info.ilProtectionUnlockBlock = 0;

        // clean the user info
        if (info.lpTokenAmount <= dustRounding) {
            delete bondInfo[_recipient];
        }

        emit BondIlProtectionRedeem(_recipient, fhmAmount, usdAmount);

        ITreasury(treasury).mintRewards(_recipient, fhmAmount);

        return fhmAmount;
    }

    /// @notice count what usd worth user can claim if one liquidate its position with given priciple amount
    /// @param _recipient user whos asking for IL protection
    /// @param _lpTokenAmount lp token position user is liquidating
    /// @param _principleAmount amount in principle user will get for its _lpTokenAmount position
    /// @return amount in usd user could claim when vesting period ends
    function ilProtectionClaimable(address _recipient, uint _lpTokenAmount, uint _principleAmount) public view returns (uint) {
        Bond memory info = bondInfo[_recipient];

        // if there is not enough time between deposit and redeem
        if (block.number - info.lastBlock < terms.ilProtectionMinBlocksFromDeposit) return 0;
        // if there is something left in position
        if (_lpTokenAmount < info.lpTokenAmount.sub(dustRounding)) return 0;

        // if liquidated position principle is less then
        uint ilInPrinciple = 0;
        if (info.payout > _principleAmount) {
            ilInPrinciple = info.payout.sub(_principleAmount);
        }
        uint claimable = ilInPrinciple.mul(uint(assetPrice())).div(1e8); // 8 decimals feed
        // full IL protection after 100 days,
        uint daysStaking = (block.number - info.lastBlock) / (24 * 60 * 60);
        claimable = Math.min(claimable, claimable.mul(daysStaking).div(ilProtectionFullProtectionInDays));

        if (claimable < terms.ilProtectionMinimalLossInUsd) return 0;
        else if (claimable >= ilProtectionMaxCapInUsd) return ilProtectionMaxCapInUsd;
        else return claimable;
    }

    /* ======== INTERNAL HELPER FUNCTIONS ======== */

    /**
     *  @notice get asset price from chainlink
     */
    function assetPrice() public view returns (int) {
        ( , int price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function modifyWhitelist(address user, bool add) external onlyPolicy {
        if (add) {
            require(!whitelist[user], "ALREADY_IN_WHITELIST");
            whitelist[user] = true;
        } else {
            require(whitelist[user], "NOT_IN_WHITELIST");
            delete whitelist[user];
        }
    }

    function updateSoldBonds(uint _payout) internal {
        uint length = soldBondsInHour.length;
        if (length == 0) {
            soldBondsInHour.push(SoldBonds({
            timestampFrom : block.timestamp,
            timestampTo : block.timestamp + 1 hours,
            payoutInUsd : _payout
            }));
            return;
        }

        SoldBonds storage soldBonds = soldBondsInHour[length - 1];
        // update in existing interval
        if (soldBonds.timestampFrom < block.timestamp && soldBonds.timestampTo >= block.timestamp) {
            soldBonds.payoutInUsd = soldBonds.payoutInUsd.add(_payout);
        } else {
            // create next interval if its continuous
            uint nextTo = soldBonds.timestampTo + 1 hours;
            if (block.timestamp <= nextTo) {
                soldBondsInHour.push(SoldBonds({
                timestampFrom : soldBonds.timestampTo,
                timestampTo : nextTo,
                payoutInUsd : _payout
                }));
            } else {
                soldBondsInHour.push(SoldBonds({
                timestampFrom : block.timestamp,
                timestampTo : block.timestamp + 1 hours,
                payoutInUsd : _payout
                }));
            }
        }
    }

    function circuitBreakerCurrentPayout() public view returns (uint _amount) {
        if (soldBondsInHour.length == 0) return 0;

        uint _max = 0;
        if (soldBondsInHour.length >= 24) _max = soldBondsInHour.length - 24;

        uint to = block.timestamp;
        uint from = to - 24 hours;
        for (uint i = _max; i < soldBondsInHour.length; i++) {
            SoldBonds memory soldBonds = soldBondsInHour[i];
            if (soldBonds.timestampFrom >= from && soldBonds.timestampFrom <= to) {
                _amount = _amount.add(soldBonds.payoutInUsd);
            }
        }

        return _amount;
    }

    function circuitBreakerActivated(uint payout) public view returns (bool) {
        if (!useCircuitBreaker) return false;
        payout = payout.add(circuitBreakerCurrentPayout());
        return payout > terms.soldBondsLimitUsd;
    }

    function getMarketPrice() public view returns (uint _marketPrice) {
        _marketPrice = IUsdbMinter(usdbMinter).getMarketPrice();
    }

    /**
     *  @notice reduce total debt
     */
    function decayDebt() internal {
        totalDebt = totalDebt.sub(debtDecay());
        lastDecay = block.number;
    }




    /* ======== VIEW FUNCTIONS ======== */

    /**
     *  @notice determine maximum bond size
     *  @return uint
     */
    function maxPayout() public view returns (uint) {
        return IERC20(USDB).totalSupply().mul(terms.maxPayout).div(100000);
    }

    /**
     *  @notice calculate interest due for new bond
     *  @param _value uint
     *  @return uint
     */
    function payoutFor(uint _value) public view returns (uint) {
        return FixedPoint.fraction(_value, bondPrice()).decode112with18().div(1e16);
    }

    function payoutInFhmFor(uint _usdbValue) public view returns (uint) {
        return FixedPoint.fraction(_usdbValue, getMarketPrice()).decode112with18().div(1e16).div(1e9);
    }

    /**
     *  @notice calculate current bond premium
     *  @return price_ uint
     */
    function bondPrice() public view returns (uint price_) {
        uint _originalPrice = 1;
        _originalPrice = _originalPrice.mul(10 ** 2);

        uint _discount = _originalPrice.mul(terms.discount).div(10 ** 5);
        price_ = _originalPrice.sub(_discount);
    }

    /**
     *  @notice converts bond price to DAI value
     *  @return price_ uint
     */
    function bondPriceInUSD() public view returns (uint price_) {
        price_ = bondPrice().mul(10 ** IERC20(principle).decimals()).div(10 ** 2);
    }
    /**
     *  @notice calculate current ratio of debt to USDB supply
     *  @return debtRatio_ uint
     */
    function debtRatio() public view returns (uint debtRatio_) {
        uint supply = IERC20(USDB).totalSupply();
        debtRatio_ = FixedPoint.fraction(
            currentDebt().mul(1e9),
            supply
        ).decode112with18().div(1e18);
    }

    /**
     *  @notice debt ratio in same terms for reserve or liquidity bonds
     *  @return uint
     */
    function standardizedDebtRatio() external view returns (uint) {
        return debtRatio();
    }

    /**
     *  @notice calculate debt factoring in decay
     *  @return uint
     */
    function currentDebt() public view returns (uint) {
        return totalDebt.sub(debtDecay());
    }

    /**
     *  @notice amount to decay total debt by
     *  @return decay_ uint
     */
    function debtDecay() public view returns (uint decay_) {
        uint blocksSinceLast = block.number.sub(lastDecay);
        decay_ = totalDebt.mul(blocksSinceLast).div(terms.vestingTerm);
        if (decay_ > totalDebt) {
            decay_ = totalDebt;
        }
    }


    /**
     *  @notice calculate how far into vesting a depositor is
     *  @param _depositor address
     *  @return percentVested_ uint
     */
    function percentVestedFor(address _depositor) public view returns (uint percentVested_) {
        Bond memory bond = bondInfo[_depositor];
        uint blocksSinceLast = block.number.sub(bond.lastBlock);
        uint vesting = bond.vesting;

        if (vesting > 0) {
            percentVested_ = blocksSinceLast.mul(10000).div(vesting);
        } else {
            percentVested_ = 0;
        }
    }

    /**
     *  @notice calculate amount of FHM available for claim by depositor
     *  @param _depositor address
     *  @return pendingPayout_ uint
     */
    function pendingPayoutFor(address _depositor) external view returns (uint pendingPayout_) {
        uint percentVested = percentVestedFor(_depositor);
        uint actualPayout = balanceOfPooled(_depositor);

        // return original amount + trading fees (half of LP token amount) or deposited amount in case of IL (will pay difference in FHM)
        uint payout = Math.max(actualPayout, bondInfo[_depositor].payout);

        if (percentVested >= 10000) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = 0;
        }
    }

    function getStakedTokens(address _depositor) public view returns (uint lpTokenAmount) {
        IMasterChef _masterChef = IMasterChef(masterChef);
        uint poolId = _masterChef.getPoolIdForLpToken(IERC20(lpToken));
        (lpTokenAmount,) = _masterChef.userInfo(poolId, _depositor);
    }

    function getPoolTokens() public view returns (IERC20[] memory tokens, uint[] memory totalBalances) {
        (tokens, totalBalances,) = IVault(balancerVault).getPoolTokens(IStablePool(lpToken).getPoolId());
    }

    /// @notice computes actual allocation inside LP token from your position
    /// @param _depositor user
    /// @return payout_ in principle
    function balanceOfPooled(address _depositor) public view returns (uint payout_) {
        (uint lpTokenAmount) = getStakedTokens(_depositor);

        (IERC20[] memory tokens, uint[] memory totalBalances) = getPoolTokens();
        for (uint i = 0; i < 2; i++) {
            IERC20 token = tokens[i];
            if (address(token) == principle) {
                return totalBalances[i].mul(lpTokenAmount).div(IERC20(lpToken).totalSupply());
            }
        }

        return 0;
    }

    /// @notice count amount of usdb for given amount in principle to create LP token from
    /// @dev D / U = d / u => u = d * U / D
    function usdbAmountForPrinciple(uint _principleAmount) public view returns (uint) {
        (IERC20[] memory tokens, uint[] memory totalBalances) = getPoolTokens();

        if (address(tokens[0]) == principle) {
            return _principleAmount.mul(totalBalances[1]).div(totalBalances[0]);
        } else {
            return _principleAmount.mul(totalBalances[0]).div(totalBalances[1]);
        }
    }

    /// @notice sets amount which is still consider a dust
    function setDustRounding(uint _dustRounding) external onlyPolicy {
        require(_dustRounding <= 1000, "DUST_ROUNDING_TOO_BIG");
        dustRounding = _dustRounding;
    }

    function setIlProtectionMaxCapInUsd(uint _ilProtectionMaxCapInUsd) external onlyPolicy {
        ilProtectionMaxCapInUsd = _ilProtectionMaxCapInUsd;
    }

    function setIlProtectionFullProtectionInDays(uint _ilProtectionFullProtectionInDays) external onlyPolicy {
        ilProtectionFullProtectionInDays = _ilProtectionFullProtectionInDays;
    }


    /* ======= AUXILLIARY ======= */

    /**
     *  @notice allow to send lost tokens (excluding principle or FHM) to the DAO
     *  @return bool
     */
    function recoverLostToken(address _token) external onlyPolicy returns (bool) {
        require(_token != FHM);
        require(_token != USDB);
        require(_token != principle);
        IERC20(_token).safeTransfer(DAO, IERC20(_token).balanceOf(address(this)));
        return true;
    }
}

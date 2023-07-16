const Tether = artifacts.require('Tether');
const RWD = artifacts.require('RWD');
const DecentralBank = artifacts.require('DecentralBank');

require('chai').use(require('chai-as-promised')).should()

// owner -> contract creator(1st account), customer -> 2nd account
contract('DecentralBank', ([owner, customer]) => {
  let tether, rwd, decentralBank

  function tokens(number) {
    return web3.utils.toWei(number, 'ether')
  }

  before(async () => {
    tether = await Tether.new()
    rwd = await RWD.new()
    decentralBank = await DecentralBank.new(tether.address, rwd.address)
    
    // Transfer 1 million reward token to bank
    await rwd.transfer(decentralBank.address, tokens('1000000'))

    // In Tether constructor 1 million tether assign to contract creator(owner)
    result = await tether.balanceOf(owner);
    assert.equal(result.toString(), tokens('1000000'), 'creator balance 1 million tether');

    // Transfer 100 tether to customer from 1st account
    await tether.transfer(customer, tokens('100'), {from: owner})
  })

  describe('Mock Tether Deployment', async () => {
    it('matches name successfully', async () => {
      const name = await tether.name()
      assert.equal(name, "Mock Tether")
    })
  })

  describe('Mock RWD Deployment', async () => {
    it('matches name successfully', async () => {
      const name = await rwd.name()
      assert.equal(name, "Reword Token")
    })
  })

  describe('Decentral Bank Deployment', async () => {
    it('matches name successfully', async () => {
      const name = await decentralBank.name()
      assert.equal(name, "Decentral Bank")
    })
    it('contract has tokens', async () => {
        let balance = await rwd.balanceOf(decentralBank.address)
        assert.equal(balance, tokens('1000000'))
    })
  })

  describe('Tield Farming', async () => {
    it('rewards tokens for staking', async () => {
      let result
      result = await tether.balanceOf(owner);
      assert.equal(result.toString(), tokens('999900'), 'owner mock balance');

      result = await tether.balanceOf(customer);
      assert.equal(result.toString(), tokens('100'), 'customer mock balance');
    
      // -------staking----------
      await tether.approve(decentralBank.address, tokens('100'), {from: customer});
      await decentralBank.depositeTokens(tokens('100'), {from: customer });
      
      // ----after staking------
      result = await tether.balanceOf(customer);
      assert.equal(result.toString(), tokens('0'), 'customer balance after stacking');
    
      result = await tether.balanceOf(decentralBank.address);
      assert.equal(result.toString(), tokens('100'), 'decentralBank balance after stacking');
    
      result = await decentralBank.isStaking(customer);
      assert.equal(result.toString(), 'true', 'customer staking status after staking');
      
      // result = await rwd.balanceOf(decentralBank.address);
      // assert.equal(result.toString(), tokens('1000000'), 'rwd balance after staking(no change of staking)')

      //-------unstaking-----------
      await decentralBank.issueTokens({from: owner});
      await decentralBank.issueTokens({from: customer}).should.be.rejected;
      await decentralBank.unstakeTokens({from: customer});

      // ----after unstaking------
      result = await tether.balanceOf(customer);
      assert.equal(result.toString(), tokens('100'), 'customer balance after unstacking');
    
      result = await tether.balanceOf(decentralBank.address);
      assert.equal(result.toString(), tokens('0'), 'decentralBank balance after unstacking');
    
      result = await decentralBank.isStaking(customer);
      assert.equal(result.toString(), 'false', 'customer staking status after unstaking');
     
      result = await rwd.balanceOf(customer);
      console.log(result.toString()); // rwd balance of customer

      result = await rwd.balanceOf(decentralBank.address);
      console.log(result.toString()); // rwd balance of bank
      
    })
  })
})
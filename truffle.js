/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() {
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>')
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

let HDWalletProvider = require('truffle-hdwallet-provider');
let mnemoic ="";

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // for more about customizing your Truffle configuration!
    networks: {
        rinkeby: {
            provider: function () {
                return new HDWalletProvider(mnemoic, 'https://rinkeby.infura.io/v3/34fcb4be022a4ebcbba6f632e91bf962')
            },
            network_id: 1
        }

    }
};
var elm_ethereum_ports = require('elm-ethereum-ports');
var secureComms = require('./secureComms');
window.forge = require('node-forge');

import { Elm } from '../../src/App'

window.testStuff = secureComms.testStuff;

window.addEventListener('load', function () {
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        ethereum.enable().then(function (val) {
            startDapp()
        }).catch(function (err) {
            startDapp();
        });
    }
    else {
        startDapp();
    }
});

function startDapp() {
    if (typeof web3 !== 'undefined') {
        web3.version.getNetwork(function (e, networkId) {
            window.app = Elm.App.init({
                node: document.getElementById('elm'),
                flags: {
                    networkId: parseInt(networkId),
                    width: window.innerWidth,
                    height: window.innerHeight
                }
            });
            portStuff(app);

        });
    } else {
        window.app = Elm.App.init({
            node: document.getElementById('elm'),
            flags: {
                networkId: parseInt(1),
                width: window.innerWidth,
                height: window.innerHeight
            }
        });
        console.log("Metamask not detected.");
    }
}

function portStuff(app) {
    elm_ethereum_ports.txSentry(app.ports.txOut, app.ports.txIn, web3);
    elm_ethereum_ports.walletSentry(app.ports.walletSentryPort, web3);
    app.ports.genPrivkey.subscribe(function (args) {
        secureComms.prepareKeypair(args.signSeedMsg, args.address, function (err, res) {
            console.log("pubkey: ", res)
            app.ports.userPubkeyResult.send(res);
        })
    });
    app.ports.encryptToPubkeys.subscribe(function (data) {
        var encryptedMessages = secureComms.encryptToPubkeys(data.message, data.pubkeyHexStrings);

        app.ports.encryptionFinished.send(encryptedMessages);
    });
    app.ports.decryptMessage.subscribe(function (data) {
        var id = data.id;

        var result = secureComms.decryptForUser(data.encapsulation, data.iv, data.tag, data.encrypted);
        if (!result) {
            console.log("Uh oh! Decryption didn't work...");
        }

        app.ports.decryptionFinished.send({ id: id, message: result })
    });
}
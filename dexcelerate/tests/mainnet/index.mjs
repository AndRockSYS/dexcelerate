import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { decodeSuiPrivateKey } from '@mysten/sui/cryptography';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';

const client = new SuiClient({
    url: getFullnodeUrl('mainnet'),
});

const owner = Ed25519Keypair.fromSecretKey(
    decodeSuiPrivateKey('suiprivkey1qrln78gu0mjhu3elufqy4m3xwvyv63ct8f6nakmqawn62yexashuuc4j7e6')
        .secretKey
);

const user = Ed25519Keypair.fromSecretKey(
    decodeSuiPrivateKey('suiprivkey1qr5plcme266jzl2fanfas3zxjfzsh4aljyhx78zwyk4dm59d240qj3d4h0d')
        .secretKey
);

// Hash Result - BkMiXpNVjrpTKptE8RoUcXHRuYszTAmRjx1H58oF1VPW
const testSwapV2WithSponsor = async () => {
    const tx = new Transaction();

    const gasAmount = await estimateGas();
    console.log(`Sponsor Amount ${gasAmount}`);

    tx.moveCall({
        target: `0x7f34a1ef1f2edb30f2653e3da4544d33248b0c064186bf07cfcb7f5859e7c8e6::slot_swap_v2::sell_with_base`,
        arguments: [
            tx.object('0xbf0a19f19a38ad17121122d76b9a7c082b7968c7b4cf383f2e25ab2c67f29874'),
            tx.object('0xde5f124b1c4411b78ab82f6d1dea233861a00a7aa03ed7e6a58c95c4bc93840f'),
            tx.pure.u64(0),
            tx.pure.u64(0),
            tx.object('0x75d3058654ed78572294721053166f0a0faffeca9bf264076ad433db2db070a9'), // user's slot
            tx.pure.u64(23200),
            tx.pure.u64(1),
            tx.object('0xb65dcbf63fd3ad5d0ebfbf334780dc9f785eff38a4459e37ab08fa79576ee511'), // flow_x
            tx.object('0x3f2d9f724f4a1ce5e71676448dc452be9a6243dac9c5b975a588c8c867066e92'), // blue_move
            tx.object('0xd746495d04a6119987c2b9334c5fefd7d8cff52a8a02a3ea4e3995b9a041ace4'), // move_pump
            tx.pure.u8(1), // 0 or 1 or 2
            tx.pure.u64(gasAmount),
            tx.pure.option('address', owner.toSuiAddress()),
            tx.object('0x0000000000000000000000000000000000000000000000000000000000000006'),
        ],
        typeArguments: [
            '0x5d4b302506645c37ff133b98c4b50a5ae14841659738d6d733d59d0d217a93bf::coin::COIN',
        ],
    });

    const kindBytes = await tx.build({ client, onlyTransactionKind: true });

    const sponsoredTx = Transaction.fromKind(kindBytes);

    const coins = await client.getAllCoins({ owner: owner.toSuiAddress() });

    sponsoredTx.setSender(user.toSuiAddress());
    sponsoredTx.setGasOwner(owner.toSuiAddress());
    sponsoredTx.setGasPayment([
        {
            objectId: coins.data[0].coinObjectId,
            digest: coins.data[0].digest,
            version: coins.data[0].version,
        },
    ]);

    const ownerSiganture = await owner.signTransaction(await sponsoredTx.build({ client }));
    const userSignature = await user.signTransaction(await sponsoredTx.build({ client }));

    const response = await client.executeTransactionBlock({
        transactionBlock: ownerSiganture.bytes,
        signature: [userSignature.signature, ownerSiganture.signature],
    });

    console.log(response);

    const receipt = await client.waitForTransaction({
        digest: response.digest,
    });

    console.log(receipt);
};

const estimateGas = async () => {
    const tx = new Transaction();

    tx.moveCall({
        target: `0x7f34a1ef1f2edb30f2653e3da4544d33248b0c064186bf07cfcb7f5859e7c8e6::slot_swap_v2::sell_with_base`,
        arguments: [
            tx.object('0xbf0a19f19a38ad17121122d76b9a7c082b7968c7b4cf383f2e25ab2c67f29874'),
            tx.object('0xde5f124b1c4411b78ab82f6d1dea233861a00a7aa03ed7e6a58c95c4bc93840f'),
            tx.pure.u64(0),
            tx.pure.u64(0),
            tx.object('0x75d3058654ed78572294721053166f0a0faffeca9bf264076ad433db2db070a9'), // user's slot
            tx.pure.u64(23200),
            tx.pure.u64(1),
            tx.object('0xb65dcbf63fd3ad5d0ebfbf334780dc9f785eff38a4459e37ab08fa79576ee511'), // flow_x
            tx.object('0x3f2d9f724f4a1ce5e71676448dc452be9a6243dac9c5b975a588c8c867066e92'), // blue_move
            tx.object('0xd746495d04a6119987c2b9334c5fefd7d8cff52a8a02a3ea4e3995b9a041ace4'), // move_pump
            tx.pure.u8(1), // 0 or 1 or 2
            tx.pure.u64(0),
            tx.pure.option('address', owner.toSuiAddress()),
            tx.object('0x0000000000000000000000000000000000000000000000000000000000000006'),
        ],
    });

    tx.setSender(user.toSuiAddress());
    tx.setGasBudget(100000000);

    const data = await client.dryRunTransactionBlock({
        transactionBlock: await tx.build({ client }),
    });

    return data.balanceChanges[0].amount;
};

testSwapV2WithSponsor();

// 	sui client ptb \
// --split-coins gas [10000000] \
// --assign coins \
// --move-call 0x7f34a1ef1f2edb30f2653e3da4544d33248b0c064186bf07cfcb7f5859e7c8e6::slot::deposit "<0x2::sui::SUI>" \
// @0x75d3058654ed78572294721053166f0a0faffeca9bf264076ad433db2db070a9 coins.0 @0x3f2d9f724f4a1ce5e71676448dc452be9a6243dac9c5b975a588c8c867066e92

// 	sui client ptb \
// --move-call 0x7f34a1ef1f2edb30f2653e3da4544d33248b0c064186bf07cfcb7f5859e7c8e6::slot_swap_v2::buy_with_base "<0x5d4b302506645c37ff133b98c4b50a5ae14841659738d6d733d59d0d217a93bf::coin::COIN>" \
// @0xbf0a19f19a38ad17121122d76b9a7c082b7968c7b4cf383f2e25ab2c67f29874 @0xde5f124b1c4411b78ab82f6d1dea233861a00a7aa03ed7e6a58c95c4bc93840f 0 0 \
// @0x75d3058654ed78572294721053166f0a0faffeca9bf264076ad433db2db070a9 \
// 11000000 0 \
// @0xb65dcbf63fd3ad5d0ebfbf334780dc9f785eff38a4459e37ab08fa79576ee511 \
// @0x3f2d9f724f4a1ce5e71676448dc452be9a6243dac9c5b975a588c8c867066e92 \
// @0xd746495d04a6119987c2b9334c5fefd7d8cff52a8a02a3ea4e3995b9a041ace4 \
// 1 \
// @0x0000000000000000000000000000000000000000000000000000000000000006

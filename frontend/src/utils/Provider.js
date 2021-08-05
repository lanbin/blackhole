import TxnWrapper, { TXN_PARAMS_TYPE, SerizalWithType } from '@wormhole-stc/txn-wrapper';
import ChainMethod, { TOKEN } from 'config/ChainMethod';

import { CurrencyAmount, Star } from '@starcoin/starswap-sdk-core';
import BigNumber from 'bignumber.js';
import { providers, bcs, serde } from '@starcoin/starcoin';

const PROVIDER_URL_MAP = {
  1: 'https://main-seed.starcoin.org',
  251: 'https://barnard-seed.starcoin.org',
};

const getJsonRpcProvider = () =>
  new providers.JsonRpcProvider(PROVIDER_URL_MAP[window.starcoin.networkVersion || 251]);

/**
 * All Token that I Have
 */
export const Account_Info = async (account) => {
  try {
    if (!window.starcoin) return;

    const resources = await getJsonRpcProvider().getBalances(account);
    return Promise.all(
      Object.keys(resources).map(async (resource) => {
        const [address, module, token] = resource.split('::');
        const amount = await CurrencyAmount.fromRawAmount(
          Star.onChain(parseInt(window.starcoin.networkVersion)),
          new BigNumber(resources[resource]),
        );
        return {
          tokenName: resource,
          name: token,
          amount: amount.toSignificant(9),
        };
      }),
    );
  } catch (err) {
    console.log(err);
  }
};

/**
 *
 */
export const GetPrecision = () => {
  return getJsonRpcProvider()
    .send('contract.call_v2', [
      { function_id: '0x1::Token::scaling_factor', type_args: ['0x1::STC::STC'], args: [] },
    ])
    .catch((err) => {
      console.log(err.body);
    });
};

/**
 */
export const GetAmout = ({ address }) => {
  return getJsonRpcProvider()
    .send('contract.call_v2', [{ function_id: ChainMethod.AMOUNT, type_args: [], args: [address] }])
    .catch((err) => {
      console.log(err.body);
    });
};

/**
 */
export const ClaimReward = ({ invite_address }) => {
  return TxnWrapper({
    functionId: ChainMethod.CLAIM_REWARD,
    typeTag: '',
    params: [invite_address],
  });
};

/**
 */
export const BurnToken = ({ token_identifier, token_amount, comment }) => {
  return TxnWrapper({
    functionId: ChainMethod.BURN,
    typeTag: [token_identifier],
    params: [
      {
        value: token_amount,
        type: TXN_PARAMS_TYPE.U128,
      },
      {
        value: comment,
        type: TXN_PARAMS_TYPE['vector<u8>'],
      },
    ],
  });
};

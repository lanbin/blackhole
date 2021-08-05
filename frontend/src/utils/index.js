import BigNumber from 'bignumber.js';

export const withPrecision = (value, precision) => {
  const multiplier = Math.pow(10, precision);
  return new BigNumber(value) * multiplier;
};

export const withoutPrecision = (value, precision) => {
  const multiplier = Math.pow(10, precision);
  return new BigNumber(value) / multiplier;
};

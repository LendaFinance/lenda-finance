var dayjs = require('dayjs');
var duration = require('dayjs/plugin/duration');
dayjs.extend(duration);

// 10^9 is billions, 10^6 is millions, 10^3 is thousands
// Token deployment
const preMinted = 1n * (10n ** 9n); // 1bn
const maxMinted = 5n * (10n ** 9n); // 5bn

const weiRate = 10n ** 18n; // funding goals are set in wei
const rate = 1000000n; // how many tokens for one native coin
const minFunding = weiRate * 300n; // BNB
const fundingGoal = weiRate * 600n; // BNB
const openingTime = dayjs('2022-01-10T00:00:00.000Z');
const closingTime = openingTime.add(60, 'd'); // ends in two months

// Tokenomics
const icoTokens = preMinted * weiRate * 60n / 100n;
const teamTokens = preMinted * weiRate * 20n / 100n;
const lpTokens = preMinted * weiRate * 15n / 100n;
const airdropTokens = preMinted * weiRate * 5n / 100n;
const annualMintTarget = preMinted * weiRate * 40n / 100n;

// TeamVestingFactory deployment
const vestingStart = dayjs().add(1, 'd');
const cliffDuration = dayjs.duration(1, 'm').as('s');
const vestingDuration = dayjs.duration(52, 'w').as('s');
const teamAddresses = [
    '0x7F7423E6a11b6f3E2C5f9870Fa46CBE3867c82Fa',
    '0x9CD10496c07FEbc0c6Ff4367C0eEce9F0F358ed0',
    '0xD9369356C5434BB334e64401C638E73006Ae0E23',
    '0x49E118A32bBD10Ad7F6B0b89DcA1D61D3Fa5500f',
    '0xc6322D0244446A5091421f4BF8B5d85306a54cf5',
    '0xb277Ab96bDBc68CDF3AE115eE09877fb8Aa3e527',
    '0xcd2edABbD64eE75E24378Feab112de57726Ac40a',
    '0xC8D02d0815B1cE70eDDEC4c198e8420e5860CC72',
];

// Staking
const cooldown = dayjs.duration(14, 'd').as('s');

module.exports = {
    preMinted,
    maxMinted,
    weiRate,
    rate,
    minFunding,
    fundingGoal,
    openingTime,
    closingTime,
    icoTokens,
    teamTokens,
    lpTokens,
    airdropTokens,
    annualMintTarget,
    vestingStart,
    cliffDuration,
    vestingDuration,
    teamAddresses,
    cooldown,
};

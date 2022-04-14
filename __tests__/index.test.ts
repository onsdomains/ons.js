import { ethers } from 'ethers';
import ONS from '../src/index'
const Web3 = require('web3');

describe('getName', () => {
    test('Valid Address (domain)', async () => {
        const web3p = new Web3.providers.HttpProvider('https://emerald.oasis.dev');
        const provider = new ethers.providers.Web3Provider(web3p)
        const ons = new ONS({ provider })
        const result = await ons.getName('0xf14645A3A6C7AF9a2545Ede9c8CB49B60ffE6574')
        expect(result).toBe('zzzzzzzzzzzzzzzzzzzzzzzz.ons');
    });
    test('Valid Address (NO domain)', async () => {
        const web3p = new Web3.providers.HttpProvider('https://emerald.oasis.dev');
        const provider = new ethers.providers.Web3Provider(web3p)
        const ons = new ONS({ provider })
        try {
            await ons.getName('0x9140CF48bC19288808179F81ae234302a018E757')
        } catch (e: any) {
            expect(e.message).toBe("User does not have a primary name");
        }
    });
    test('Invalid Address', async () => {
        const web3p = new Web3.providers.HttpProvider('https://emerald.oasis.dev');
        const provider = new ethers.providers.Web3Provider(web3p)
        const ons = new ONS({ provider })
        try {
            await ons.getName('asdasd')
        } catch (e: any) {
            expect(e.message).toBe("Invalid address");
        }
        //expect(result).toBe('zzzzzzzzzzzzzzzzzzzzzzzz.ons');
    });
});
describe('getAddress', () => {
    test('Valid name', async () => {
        const web3p = new Web3.providers.HttpProvider('https://emerald.oasis.dev');
        const provider = new ethers.providers.Web3Provider(web3p)
        const ons = new ONS({ provider })
        const result = await ons.getAddress('mehrab.ons')
        expect(result).toBe('0x4611957096bAB8a6DF2aa575d9DaBc27Ae246f58');
    });
    test('Inalid name', async () => {
        const web3p = new Web3.providers.HttpProvider('https://emerald.oasis.dev');
        const provider = new ethers.providers.Web3Provider(web3p)
        const ons = new ONS({ provider })
        try {
            await ons.getAddress('mehrabss.ons')
        } catch (e: any) {
            expect(e.message).toBe('This name does not exist');
        }
    });
});
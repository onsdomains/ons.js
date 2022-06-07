const hre = require("hardhat");
const { ethers } = require("hardhat");
import ONSRegister from '../src/contracts/ONSRegsiter';
import PublicResolver from '../src/contracts/PublicResolver';
import RegisterController from '../src/contracts/RegisterController';
import NFTResolver from '../src/contracts/NFTResolver';
import ONS from '../src/index'
const Web3 = require('web3');
const addressBook = 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6
jest.setTimeout(20000)

describe('get Address', () => {
    let ons: any = null;
    let address1: string;
    beforeAll(async () => {
        const web3p = new Web3.providers.HttpProvider('http://127.0.0.1:8545/');
        const provider = new ethers.providers.Web3Provider(web3p)
        let privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
        ons = new ONS({ provider })
        await ons.init(addressBook)
        const addr1 = new ethers.Wallet(privateKey, provider)
        address1 = addr1.address
        const ControllerAddress = await ons.getContractAddress("ControllerContract")
        const ControllerC = new ethers.Contract(ControllerAddress, RegisterController.abi, provider)
        const PublicResolverAddress = await ons.getContractAddress("PublicResolver")
        const PublicResolverC = new ethers.Contract(PublicResolverAddress, PublicResolver.abi, provider)
        const NFTResolverAddr = await ons.getContractAddress("NFTResolver")
        const ONSRegisterAddress = await ons.getContractAddress("BaseContract")
        const ONSRegisterC = new ethers.Contract(ONSRegisterAddress, ONSRegister.abi, provider)
        const tx = await ControllerC.connect(addr1).register('mehrab', 0, 1, { value: ethers.utils.parseEther('60') })
        tx.wait()
        const getTokenID = await ONSRegisterC.tokenOfOwnerByIndex(address1, 0);
        await PublicResolverC.connect(addr1).editText(getTokenID, "com.twitter", "mehrab");
        const DummyERC721Addrs = await ons.getContractAddress("DummyERC721")
        await PublicResolverC.connect(addr1).editNFT(getTokenID, DummyERC721Addrs, 5);
    })
    test('getAddress > Valid name', async () => {
        const result = await ons.name('mehrab.ons').getAddress()
        expect(result).toBe(address1);
    })
    // test('getAddress > Ivnalid name', async () => {

    //     try {
    //         await ons.name('null.ons').getAddress()
    //     } catch (e: any) {
    //         expect(e.message).toBe('This name does not exist');
    //     }
    // });
    test('getName > Valid Address (domain)', async () => {
        const result = await ons.getName('0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266')
        expect(result).toBe('mehrab.ons');
    });
    test('getName > Invalid Address', async () => {
        try {
            await ons.getName('INVALIDADDRESS')
        } catch (e: any) {
            expect(e.message).toBe("Invalid address");
        }
    });
    test('getName > Invalid Address (NO domain)', async () => {
        try {
            await ons.getName('0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc')
        } catch (e: any) {
            expect(e.message).toBe("Something went wrong");
        }
    });
    test('getTwitter > Valid name', async () => {
        const result = await ons.name('mehrab.ons').getTwitter()
        expect(result).toBe('mehrab');
    })
    test('getTwitter > Inalid name', async () => {
        try {
            await ons.name('mehraaab.ons').getTwitter()
        } catch (e: any) {
            expect(e.message).toContain('Domain is not available');
        }
    })
    test('getInstagram > unknown', async () => {
        const result = await ons.name('mehrab.ons').getInstagram()
        expect(result).toBe(undefined);
    })
    test('getAvatarUrl > Invalid', async () => {
        try {
            const result = await ons.name('mehrab.ons').getAvatarUrl()
        } catch (e: any) {
            expect(e.message).toContain('Something went wrong');
        }
    })

});
